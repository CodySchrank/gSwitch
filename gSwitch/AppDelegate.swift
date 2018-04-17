//
//  AppDelegate.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa
import SwiftyBeaver

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let manager = GPUManager()
    let listener = GPUListener()
    let processer = ProcessManager()
    let notifications = UserNotificationManager()
    let log = SwiftyBeaver.self
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {        
        /** If we cant connect to gpu there is no point in continuing */
        do {
            try manager.connect()
        } catch RuntimeError.CanNotConnect(let errorMessage) {
            log.error(errorMessage)
            NSApplication.shared.terminate(self)
        } catch {
            log.error("Unknown error occured")
            NSApplication.shared.terminate(self)
        }
        
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination()
        file.logFileURL = URL(fileURLWithPath: "swiftybeaver.log")
        log.addDestination(console)
        log.addDestination(file)
        
        /** Lets listen to changes! */
        listener.listen(manager: manager, processor: processer)
        
        /**
         TODO: Could add in ability to select mode with args here instead of hard .SetDynamic
         */
        
        /** Lets set dynamic on startup */
        if(manager.GPUMode(mode: .SetDynamic)) {
            log.info("Set Dynamic")
        } else {
            log.warning("Could not set dynamic")
        }
        
        /** Get current state so current gpu name exists for use in menu */
        _ = manager.CheckGPUStateAndisUsingIntegratedGPU()
        
        /** Are there any hungry processes off the bat?  Updates menu if so */
        processer.updateProcessMenuList()
        
        /** NotificationCenter want to check the gpu too */
        notifications.inject(manager: manager)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        /** Clean up gpu change notifications */
        notifications.cleanUp()
        
        /** Lets go back to dynamic when exiting */
        if(manager.GPUMode(mode: .SetDynamic)) {
            log.info("Set state to dynamic mode")
        }
        
        _ = manager.close()
    }
}

