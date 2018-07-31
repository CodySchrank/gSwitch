//
//  AboutWindow.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/18/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa

class AboutWindow: BossyWindow {
    @IBOutlet weak var aboutText: NSTextField!
    
    private let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        log.info("About Opened")
        
        aboutText.stringValue = "gSwitch \(version)"
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(self)
        self.window?.orderedIndex = 0
        NSApp.activate(ignoringOtherApps: true)
    }
}
