//
//  StatusMenuController.swift
//  GSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        statusItem.menu = statusMenu
        
        let icon = NSImage(named: NSImage.Name(rawValue: "ic_star_half"))
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
