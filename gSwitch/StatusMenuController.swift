//
//  StatusMenuController.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!

    @IBOutlet weak var CurrentGPU: NSMenuItem!
    
    @IBOutlet weak var IntegratedOnlyItem: NSMenuItem!
    
    @IBOutlet weak var Dependencies: NSMenuItem!
    
    @IBOutlet weak var DiscreteOnlyItem: NSMenuItem!
    
    @IBOutlet weak var DynamicSwitchingItem: NSMenuItem!
    
    var appDelegate: AppDelegate?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        appDelegate = (NSApplication.shared.delegate as! AppDelegate) 
        
        statusItem.menu = statusMenu
        
        CurrentGPU.title = "GPU: \(appDelegate?.manager.currentGPU ?? "Unknown")"
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeGPUNameInMenu(notification:)), name: .checkGPUState, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProcessList(notification:)), name: .updateProcessListInMenu, object: nil)
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
    }
    
    @IBAction func intergratedOnlyClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .ForceIntergrated) {
            return  //already set
        }
        
        let hungryProcesses = appDelegate?.processer.getHungryProcesses()
        
        if(hungryProcesses!.count > 0) {
            print("SHOW: Can't switch to integrated only, because of \(String(describing: hungryProcesses))")
            return
        }
        
        IntegratedOnlyItem.state = .on
        DiscreteOnlyItem.state = .off
        DynamicSwitchingItem.state = .off
        
        _ = appDelegate?.manager.GPUMode(mode: .ForceIntergrated)
        print("NOTIFY?:  Set Force Integrated")
    }
    
    @IBAction func discreteOnlyClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .ForceDiscrete) {
            return  //already set
        }
        
        IntegratedOnlyItem.state = .off
        DiscreteOnlyItem.state = .on
        DynamicSwitchingItem.state = .off
        
        _ = appDelegate?.manager.GPUMode(mode: .ForceDiscrete)
        print("NOTIFY?:  Set Force Discrete")
    }
    
    @IBAction func dynamicSwitchingClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .SetDynamic) {
            return  //already set
        }
        
        IntegratedOnlyItem.state = .off
        DiscreteOnlyItem.state = .off
        DynamicSwitchingItem.state = .on
        
        _ = appDelegate?.manager.GPUMode(mode: .SetDynamic)
        print("NOTIFY?:  Set Dynamic")
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    
    /**
        Originally this was designed to reflect the current state selected in the menu
        but it is undoubtedly more useful when it shows the current active gpu
    */
    private func changeMenuIcon(state: SwitcherMode) {
        let icon: NSImage?
        
        switch state {
        case .ForceIntergrated:
            icon = NSImage(named: NSImage.Name(rawValue: "ic_brightness_low"))
        case .SetDynamic:
            icon = NSImage(named: NSImage.Name(rawValue: "ic_brightness_auto"))
        case .ForceDiscrete:
            icon = NSImage(named: NSImage.Name(rawValue: "ic_brightness_high"))
        }

        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    @objc private func changeGPUNameInMenu(notification: NSNotification) {
        // this function always gets called from a non-main thread
        DispatchQueue.main.async {
            guard let currentGPU = self.appDelegate?.manager.currentGPU,
                  let integratedName = self.appDelegate?.manager.integratedName
            else {
                print("Can't change gpu name in menu, Current GPU Unknown")
                return
            }
            
            self.CurrentGPU.title = "GPU: \(currentGPU)"
            
            
            /** At the same time update the stars */
            if(currentGPU == integratedName) {
                self.changeMenuIcon(state: SwitcherMode.ForceIntergrated)
            } else {
                self.changeMenuIcon(state: SwitcherMode.ForceDiscrete)
            }
        }
    }
    
    @objc private func updateProcessList(notification: NSNotification) {
        guard var hungry = notification.object as? [Process] else {
            print("Could not update process list, invalid object received")
            return
        }
        
        for item in statusMenu.items {
            if item.tag == 10 {
                statusMenu.removeItem(item)
            }
        }
        
        if hungry.count > 0 {
            Dependencies.isHidden = false
            
            if appDelegate?.manager.requestedMode == SwitcherMode.ForceIntergrated {
                Dependencies.title = "Hungry"
            } else {
                Dependencies.title = "Dependencies"
            }
            
            hungry.reverse() // because of insert
            
            for process in hungry {
                let title = "\t\(process.name) (\(process.pid))"
                let newDependency = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                newDependency.tag = 10 // so its easy to find when we delete
                statusMenu.insertItem(newDependency, at: 10)  // below the menu list name
            }
            
        } else {
            Dependencies.isHidden = true
            
            Dependencies.title = "Dependencies"
        }
    }
}
