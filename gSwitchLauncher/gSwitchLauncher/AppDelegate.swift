//
//  AppDelegate.swift
//  gSwitchLauncher
//
//  Created by Cody Schrank on 4/18/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa

class Constants {
    static let KILLME = Notification.Name("killme")
    static let APP_BUNDLE = "com.CodySchrank.gSwitch"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let mainAppIdentifier = Constants.APP_BUNDLE
        let running = NSWorkspace.shared.runningApplications
        var alreadyRunning = false

        // loop through running apps - check if the Main application is running
        for app in running {
            if app.bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                break
            }
        }

        if !alreadyRunning {
            // Register for the notification killme
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.terminate), name: Constants.KILLME, object: mainAppIdentifier)

            // Get the path of the current app and navigate through them to find the Main Application
            let path = Bundle.main.bundlePath as NSString
            var components = path.pathComponents
            components.removeLast(3)
            components.append("MacOS")
            components.append("gSwitch")

            let newPath = NSString.path(withComponents: components)

            // Launch the Main application
            NSWorkspace.shared.launchApplication(newPath)
        }
        else {
            // Main application is already running
            self.terminate()
        }

    }

    @objc func terminate() {
        print("Terminate application")
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

