//
//  GPUListener.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Foundation
import CoreGraphics

class GPUListener {
    var _notificationQueue: DispatchQueue?
    var _manager: GPUManager?
    var _processor: ProcessManager?
    
    init() {
        self._notificationQueue = DispatchQueue.init(label: Constants.NOTIFICATION_QUEUE)
    }
    
    public func listen(manager: GPUManager, processor: ProcessManager) {
        self._manager = manager
        self._processor = processor
        displayCallback()
        print("Listening")
    }
    
    private func displayCallback() {
        
        let callback: @convention(c) (_ display: UInt32, _ flags: CGDisplayChangeSummaryFlags, _ data: UnsafeMutableRawPointer?) -> Void = {
            (display, flags, data) -> Void in
            
            let this = unsafeBitCast(data, to: GPUListener.self)
            
            print("NOTIFY:  Get potential hungry processes to set in menu")
            NotificationCenter.default.post(name: .checkForHungryProcesses, object: nil)
        
            if(this._manager!.UpdateGPUStateAndisUsingIntegratedGPU() && this._manager!.requestedMode == SwitcherMode.ForceIntergrated) {
                //calls potentialGPUChange
                print("NOTIFY?: Switched from desired integrated to discrete")
            }
            
            
            if Int(flags.rawValue) & Constants.kCGDisplaySetModeFlag > 0 {
                print("Dedicated Graphics Card Called")
                _ = this._processor?.getHungryProcesses()

                this._notificationQueue?.async(execute: {
                    sleep(1)
                    
                    //calls potentialGPUChange
                    
                    let isUsingIntegrated = this._manager!.UpdateGPUStateAndisUsingIntegratedGPU()
                    let requestedMode = this._manager!.requestedMode

                    if(!isUsingIntegrated && requestedMode == SwitcherMode.ForceIntergrated) {
                        if(this._manager!.GPUMode(mode: .ForceIntergrated)) {
                            print("NOTIFY?: Forced integrated GPU From dedicated GPU")
                        }
                    }
                })
            }
        }
        
        
        CGDisplayRegisterReconfigurationCallback(callback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
    }
    
}
