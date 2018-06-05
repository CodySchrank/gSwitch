//
//  GPUManager.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/14/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//
//  some logic is from gfxCardStatus
//  https://github.com/codykrieger/gfxCardStatus/blob/master/LICENSE @ Jun 17, 2012
//  Copyright (c) 2010-2012, Cody Krieger
//  All rights reserved.
//

import Foundation
import IOKit
import SwiftyBeaver

class GPUManager {
    private let log = SwiftyBeaver.self
    
    public var integratedName: String?
    public var discreteName: String?
    public var currentGPU: String?
    public var requestedMode: SwitcherMode?
    
    private var _connect: io_connect_t = IO_OBJECT_NULL;
    
    public func setGPUNames() {
        let gpus = getGpuNames()
        
        /**
         This only works if there are exactly 2 gpus
         and the integrated one is intel and the discrete
         one is not intel (AMD or NVIDIA).
         
         If apple changes the status quo this will break
         */
        for gpu in gpus {
            if gpu.hasPrefix(Constants.INTEL_GPU_PREFIX) {
                self.integratedName = gpu
            } else {
                self.discreteName = gpu
            }
        }
        
        log.verbose("Integrated: \(integratedName ?? "Unknown")")
        log.verbose("Discrete: \(discreteName ?? "Unknown")")
    }
    
    public func connect() throws {
        var kernResult: kern_return_t = 0
        var service: io_service_t = IO_OBJECT_NULL
        var iterator: io_iterator_t = 0
        
        kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(Constants.GRAPHICS_CONTROL), &iterator);
        
        if kernResult != KERN_SUCCESS {
            throw RuntimeError.CanNotConnect("IOServiceGetMatchingServices returned \(kernResult)")
        }
        
        service = IOIteratorNext(iterator);
        IOObjectRelease(iterator);
        
        if service == IO_OBJECT_NULL {
            throw RuntimeError.CanNotConnect("No matching drivers found.");
        }
        
        kernResult = IOServiceOpen(service, mach_task_self_, 0, &self._connect);
        if kernResult != KERN_SUCCESS {
            throw RuntimeError.CanNotConnect("IOServiceOpen returned \(kernResult)");
        }
        
        kernResult = IOConnectCallScalarMethod(self._connect, UInt32(DispatchSelectors.kOpen.rawValue), nil, 0, nil, nil);
        if kernResult != KERN_SUCCESS {
            throw RuntimeError.CanNotConnect("IOConnectCallScalarMethod returned \(kernResult)")
        }
        
