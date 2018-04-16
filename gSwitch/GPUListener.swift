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
            
            print("Get hungry processes to set in menu")
        
            if(this._manager!.isUsingDedicatedGPU() && this._manager!.requestedMode == SwitcherMode.ForceIntergrated) {
                //call potentialGPUChange
                print("NOTIFY: Switched from desired integrated to discrete")
            }
            
            
            if Int(flags.rawValue) & Constants.kCGDisplaySetModeFlag > 0 {
                print("Dedicated Graphics Card Called")
                _ = this._processor?.getHungryProcesses()

                this._notificationQueue?.async(execute: {
                    sleep(1)

                    let isUsingIntegrated = this._manager!.isUsingIntegratedGPU()
                    let requestedMode = this._manager!.requestedMode

                    if(!isUsingIntegrated && requestedMode == SwitcherMode.ForceIntergrated) {
                        if(this._manager!.GPUMode(mode: .ForceIntergrated)) {
                            //call potentialGPUChange (forced)
                            print("NOTIFY: Forced integrated GPU From dedicated GPU")
                        }
                    } else {
                        //call potentialGPUChange
                        print("NOTIFY: current gpu name")
                    }
                })
            }
        }
        
        
        CGDisplayRegisterReconfigurationCallback(callback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
    }
    
}
