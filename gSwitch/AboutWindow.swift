//
//  AboutWindow.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/18/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa
import SwiftyBeaver

class AboutWindow: NSWindowController {
    
    let log = SwiftyBeaver.self

    override func windowDidLoad() {
        super.windowDidLoad()

        log.info("About Opened")
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
