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
    
    @IBOutlet weak var DiscreteOnlyItem: NSMenuItem!
    
    @IBOutlet weak var DynamicSwitchingItem: NSMenuItem!
    
    var appDelegate: AppDelegate?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        appDelegate = (NSApplication.shared.delegate as! AppDelegate) 
        
        statusItem.menu = statusMenu
        
        changeMenuIcon(state: .SetDynamic)
        
        CurrentGPU.title = "GPU: \(appDelegate?.manager.currentGPU ?? "Unkown")"
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeGPUNameInMenu(notfication:)), name: .potentialGPUChange, object: nil)
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
    }
    
    @IBAction func intergratedOnlyClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .ForceIntergrated) {
            return  //already set
        }
        
        let hungryProcesses = appDelegate?.processer.getHungryProcesses()
        
        if(hungryProcesses!.count > 0) {
            print("NOTIFY: Can't switch to integrated only, because of \(String(describing: hungryProcesses))")
            return
        }
        
        IntegratedOnlyItem.state = .on
        DiscreteOnlyItem.state = .off
        DynamicSwitchingItem.state = .off
        
        changeMenuIcon(state: .ForceIntergrated)
        _ = appDelegate?.manager.GPUMode(mode: .ForceIntergrated)
        print("NOTIFY:  Set Force Integrated")
    }
    
    @IBAction func discreteOnlyClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .ForceDiscrete) {
            return  //already set
        }
        
        IntegratedOnlyItem.state = .off
        DiscreteOnlyItem.state = .on
        DynamicSwitchingItem.state = .off
        
        changeMenuIcon(state: .ForceDiscrete)
        _ = appDelegate?.manager.GPUMode(mode: .ForceDiscrete)
        print("NOTIFY:  Set Force Discrete")
    }
    
    @IBAction func dynamicSwitchingClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .SetDynamic) {
            return  //already set
        }
        
        IntegratedOnlyItem.state = .off
        DiscreteOnlyItem.state = .off
        DynamicSwitchingItem.state = .on
        
        changeMenuIcon(state: .SetDynamic)
        _ = appDelegate?.manager.GPUMode(mode: .SetDynamic)
        print("NOTIFY:  Set Dynamic")
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @objc private func changeGPUNameInMenu(notfication: NSNotification) {
        CurrentGPU.title = "GPU: \((appDelegate?.manager.currentGPU)!)"
    }
    
    private func changeMenuIcon(state: SwitcherMode) {
        let icon: NSImage?
        
        switch state {
        case .ForceIntergrated:
            icon = NSImage(named: NSImage.Name(rawValue: "ic_star_border"))
        case .SetDynamic:
            icon = NSImage(named: NSImage.Name(rawValue: "ic_star_half"))
        case .ForceDiscrete:
            icon = NSImage(named: NSImage.Name(rawValue: "ic_star"))
        }

        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
}
