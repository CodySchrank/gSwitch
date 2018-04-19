//
//  StatusMenuController.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa
import SwiftyBeaver

class StatusMenuController: NSViewController {
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var IntegratedOnlyItem: NSMenuItem!
    
    @IBOutlet weak var GPUViewLabel: NSMenuItem!
    
    @IBOutlet weak var Dependencies: NSMenuItem!
    
    @IBOutlet weak var DiscreteOnlyItem: NSMenuItem!
    
    @IBOutlet weak var DynamicSwitchingItem: NSMenuItem!
    
    @IBOutlet weak var CurrentGPU: NSMenuItem!
    
    @IBOutlet weak var GPUViewController: GPUView!
    
    var preferencesWindow: PreferencesWindow!
    var aboutWindow: AboutWindow!
    
    let log = SwiftyBeaver.self
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var appDelegate: AppDelegate?
    
    override func awakeFromNib() {
        appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        
        statusItem.menu = statusMenu
        GPUViewLabel.view = GPUViewController
        
        preferencesWindow = PreferencesWindow(windowNibName: NSNib.Name(rawValue: "PreferencesWindow"))
        
        aboutWindow = AboutWindow(windowNibName: NSNib.Name(rawValue: "AboutWindow"))
        
        CurrentGPU.title = "GPU: \(appDelegate?.manager.currentGPU ?? "Unknown")"
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeGPUNameInMenu(notification:)), name: .checkGPUState, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProcessList(notification:)), name: .updateProcessListInMenu, object: nil)
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func aboutClicked(_ sender: NSMenuItem) {
        aboutWindow.showWindow(nil)
    }
    
    
    @IBAction func intergratedOnlyClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .ForceIntergrated) {
            return  //already set
        }
        
        
        /** According to gfx we cant do this */
        let hungryProcesses = appDelegate?.processer.getHungryProcesses()
        if(hungryProcesses!.count > 0) {
            
            /** TODO: Instead of showing warning present window with the offending processes and the option
                        to delete them              */
            log.warning("SHOW: Can't switch to integrated only, because of \(String(describing: hungryProcesses))")
            return
        }
        
        IntegratedOnlyItem.state = .on
        DiscreteOnlyItem.state = .off
        DynamicSwitchingItem.state = .off
        
        _ = appDelegate?.manager.GPUMode(mode: .ForceIntergrated)
        log.info("NOTIFY?:  Set Force Integrated")
    }
    
    @IBAction func discreteOnlyClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .ForceDiscrete) {
            return  //already set
        }
        
        IntegratedOnlyItem.state = .off
        DiscreteOnlyItem.state = .on
        DynamicSwitchingItem.state = .off
        
        _ = appDelegate?.manager.GPUMode(mode: .ForceDiscrete)
        log.info("NOTIFY?:  Set Force Discrete")
    }
    
    @IBAction func dynamicSwitchingClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .SetDynamic) {
            return  //already set
        }
        
        IntegratedOnlyItem.state = .off
        DiscreteOnlyItem.state = .off
        DynamicSwitchingItem.state = .on
        
        _ = appDelegate?.manager.GPUMode(mode: .SetDynamic)
        log.info("NOTIFY?:  Set Dynamic")
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
    }
    
    @objc private func changeGPUNameInMenu(notification: NSNotification) {
        // this function always gets called from a non-main thread
        DispatchQueue.main.async {
            guard let currentGPU = self.appDelegate?.manager.currentGPU,
                  let integratedName = self.appDelegate?.manager.integratedName
            else {
                self.log.warning("Can't change gpu name in menu, Current GPU Unknown")
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
            log.warning("Could not update process list, invalid object received")
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
            
            let seperator = NSMenuItem.separator()
            seperator.tag = 10
            statusMenu.insertItem(seperator, at: 4)
            
            for process in hungry {
                let title = "\t\(process.name) (\(process.pid))"
                let newDependency = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                newDependency.isEnabled = false
                newDependency.tag = 10 // so its easy to find when we delete
                statusMenu.insertItem(newDependency, at: 6)  // below the menu list name
            }
            
        } else {
            Dependencies.isHidden = true
            
            Dependencies.title = "Dependencies"
        }
    }
}
