//
//  AppDelegate.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

/** gSwitch 1.9.5 */

import Cocoa
import ServiceManagement
import SwiftyBeaver
import Sparkle
import LaunchAtLogin


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
        /** I like me dam logs! <-- get it, because beavers... its swiftybeaver... sorry */
        let console = ConsoleDestination()
        let file = FileDestination()
        log.addDestination(console)
        log.addDestination(file)
        log.verbose("gSwitch \(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)")
        
        /** If we cant connect to gpu there is no point in continuing */
        do {
            try manager.connect()
        } catch RuntimeError.CanNotConnect(let errorMessage) {
            log.error(errorMessage)
            appFailure()
        } catch {
            log.error("Unknown error occured")
            appFailure()
        }
        
        /** Default prefs so shit works */
        UserDefaults.standard.register(defaults: [Constants.GPU_CHANGE_NOTIFICATIONS : false])
        UserDefaults.standard.register(defaults: [Constants.LAUNCH_AT_LOGIN : true])
        UserDefaults.standard.register(defaults: [Constants.USE_LAST_STATE: true])
        UserDefaults.standard.register(defaults: [Constants.SAVED_GPU_STATE: SwitcherMode.SetDynamic.rawValue])
        
        /** Startup AutoLauncher */
        LaunchAtLogin.isEnabled = (UserDefaults.standard.integer(forKey: Constants.LAUNCH_AT_LOGIN) == 1)
        
        /** GPU Names are good */
        manager.setGPUNames()
        
        /** Lets listen to changes! */
        listener.listen(manager: manager, processor: processer)
        
        /** Gets the updates kicking */
        setupUpdater()
        
        /** What did the beaver say to the tree?  It's been nice gnawing you. */
        deforestation()
        
        /** Was a mode passed in? (If there was, the last gpu state is overridden and not used) */
        var arg = false;
        for argument in CommandLine.arguments {
            switch argument {
            case "--integrated":
                arg = true;
                log.debug("Integrated passed in")
                safeIntergratedOnly()
                break
                
            case "--discrete":
                arg = true;
                log.debug("Discrete passed in")
                safeDiscreteOnly()
                break
                
            case "--dynamic":
                arg = true;
                log.debug("Dynamic passed in")
                safeDynamicSwitching()
                break
                
            default:
                break
            }
        }
        
        /** Lets set last state on startup if desired (and no arg) */
        if(!arg && UserDefaults.standard.bool(forKey: Constants.USE_LAST_STATE)) {
            switch UserDefaults.standard.integer(forKey: Constants.SAVED_GPU_STATE) {
            //Checking for dependencies could offer a better start up experience here
            case SwitcherMode.ForceDiscrete.rawValue:
                safeDiscreteOnly()
            case SwitcherMode.ForceIntergrated.rawValue:
                safeIntergratedOnly()
            case SwitcherMode.SetDynamic.rawValue:
                safeDynamicSwitching()
            default:
                break;
            }
        } else if(!arg) {
            if(manager.GPUMode(mode: .SetDynamic)) {
                log.info("No default state, Initially set as Dynamic")
            }
        }
        
        /** Get current state so current gpu name exists for use in menu */
        _ = manager.CheckGPUStateAndisUsingIntegratedGPU()
        
        /** Are there any hungry processes off the bat?  Updates menu if so */
        processer.updateProcessMenuList()
        
        /** UserNotificationManager likes the manager too. Done last so that the currentGPU is updated and there are no unnessecary notifications on startup */
        notifications.inject(manager: manager)
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
    
    public func unsafeIntegratedOnly() {
        statusMenu?.changeGPUButtonToCorrectState(state: .ForceIntergrated)
        
        if(manager.GPUMode(mode: .ForceIntergrated)) {
            log.info("Set Force Integrated")
        } else {
            // only fails at this point if already integrated (not really a failure)
            log.warning("Failed to force igpu (probably because already on igpu)")
        }
        
        UserDefaults.standard.set(SwitcherMode.ForceIntergrated.rawValue, forKey: Constants.SAVED_GPU_STATE)
    }
    
    public func unsafeDiscreteOnly() {
        statusMenu?.changeGPUButtonToCorrectState(state: .ForceDiscrete)
        
        if(manager.GPUMode(mode: .ForceDiscrete)) {
            log.info("Set Force Discrete")
        } else {
            // hopefully impossible?
            log.warning("Failed to force Discrete")
        }
        
        UserDefaults.standard.set(SwitcherMode.ForceDiscrete.rawValue, forKey: Constants.SAVED_GPU_STATE)
    }
    
    public func unsafeDynamicSwitching() {
        statusMenu?.changeGPUButtonToCorrectState(state: .SetDynamic)
        
        if(manager.GPUMode(mode: .SetDynamic)) {
            log.info("Set Dynamic Switching")
        } else {
            // hopefully impossible?
            log.warning("Failed to set Dynamic Switching")
        }
        
        UserDefaults.standard.set(SwitcherMode.SetDynamic.rawValue, forKey: Constants.SAVED_GPU_STATE)
    }
    
    public func safeIntergratedOnly() {
        if(manager.requestedMode == .ForceIntergrated) {
            log.info("Already Force Integrated");
            return  //already set
        }
        
        /**
            Check for hungry processes because it could cause a crash
         */
        let hungryProcesses = processer.getHungryProcesses()
        if(hungryProcesses.count > 0) {
            log.warning("SHOW: Can't switch to integrated only, because of \(String(describing: hungryProcesses))")
            
            let alert = NSAlert.init()
            
            alert.messageText = "Warning!  Are you sure you want to change to integrated only?"
            alert.informativeText = "You currently have GPU dependencies. Changing the mode now could cause these processes to crash.  If there is currently an external display plugged in you cannot change to integrated only."

            alert.addButton(withTitle: "Do it anyway").setAccessibilityFocused(true)
            alert.addButton(withTitle: "Never mind")
            
            let modalResult = alert.runModal()
            
            switch modalResult {
            case .alertFirstButtonReturn:
                log.info("Override clicked!")
                unsafeIntegratedOnly();
            default:
                break;
            }
        } else {
            unsafeIntegratedOnly();
        }
    }
    
    public func safeDiscreteOnly() {
        if(manager.requestedMode == .ForceDiscrete) {
            log.info("Already Force Discrete");
            return  //already set
        }
        
        unsafeDiscreteOnly()
    }
    
    public func safeDynamicSwitching() {
        if(manager.requestedMode == .SetDynamic) {
            log.info("Already Dynamic");
            return  //already set
        }
        
        unsafeDynamicSwitching()
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
            
            log.info("Updater setup")
        } catch {
            log.error(error)
        }
    }
    
    /**
        Just Logging
    */
    private func deforestation() {
        log.verbose("Launch at Login set as \(UserDefaults.standard.integer(forKey: Constants.LAUNCH_AT_LOGIN) == 1)")
        
        log.verbose("Automatically update set as \(updater?.automaticallyChecksForUpdates ?? false)")
        
        log.verbose("GPU Change notifications set as \(UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS) == 1)")
        
        log.verbose("Use Last State set as \(UserDefaults.standard.integer(forKey: Constants.USE_LAST_STATE) == 1)")
        
        log.verbose("Saved GPU State set as \(UserDefaults.standard.integer(forKey: Constants.SAVED_GPU_STATE)) (\(SwitcherMode(rawValue: UserDefaults.standard.integer(forKey: Constants.SAVED_GPU_STATE))!))")
    }
    
    
    /** Warning for not finding multiple gpus */
    private func appFailure() {
        let alert = NSAlert.init()
        
        alert.messageText = "Error!  Failed to find multiple GPUs"
        alert.informativeText = "There are a few reasons this could have happened, but the most likely is that your hardware is not supported at this time.  Please notify us on the gSwitch issue page on github about your current setup and we will let you know why this happened!"
        
        alert.addButton(withTitle: "Quit").setAccessibilityFocused(true)
        alert.addButton(withTitle: "Continue Anyway (App will not function properly)")
        
        let modalResult = alert.runModal()
        
        switch modalResult {
        case .alertFirstButtonReturn:
            NSApplication.shared.terminate(self)
            break;
        default:
            break;
        }
    }
}
