//
//  GPUListener.swift
//  GSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Foundation
import CoreGraphics

class GPUListener {
    static var _notificationQueue: DispatchQueue?
    static var _manager: GPUManager?
    static var _processor: ProcessManager?
    
    init() {
        GPUListener._notificationQueue = DispatchQueue.init(label: Constants.NOTIFICATION_QUEUE)
    }
    
    public func listen(manager: GPUManager, processor: ProcessManager) {
        GPUListener._manager = manager
        GPUListener._processor = processor
        displayCallback()
        print("Listening")
    }
    
    private func displayCallback() {
        CGDisplayRegisterReconfigurationCallback({
            (display: UInt32, flags: CGDisplayChangeSummaryFlags, userInfo: UnsafeMutableRawPointer?) in
            
            if Int(flags.rawValue) & Constants.kCGDisplaySetModeFlag > 0 {
                print("Dedicated Graphics Card Called")
                GPUListener._processor?.getHungryProcesses()
                
                GPUListener._notificationQueue?.async(execute: {
                    sleep(1)
                    
                    let isUsingIntegrated = GPUListener._manager!.isUsingIntegratedGPU()
                    let requestedMode = GPUListener._manager!.requestedMode
                    
                    if(!isUsingIntegrated && requestedMode == SwitcherMode.ForceIntergrated) {
                        if(GPUListener._manager!.GPUMode(mode: .ForceIntergrated)) {
                             print("Forced integrated GPU")
                        }
                    }
                })
            }
        }, nil)
    }
    
}
