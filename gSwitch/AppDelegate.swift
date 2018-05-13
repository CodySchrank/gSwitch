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
    var updaterDelegate: UpdaterDelegate?
    var statusMenu: StatusMenuController?
    
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
        file.logFileURL = URL(fileURLWithPath: "swiftybeaver.log")
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
        
        
        //TODO: if else command line or desired state (default dynamic)
        
        /** Lets set dynamic on startup regardless of desired state */
        if(manager.GPUMode(mode: .SetDynamic)) {
            log.info("Initially set as Dynamic!")
        }
        
        /** Was a mode passed in? */
        for argument in CommandLine.arguments {
            switch argument {
            case "--integrated":
                log.info("Integrated passed in")
                safeIntergratedOnly()
                break
                
            case "--discrete":
                log.info("Discrete passed in")
                safeDiscreteOnly()
                break
                
            default:
                break
            }
        }
        
        /** Get current state so current gpu name exists for use in menu */
        _ = manager.CheckGPUStateAndisUsingIntegratedGPU()
        
        /** Are there any hungry processes off the bat?  Updates menu if so */
        processer.updateProcessMenuList()
        
        /** UserNotificationManager likes the gpu too */
        notifications.inject(manager: manager)
        
        /** Default prefs so shit works */
        UserDefaults.standard.register(defaults: [Constants.GPU_CHANGE_NOTIFICATIONS : true])
        UserDefaults.standard.register(defaults: [Constants.APP_LOGIN_START : true])
        
        /** What did the beaver say to the tree?  It's been nice gnawing you. */
        log.verbose("Initial GPU Change notifications set as \(UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS))")
        log.verbose("Initial App Startup set as \(UserDefaults.standard.integer(forKey: Constants.APP_LOGIN_START))")
        
        /** Checks for updates if selected */
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
    
    public func safeIntergratedOnly() {
        if(manager.requestedMode == .ForceIntergrated) {
            return  //already set
        }
        
        /** According to gfx we cant do this. Further testing needed */
        let hungryProcesses = processer.getHungryProcesses()
        if(hungryProcesses.count > 0) {
            log.warning("SHOW: Can't switch to integrated only, because of \(String(describing: hungryProcesses))")
            
            let alert = NSAlert.init()
            alert.messageText = "Cannot change to Integrated Only"
            alert.informativeText = "You have GPU Dependencies"
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
            return
        }
        
        statusMenu?.changeGPUButtonToCorrectState(state: .ForceIntergrated)
        
        _ = manager.GPUMode(mode: .ForceIntergrated)
        log.info("Set Force Integrated")
    }
    
    public func safeDiscreteOnly() {
        if(manager.requestedMode == .ForceDiscrete) {
            return  //already set
        }
        
         statusMenu?.changeGPUButtonToCorrectState(state: .ForceDiscrete)
        
        _ = manager.GPUMode(mode: .ForceDiscrete)
        log.info("Set Force Discrete")
    }
    
    public func safeDynamicSwitching() {
        if(manager.requestedMode == .SetDynamic) {
            return  //already set
        }
        
        statusMenu?.changeGPUButtonToCorrectState(state: .SetDynamic)
        
        _ = manager.GPUMode(mode: .SetDynamic)
        log.info("Set Dynamic")
    }
    
    public func checkForUpdates() {
        updater?.checkForUpdates()
    }
    
    private func setupUpdater() {
        let hostBundle = Bundle.main
        let applicationBundle = hostBundle
        var userDriver: SPUStandardUserDriverProtocol?
        userDriver = SPUStandardUserDriver(hostBundle: hostBundle, delegate: nil)
        
        updaterDelegate = UpdaterDelegate()
        
        updater = SPUUpdater(hostBundle: hostBundle, applicationBundle: applicationBundle, userDriver: userDriver as! SPUUserDriver, delegate: updaterDelegate)
        
        do {
            try updater?.start()
            log.info("Started updater")
        } catch {
            log.error(error)
        }
    }
}


