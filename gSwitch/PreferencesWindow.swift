//
//  PreferencesWindow.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/18/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa
import ServiceManagement
import SwiftyBeaver

class PreferencesWindow: NSWindowController {
    
    let log = SwiftyBeaver.self
    
    @IBOutlet weak var toggleOpenAppLogin: NSButton!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        log.info("Preferences Opened")
        
        print(UserDefaults.standard.integer(forKey: "appLoginStart"))
        
        toggleOpenAppLogin.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: "appLoginStart"))
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func loginItemPressed(_ sender: NSButton) {
        if toggleOpenAppLogin.state.rawValue == 1 {
            if !SMLoginItemSetEnabled(Constants.launcherApplicationIdentifier as CFString, true) {
                log.error("The login item was not successfull")
                toggleOpenAppLogin.state = NSControl.StateValue(rawValue: 0)
            }
            else {
                log.info("Successfully set login item to be on")
                UserDefaults.standard.set(1, forKey: "appLoginStart")
            }
        }
        else {
            if !SMLoginItemSetEnabled(Constants.launcherApplicationIdentifier as CFString, false) {
                log.error("The login item was not successfull")
                toggleOpenAppLogin.state = NSControl.StateValue(rawValue: 1)
            }
            else {
                log.info("Successfully set login item to be off")
                UserDefaults.standard.set(0, forKey: "appLoginStart")
            }
        }
        
    }
    
}
