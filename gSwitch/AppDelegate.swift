//
//  AppDelegate.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var manager = GPUManager()
    var listener = GPUListener()
    var processer = ProcessManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        /**
         If we cant connect to gpu there is no point in continuing
         */
        do {
            try manager.connect()
        } catch RuntimeError.CanNotConnect(let errorMessage) {
            print(errorMessage)
            NSApplication.shared.terminate(self)
        } catch {
            print("Unkown error occured")
            NSApplication.shared.terminate(self)
        }
        
        /** Lets listen to changes! */
        listener.listen(manager: manager, processor: processer)
        
        
        /**
         TODO: Could add in ability to select mode with args here
         */
        
        
        // Lets set dynamic on startup
        //        if(manager.GPUMode(mode: .SetDynamic)) {
        //            print("Set Dynamic")
        //        } else {
        //            print("Could not set dynamic")
        //        }
        
        manager.GPUMode(mode: SwitcherMode.ForceIntergrated)
        
        processer.getHungryProcesses()
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        // Lets go back to dynamic, if not there, when exiting
        if(manager.GPUMode(mode: .SetDynamic)) {
            print("Set state to dynamic mode")
        }
        
        _ = manager.close()
    }
    
    
}

