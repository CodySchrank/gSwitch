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
        
        /** I like me dam logs! <-- get it, because beavers... its swiftybeaver... sorry */
        // if i ever want to use swiftybeaver cloud logging.. probably not
        // Okn11N
        // l4T8lQbvbvtfjoOndosh6msocjxqdyrl
        // q7epzszGSDoVnimkq9ckRd9wuaCwjdVh
        let console = ConsoleDestination()
        let file = FileDestination()
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
        
        /** Default prefs so shit works */
        UserDefaults.standard.register(defaults: [Constants.GPU_CHANGE_NOTIFICATIONS : true])
        UserDefaults.standard.register(defaults: [Constants.APP_LOGIN_START : true])
        UserDefaults.standard.register(defaults: [Constants.USE_LAST_STATE: true])
        UserDefaults.standard.register(defaults: [Constants.SAVED_GPU_STATE: SwitcherMode.SetDynamic.rawValue])
        
        /** What did the beaver say to the tree?  It's been nice gnawing you.  Ok no more jokes */
        log.verbose("App Startup set as \(UserDefaults.standard.integer(forKey: Constants.APP_LOGIN_START))")
        log.verbose("Use Last State set as \(UserDefaults.standard.integer(forKey: Constants.USE_LAST_STATE))")
        log.verbose("Saved GPU State set as \(UserDefaults.standard.integer(forKey: Constants.SAVED_GPU_STATE))")
        log.verbose("GPU Change notifications set as \(UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS))")
        
        /** GPU Names are good */
        manager.setGPUNames()
        
        /** Lets listen to changes! */
        listener.listen(manager: manager, processor: processer)
        
        /** Was a mode passed in? (If there was, the last gpu state is overridden and not used) */
        for argument in CommandLine.arguments {
            switch argument {
            case "--integrated":
                log.debug("Integrated passed in")
                safeIntergratedOnly()
                break
                
            case "--discrete":
                log.debug("Discrete passed in")
                safeDiscreteOnly()
                break
                
            case "--dynamic":
                log.debug("Dynamic passed in")
                safeDynamicSwitching()
                break
                
            default:
                break
            }
        }
        
        /** Lets set last state on startup if desired */
        if(UserDefaults.standard.bool(forKey: Constants.USE_LAST_STATE)) {
            switch UserDefaults.standard.integer(forKey: Constants.SAVED_GPU_STATE) {
            case SwitcherMode.ForceDiscrete.rawValue:
                safeDiscreteOnly()
            case SwitcherMode.ForceIntergrated.rawValue:
                safeIntergratedOnly()
            case SwitcherMode.SetDynamic.rawValue:
                safeDynamicSwitching()
            default:
                break;
            }
        } else {
            if(manager.GPUMode(mode: .SetDynamic)) {
                log.info("Initially set as Dynamic!")
            }
        }
        
        /** Get current state so current gpu name exists for use in menu */
        _ = manager.CheckGPUStateAndisUsingIntegratedGPU()
        
        /** Are there any hungry processes off the bat?  Updates menu if so */
        processer.updateProcessMenuList()
        
        /** UserNotificationManager likes the gpu too */
        notifications.inject(manager: manager)
        
        /** Checks for updates if selected */
        setupUpdater()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        /** Clean up gpu change notifications */
        notifications.cleanUp()
        
        /** Lets go back to dynamic when exiting (but don't save it) */
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
        
        if(manager.GPUMode(mode: .ForceIntergrated)) {
            log.info("Set Force Integrated")
        } else {
            // only fails at this point if already integrated (not really a failure)
            log.warning("Failed to force Integrated (possibly because already on igpu, this is handled)")
        }
        
        UserDefaults.standard.set(SwitcherMode.ForceIntergrated.rawValue, forKey: Constants.SAVED_GPU_STATE)
    }
    
    public func safeDiscreteOnly() {
        if(manager.requestedMode == .ForceDiscrete) {
            return  //already set
        }
        
         statusMenu?.changeGPUButtonToCorrectState(state: .ForceDiscrete)
        
        if(manager.GPUMode(mode: .ForceDiscrete)) {
            log.info("Set Force Discrete")
        } else {
            // hopefully impossible?
            log.warning("Failed to force Discrete")
        }
        
        UserDefaults.standard.set(SwitcherMode.ForceDiscrete.rawValue, forKey: Constants.SAVED_GPU_STATE)
    }
    
    public func safeDynamicSwitching() {
        if(manager.requestedMode == .SetDynamic) {
            return  //already set
        }
        
        statusMenu?.changeGPUButtonToCorrectState(state: .SetDynamic)
        
        if(manager.GPUMode(mode: .SetDynamic)) {
            log.info("Set Dynamic Switching")
        } else {
            // hopefully impossible?
            log.warning("Failed to set Dynamic Switching")
        }
        
        UserDefaults.standard.set(SwitcherMode.SetDynamic.rawValue, forKey: Constants.SAVED_GPU_STATE)
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


