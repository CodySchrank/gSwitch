//
//  GPUView.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/18/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Cocoa
import SwiftyBeaver

class GPUView: NSView {

    /**  We use a hidden view to poll for hungry processes or possibly other information like vram */
    
    let log = SwiftyBeaver.self
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func viewWillDraw() {
        log.info("Menu was opened")
        NotificationCenter.default.post(name: .checkForHungryProcesses, object: nil)
    }
    
    override func discardCursorRects() {
        log.info("Menu was closed")
    }


}
