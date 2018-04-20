//
//  PreferencesWindow.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/18/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa
import ServiceManagement

class PreferencesWindow: BossyWindow {
    @IBOutlet weak var toggleOpenAppLogin: NSButton!
    
    @IBOutlet weak var toggleGPUChangeNotifications: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        log.info("Preferences Opened")
        
        toggleOpenAppLogin.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: Constants.APP_LOGIN_START))
        
        toggleGPUChangeNotifications.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS))
    }
    
    @IBAction func gpuChangeNotificationsPressed(_ sender: NSButton) {
        let status = sender.state.rawValue
        
        log.info("Successfully set gpuChangeNotifications item to be \(status)")
        UserDefaults.standard.set(status, forKey: Constants.GPU_CHANGE_NOTIFICATIONS)
    }
    
    @IBAction func loginItemPressed(_ sender: NSButton) {
        if toggleOpenAppLogin.state.rawValue == 1 {
            if !SMLoginItemSetEnabled(Constants.launcherApplicationIdentifier as CFString, true) {
                log.error("The login item was not successfull")
                toggleOpenAppLogin.state = NSControl.StateValue(rawValue: 0)
            }
            else {
                log.info("Successfully set login item to be on")
                UserDefaults.standard.set(1, forKey: Constants.APP_LOGIN_START)
            }
        }
        else {
            if !SMLoginItemSetEnabled(Constants.launcherApplicationIdentifier as CFString, false) {
                log.error("The login item was not successfull")
                toggleOpenAppLogin.state = NSControl.StateValue(rawValue: 1)
            }
            else {
                log.info("Successfully set login item to be off")
                UserDefaults.standard.set(0, forKey: Constants.APP_LOGIN_START)
            }
        }
        
    }
    
}
