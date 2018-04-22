//
//  AppDelegate.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa
import SwiftyBeaver
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let log = SwiftyBeaver.self
    let manager = GPUManager()
    let listener = GPUListener()
    let processer = ProcessManager()
    let notifications = UserNotificationManager()
    
    var updater: SPUUpdater?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {        
        /** Check if the launcher app is started */
        var startedAtLogin = false
        for app in NSWorkspace.shared.runningApplications {
            if app.bundleIdentifier == Constants.launcherApplicationIdentifier {
                startedAtLogin = true
            }
        }
    
        /** If the app started, post to the notification center to kill the launcher app */
        if startedAtLogin {
            DistributedNotificationCenter.default().postNotificationName(.KILLME, object: Bundle.main.bundleIdentifier, userInfo: nil, options: DistributedNotificationCenter.Options.deliverImmediately)
        }
        
        /** I like logs */
        // if i ever want to use swiftybeaver cloud logging.. probably not
        // Okn11N
        // l4T8lQbvbvtfjoOndosh6msocjxqdyrl
        // q7epzszGSDoVnimkq9ckRd9wuaCwjdVh
        let console = ConsoleDestination()
        let file = FileDestination()
        file.logFileURL = URL(fileURLWithPath: "swiftybeaver.log")  //logs to container/*/swiftybeaver.log
        log.addDestination(console)
        log.addDestination(file)
        
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
        
        /** GPU Names are good */
        manager.setGPUNames()
        
        /** Lets listen to changes! */
        listener.listen(manager: manager, processor: processer)
        
        /** Lets set dynamic on startup */
        if(manager.GPUMode(mode: .SetDynamic)) {
            log.info("Initially set as Dynamic")
        } else {
            //if it could connect but couldnt set idk if thats possible?
            //if it is possible this should quit the program here and report error
            log.error("Could not set dynamic")
        }
        
        /** Get current state so current gpu name exists for use in menu */
        _ = manager.CheckGPUStateAndisUsingIntegratedGPU()
        
        /** Are there any hungry processes off the bat?  Updates menu if so */
        processer.updateProcessMenuList()
        
        /** UserNotificationManager likes the gpu too */
        notifications.inject(manager: manager)
        
        /** Default prefs so shit works */
        UserDefaults.standard.register(defaults: [Constants.GPU_CHANGE_NOTIFICATIONS : true])
        UserDefaults.standard.register(defaults: [Constants.APP_LOGIN_START : false])
        
        log.verbose("Initial GPU Change notifications set as \(UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS))")
        log.verbose("Initial App Startup set as \(UserDefaults.standard.integer(forKey: Constants.APP_LOGIN_START))")
        
        setupUpdater()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        /** Clean up gpu change notifications */
        notifications.cleanUp()
        
        /** Lets go back to dynamic when exiting */
        if(manager.GPUMode(mode: .SetDynamic)) {
            log.info("Set state to dynamic mode")
        }
        
        _ = manager.close()
    }
    
    func checkForUpdates() {
        updater?.checkForUpdates()
    }
    
    private func setupUpdater() {
        let hostBundle = Bundle.main
        let applicationBundle = hostBundle
        var userDriver: SPUStandardUserDriverProtocol?
        userDriver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: nil)
        
        updater = SPUUpdater(hostBundle: hostBundle, applicationBundle: applicationBundle, userDriver: userDriver as! SPUUserDriver, delegate: nil)
        
        do {
            try updater?.start()
            log.info("Started updater")
        } catch {
            log.error(error)
        }
    }
}