        log.info("Successfully connected")
    }
    
    public func close() -> Bool {
        var kernResult: kern_return_t = 0
        if self._connect == IO_OBJECT_NULL {
            return true;
        }
        
        kernResult = IOConnectCallScalarMethod(self._connect, UInt32(DispatchSelectors.kClose.rawValue), nil, 0, nil, nil);
        if kernResult != KERN_SUCCESS {
            log.error("IOConnectCallScalarMethod returned \(kernResult)")
            return false
        }
        
        kernResult = IOServiceClose(self._connect);
        if kernResult != KERN_SUCCESS {
            log.error("IOServiceClose returned \(kernResult)")
            return false
        }
        
        self._connect = IO_OBJECT_NULL
        log.info("Driver Connection Closed")
        
        return true
    }
    
    public func GPUMode(mode: SwitcherMode) -> Bool {
        let connect = self._connect
        
        requestedMode = mode
        
        var status = false
        
        if connect == IO_OBJECT_NULL {
            return status
        }
        
        switch mode {
        case .ForceIntergrated:
            let integrated = CheckGPUStateAndisUsingIntegratedGPU()
            log.info("Requesting integrated, are we integrated?  \(integrated)")
            
            if !integrated {
                status = SwitchGPU(connect: connect)
            }
            
        case .ForceDiscrete:
            log.info("Requesting discrete")
            
            /** Essientialy ticks and unticks the box in system prefs, which by design forces discrete */
            
            _ = setFeatureInfo(connect: connect, feature: Features.Policy, enabled: true)
            _ = setSwitchPolicy(connect: connect)
            
            status = setDynamicSwitching(connect: connect, enabled: true)
            
            // give the gpu a second to switch
            sleep(1)
            
            status = setDynamicSwitching(connect: connect, enabled: false)
        case .SetDynamic:
            log.info("Requesting Dynamic")
            
            /** Set switch policy back, makes it think its on auto switching */
            _ = setFeatureInfo(connect: connect, feature: Features.Policy, enabled: true)
            _ = setSwitchPolicy(connect: connect)
            
            status = setDynamicSwitching(connect: connect, enabled: true)
        }
        
        return status
    }
    
    public func resolveGPUName(gpu: GPU_INT) -> String? {
        return gpu == .Integrated ? self.integratedName : self.discreteName
    }
    
    /**
        We should never assume gpu state that is why we always check.
        Anytime we get state of gpu we might as well:
     
        Change the active name
        NOTIFY checkGPUState in case it changed
        return whether we are integrated or discrete
    */
    public func CheckGPUStateAndisUsingIntegratedGPU() -> Bool {
        if self._connect == IO_OBJECT_NULL {
            log.error("Lost connection to gpu")
            return false  //probably need to throw or exit if lost connection?
        }
        
        let gpu = getGPUState(connect: self._connect, input: GPUState.GraphicsCard)
        
        NotificationCenter.default.post(name: .checkGPUState, object: gpu)
        log.info("NOTIFY: checkGPUState ~ Checking GPU...")
        
        return gpu == .Integrated
    }
    
    /**
        Kind of a misnomer because it only sets it to integrated (this is what its called for kernal mux)
        ie. switch back from discrete (used to force integrated)
     */
    private func SwitchGPU(connect: io_connect_t) -> Bool {
        let _ = setDynamicSwitching(connect: connect, enabled: false)
        
        sleep(1);
        
        return setGPUState(connect: connect, state: GPUState.ForceSwitch, arg: 0)
    }
    
    private func setGPUState(connect: io_connect_t ,state: GPUState, arg: UInt64) -> Bool {
        var kernResult: kern_return_t = 0
        
        let scalar: [UInt64] = [ 1, UInt64(state.rawValue), arg ];
        
        kernResult = IOConnectCallScalarMethod(
            // an io_connect_t returned from IOServiceOpen().
            connect,
            
            // selector of the function to be called via the user client.
            UInt32(DispatchSelectors.kSetMuxState.rawValue),
            
            // array of scalar (64-bit) input values.
            scalar,
            
            // the number of scalar input values.
            3,
            
            // array of scalar (64-bit) output values.
            nil,
            
            // pointer to the number of scalar output values.
            nil
        );

        if kernResult == KERN_SUCCESS {
            log.verbose("Modified state with \(state)")
        } else {
            log.error("ERROR: Set state returned \(kernResult)")
        }
            
        return kernResult == KERN_SUCCESS
    }
    
    private func getGPUState(connect: io_connect_t, input: GPUState) -> GPU_INT {
        var kernResult: kern_return_t = 0
        let scalar: [UInt64] = [ 1, UInt64(input.rawValue) ];
        var output: UInt64 = 0
        var outputCount: UInt32 = 1
        
        kernResult = IOConnectCallScalarMethod(
            // an io_connect_t returned from IOServiceOpen().
            connect,
            
            // selector of the function to be called via the user client.
            UInt32(DispatchSelectors.kGetMuxState.rawValue),
            
            // array of scalar (64-bit) input values.
            scalar,
            
            // the number of scalar input values.
            2,
            
            // array of scalar (64-bit) output values.
            &output,
            
            // pointer to the number of scalar output values.
            &outputCount
        );
        
        if kernResult == KERN_SUCCESS {
            log.verbose("Successfully got state, count \(outputCount), value \(output)")
        } else {
            log.error("ERROR: Get state returned \(kernResult)")
        }
        
        return GPU_INT(rawValue: Int(output))!
    }
    
    private func setFeatureInfo(connect: io_connect_t, feature: Features, enabled: Bool) -> Bool {
        return setGPUState(
            connect: connect,
            state: enabled ? GPUState.EnableFeatureORFeatureInfo2 : GPUState.DisableFeatureORFeatureInfo,
            arg: 1 << feature.rawValue)
    }
    
    private func setSwitchPolicy(connect: io_connect_t, dynamic: Bool = true) -> Bool {
        /** dynamic = 0: instant switching, dynamic = 2: user needs to logout before switching */
        return setGPUState(connect: connect, state: GPUState.SwitchPolicy, arg: dynamic ? 0 : 2)
    }
    
    private func setDynamicSwitching(connect: io_connect_t, enabled: Bool) -> Bool {
        return setGPUState(connect: connect, state: GPUState.GpuSelect, arg: enabled ? 1 : 0);
    }
    
    private func getGpuNames() -> [String] {
        let ioProvider = IOServiceMatching(Constants.IO_PCI_DEVICE)
        var iterator: io_iterator_t = 0
        
        var gpus = [String]()
        
        if(IOServiceGetMatchingServices(kIOMasterPortDefault, ioProvider, &iterator) == kIOReturnSuccess) {
            var device: io_registry_entry_t = 0
            
            repeat {
                device = IOIteratorNext(iterator)
                var serviceDictionary: Unmanaged<CFMutableDictionary>?;
                
                if (IORegistryEntryCreateCFProperties(device, &serviceDictionary, kCFAllocatorDefault, 0) != kIOReturnSuccess) {
                    // Couldn't get the properties
                    IOObjectRelease(device)
                    continue;
                }
                
                if let props = serviceDictionary {
                    let dict = props.takeRetainedValue() as NSDictionary
                    
                    if let d = dict.object(forKey: Constants.IO_NAME_KEY) as? String {
                        if d == Constants.DISPLAY_KEY {
                            let model = dict.object(forKey: Constants.MODEL_KEY) as! Data
                            gpus.append(String(data: model, encoding: .ascii)!)
                        }
                    }
                }
            } while (device != 0)
        }
        
        return gpus
    }
    
}


