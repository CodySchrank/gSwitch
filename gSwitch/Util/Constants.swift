//
//  Constants.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/14/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//
//  GPUState, DispatchSelectors, and Features are from gfxCardStatus
//  Copyright (c) 2010-2012, Cody Krieger
//  All rights reserved.
//

import Foundation

enum GPUState : Int {
    case
    // get: returns a uint64_t with bits set according to FeatureInfos, 1=enabled
    DisableFeatureORFeatureInfo        = 0,
    
    // get: same as FeatureInfo
    EnableFeatureORFeatureInfo2        = 1,
    
    // set: force Graphics Switch regardless of switching mode
    // get: always returns 0xdeadbeef
    ForceSwitch                        = 2,
    
    // set: power down a gpu, pretty useless since you can't power down the igp and the dedicated gpu is powered down automatically
    // get: maybe returns powered on graphics cards, 0x8 = integrated, 0x88 = discrete (or probably both, since integrated never gets powered down?)
    PowerGPU                           = 3,
    
    // set/get: Dynamic Switching on/off with [2] = 0/1
    GpuSelect                          = 4,
    
    // set: 0 = dynamic switching, 2 = no dynamic switching, exactly like older mbp switching, 3 = no dynamic stuck, others unsupported
    // get: possibly inverted?
    SwitchPolicy                       = 5,
    
    // get: always 0xdeadbeef
    Unknown                            = 6,
    
    // get: returns active graphics card
    GraphicsCard                       = 7,
    
    // get: sometimes 0xffffffff, TODO: figure out what that means
    Unknown2                           = 8
}

enum DispatchSelectors: Int {
    case
    kOpen = 0,
    kClose,
    kSetMuxState,
    kGetMuxState,
    kSetExclusive,
    kDumpState,
    kUploadEDID,
    kGetAGCData,
    kGetAGCData_log1,
    kGetAGCData_log2,
    kNumberOfMethods
};

enum GPU_INT: Int {
    case
    Discrete = 0,
    Integrated
}

enum SwitcherMode: Int {
    case
    ForceIntergrated,
    ForceDiscrete,
    SetDynamic
}

enum Features: Int {
    case
    Policy = 0,
    Auto_PowerDown_GPU,
    Dynamic_Switching,
    GPU_Powerpolling, // Inverted: Disable Feature enables it and vice versa
    Defer_Policy,
    Synchronous_Launch,
    Backlight_Control = 8,
    Recovery_Timeouts,
    Power_Switch_Debounce,
    Logging = 16,
    Display_Capture_Switch,
    No_GL_HDA_busy_idle_registration,
    muxFeaturesCount
}

enum RuntimeError: Error {
    case CanNotConnect(String)
}

struct Constants {
    static let IO_PCI_DEVICE = "IOPCIDevice"
    static let IO_NAME_KEY = "IOName"
    static let DISPLAY_KEY = "display"
    static let MODEL_KEY = "model"
    static let INTEL_GPU_PREFIX = "Intel"
    static let LEGACY_2009_DISCRETE_GPU = "NVIDIA GeForce 9600M GT"
    static let LEGACY_2010_DISCRETE_GPU = "NVIDIA GeForce GT 330M"
    static let LEGACY = [Constants.LEGACY_2009_DISCRETE_GPU, Constants.LEGACY_2010_DISCRETE_GPU]
    static let GRAPHICS_CONTROL = "AppleGraphicsControl"
    static let NOTIFICATION_QUEUE = "com.CodySchrank.GSwitch.GPUChangeNotificationQueue"
    static let kCGDisplaySetModeFlag = (1 << 3)
    static let kCGDisplayAddFlag = (1 << 4)
    static let kCGDisplayRemoveFlag = (1 << 5)
    static let launcherApplicationIdentifier = "com.CodySchrank.gSwitchLauncher"
    static let GPU_CHANGE_NOTIFICATIONS = "gpuChangeNotifications"
    static let APP_LOGIN_START = "appLoginStart"
    static let USE_LAST_STATE = "useLastState"
    static let SAVED_GPU_STATE = "savedGPUState"
    static let STATUS_MENU_DEPENDENCY_APPEND_INDEX = 5
    static let STATUS_MENU_DEPENDENCY_TAG = 10
    static let HELP_URL = "https://codyschrank.github.io/gSwitch/#faq"
}

extension Notification.Name {
    static let checkGPUState = Notification.Name("checkGPUState")
    static let checkForHungryProcesses = Notification.Name("checkForHungryProcesses")
    static let updateProcessListInMenu = Notification.Name("updateProcessListInMenu")
    static let probableGPUChange = Notification.Name("probableGPUChange")
    static let externalDisplayConnect = Notification.Name("externalDisplayConnect")
    static let startPolling = Notification.Name("startPolling")
    static let stopPolling = Notification.Name("stopPolling")
    static let killLauncher = Notification.Name("killLauncher")
}

