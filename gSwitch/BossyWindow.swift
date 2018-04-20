//
//  BossyWindow.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/19/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa
import Foundation
import SwiftyBeaver

class BossyWindow: NSWindowController {
    internal let log = SwiftyBeaver.self
    
    public func pushToFront() {
        self.window?.center()
        self.window?.makeKeyAndOrderFront(self)
        self.window?.orderedIndex = 0
        NSApp.activate(ignoringOtherApps: true)
    }
}
