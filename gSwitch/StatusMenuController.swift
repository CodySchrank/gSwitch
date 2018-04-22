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
    
    private var preferencesWindow: PreferencesWindow!
    private var aboutWindow: AboutWindow!
    
    private let log = SwiftyBeaver.self
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private var appDelegate: AppDelegate?
    
    override func awakeFromNib() {
        appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        
        statusItem.menu = statusMenu
        GPUViewLabel.view = GPUViewController  // hidden view
        
        preferencesWindow = PreferencesWindow(windowNibName: NSNib.Name(rawValue: "PreferencesWindow"))
        
        aboutWindow = AboutWindow(windowNibName: NSNib.Name(rawValue: "AboutWindow"))
        
        CurrentGPU.title = "GPU: \(appDelegate?.manager.currentGPU ?? "Unknown")"
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeGPUNameInMenu(notification:)), name: .checkGPUState, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProcessList(notification:)), name: .updateProcessListInMenu, object: nil)
    }
    
    @IBAction func helpClicked(_ sender: NSMenuItem) {
        if let url = URL(string: Constants.HELP_URL), NSWorkspace.shared.open(url) {
            log.info("Opened help")
        }
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
        preferencesWindow.pushToFront()
    }
    
    @IBAction func aboutClicked(_ sender: NSMenuItem) {
        aboutWindow.showWindow(nil)
        aboutWindow.pushToFront()
    }
    
    @IBAction func intergratedOnlyClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .ForceIntergrated) {
            return  //already set
        }
        
        /** According to gfx we cant do this.  Idk in testing it seems like I can do force it.
            How do i find out if the dgpu is still on? */
        let hungryProcesses = appDelegate?.processer.getHungryProcesses()
        if(hungryProcesses!.count > 0) {
            log.warning("SHOW: Can't switch to integrated only, because of \(String(describing: hungryProcesses))")
            
            let alert = NSAlert.init()
            alert.messageText = "Cannot change to Integrated Only"
            alert.informativeText = "You have GPU Dependencies"
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
            return
        }
        
        changeGPUButtonToCorrectState(state: .ForceIntergrated)
        
        _ = appDelegate?.manager.GPUMode(mode: .ForceIntergrated)
        log.info("NOTIFY?:  Set Force Integrated")
    }
    
    @IBAction func discreteOnlyClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .ForceDiscrete) {
            return  //already set
        }
        
        changeGPUButtonToCorrectState(state: .ForceDiscrete)
        
        _ = appDelegate?.manager.GPUMode(mode: .ForceDiscrete)
        log.info("NOTIFY?:  Set Force Discrete")
    }
    
    @IBAction func dynamicSwitchingClicked(_ sender: NSMenuItem) {
        if(appDelegate?.manager.requestedMode == .SetDynamic) {
            return  //already set
        }
        
        changeGPUButtonToCorrectState(state: .SetDynamic)
        
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
        
        // get rid of old dependencies
        for item in statusMenu.items {
            if item.tag == Constants.STATUS_MENU_DEPENDENCY_TAG {
                statusMenu.removeItem(item)
            }
        }
        
        for process in hungry {
            if process.name.contains("External Display")
                && appDelegate?.manager.requestedMode != SwitcherMode.SetDynamic {
                
                if (appDelegate?.manager.GPUMode(mode: SwitcherMode.SetDynamic))! {
                    log.warning("External display connected, going back to dynamic")
                    
                    NotificationCenter.default.post(name: .externalDisplayConnect, object: nil)
                    
                    changeGPUButtonToCorrectState(state: .SetDynamic)
                    return
                }
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
            seperator.tag = Constants.STATUS_MENU_DEPENDENCY_TAG
            statusMenu.insertItem(seperator, at: Constants.STATUS_MENU_DEPENDENCY_APPEND_INDEX)
            
            for process in hungry {
                var title = "\t\(process.name)"
                if process.pid != "" {
                    title += " (\(process.pid))"
                }
                let newDependency = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                newDependency.isEnabled = false
                newDependency.tag = Constants.STATUS_MENU_DEPENDENCY_TAG
                statusMenu.insertItem(newDependency, at: Constants.STATUS_MENU_DEPENDENCY_APPEND_INDEX + 2)
            }
            
        } else {
            Dependencies.isHidden = true
            
            Dependencies.title = "Dependencies"
        }
    }
    
    private func changeGPUButtonToCorrectState(state: SwitcherMode) {
        switch state {
        case .ForceIntergrated:
            IntegratedOnlyItem.state = .on
            DynamicSwitchingItem.state = .off
            DiscreteOnlyItem.state = .off
        
        case .SetDynamic:
            IntegratedOnlyItem.state = .off
            DynamicSwitchingItem.state = .on
            DiscreteOnlyItem.state = .off

        case .ForceDiscrete:
            IntegratedOnlyItem.state = .off
            DynamicSwitchingItem.state = .off
            DiscreteOnlyItem.state = .on
        }
    }
    
    
}
