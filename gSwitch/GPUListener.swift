//
//  GPUListener.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftyBeaver

class GPUListener {
    var _notificationQueue: DispatchQueue?
    var _manager: GPUManager?
    var _processor: ProcessManager?
    
    let log = SwiftyBeaver.self
    
    init() {
        self._notificationQueue = DispatchQueue.init(label: Constants.NOTIFICATION_QUEUE)
    }
    
    public func listen(manager: GPUManager, processor: ProcessManager) {
        self._manager = manager
        self._processor = processor
        displayCallback()
        log.info("Listening")
    }
    
    private func displayCallback() {
        let callback: @convention(c) (_ display: UInt32, _ flags: CGDisplayChangeSummaryFlags, _ data: UnsafeMutableRawPointer?) -> Void = {
            (display, flags, data) -> Void in
            
            let this = unsafeBitCast(data, to: GPUListener.self)
            
            this.log.info("NOTIFY: checkForHungryProcesses ~ for menu update")
            NotificationCenter.default.post(name: .checkForHungryProcesses, object: nil)
        
            if(this._manager!.CheckGPUStateAndisUsingIntegratedGPU() && this._manager!.requestedMode == SwitcherMode.ForceIntergrated) {
                //calls .checkGPUState
                this.log.info("NOTIFY?: Switched from desired integrated to discrete")
            }
            
            
            if Int(flags.rawValue) & Constants.kCGDisplaySetModeFlag > 0 {
                this.log.info("Dedicated Graphics Card Called")
                _ = this._processor?.getHungryProcesses()

                this._notificationQueue?.async(execute: {
                    sleep(1)
                    
                    //calls .checkGPUState
                    
                    let isUsingIntegrated = this._manager!.CheckGPUStateAndisUsingIntegratedGPU()
                    let requestedMode = this._manager!.requestedMode

                    if(!isUsingIntegrated && requestedMode == SwitcherMode.ForceIntergrated) {
                        if(this._manager!.GPUMode(mode: .ForceIntergrated)) {
                            this.log.info("NOTIFY?: Forced integrated GPU From dedicated GPU")
                        }
                    } else {
                        // usually gets called when change but sometimes gets called when no change?
                        this.log.info("NOTIFY: GPU maybe Changed")
                        NotificationCenter.default.post(name: .probableGPUChange, object: this._manager?.currentGPU)
                    }
                })
            }
        }
        
        
        CGDisplayRegisterReconfigurationCallback(callback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
    }
    
}
