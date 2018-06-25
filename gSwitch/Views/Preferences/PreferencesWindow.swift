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
    
    @IBOutlet weak var useLastState: NSButton!
    
    @IBOutlet weak var automaticallyUpdate: NSButton!
    
    private var advancedWindow: AdvancedWindow!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        advancedWindow = AdvancedWindow(windowNibName: NSNib.Name(rawValue: "AdvancedWindow"))
        
        log.info("Preferences Opened")
        
        toggleOpenAppLogin.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: Constants.APP_LOGIN_START))
        
        automaticallyUpdate.state = NSControl.StateValue(rawValue: (appDelegate.updater?.automaticallyChecksForUpdates)! ? 1 : 0)
        
        useLastState.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: Constants.USE_LAST_STATE))
        
        toggleGPUChangeNotifications.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS))
    }
    
    @IBAction func gpuChangeNotificationsPressed(_ sender: NSButton) {
        let status = sender.state.rawValue
        
        log.info("Successfully set gpuChangeNotifications item to be \(status == 1)")
        UserDefaults.standard.set(status, forKey: Constants.GPU_CHANGE_NOTIFICATIONS)
    }
    
    @IBAction func loginItemPressed(_ sender: NSButton) {
        if toggleOpenAppLogin.state.rawValue == 1 {
            if !SMLoginItemSetEnabled(Constants.launcherApplicationIdentifier as CFString, true) {
                log.error("The login item was not successfull")
                toggleOpenAppLogin.state = NSControl.StateValue(rawValue: 0)
            }
            else {
                log.info("Successfully set login item to be true")
                UserDefaults.standard.set(1, forKey: Constants.APP_LOGIN_START)
            }
        }
        else {
            if !SMLoginItemSetEnabled(Constants.launcherApplicationIdentifier as CFString, false) {
                log.error("The login item was not successfull")
                toggleOpenAppLogin.state = NSControl.StateValue(rawValue: 1)
            }
            else {
                log.info("Successfully set login item to be false")
                UserDefaults.standard.set(0, forKey: Constants.APP_LOGIN_START)
            }
        }
        
    }
    
    @IBAction func automaticallyUpdateClicked(_ sender: NSButton) {
        let status = sender.state.rawValue
        
        log.info("Successfully set automatically update to be \(status == 1)")
        appDelegate.updater?.automaticallyChecksForUpdates = (status == 1);
    }
    
    @IBAction func useLastStateClicked(_ sender: NSButton) {
        let status = sender.state.rawValue
        
        log.info("Successfully set useLastState item to be \(status == 1)")
        UserDefaults.standard.set(status, forKey: Constants.USE_LAST_STATE)
    }
    
    @IBAction func checkForUpdatesClicked(_ sender: NSButton) {
        appDelegate.checkForUpdates()
        log.info("Checking for updates..")
        self.window?.close()
    }
    
    @IBAction func openAdvancedPaneClicked(_ sender: NSButton) {
        advancedWindow.showWindow(nil)
        advancedWindow.pushToFront()
        self.close()
    }
}
