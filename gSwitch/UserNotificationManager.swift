//
//  UserNotificationManager.swift
//  gSwitch
//
//  Created by Cody Schrank on 4/16/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyBeaver

class UserNotificationManager : NSObject, NSUserNotificationCenterDelegate {
    let notificationCenter = NSUserNotificationCenter.default
    let log = SwiftyBeaver.self
    
    var _manager: GPUManager?
    var lastGPU: String?
    
    var isGoingToCleanNotifications = false
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(_showNotification(notification:)), name: .probableGPUChange, object: nil)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    public func inject(manager: GPUManager) {
        _manager = manager
        
        lastGPU = manager.currentGPU
    }
    
    public func showNotification(currentGPU: String?) {
        if UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS) == 0 {
            return
        }
        
        let notification = NSUserNotification()
        notification.title = "GPU Changed"
        notification.informativeText = currentGPU ?? ""
        
        notificationCenter.deliver(notification)
        
        if !isGoingToCleanNotifications {
            log.info("Called the maid")
            
            /** Removes notifications in 15 minutes */
            Timer.scheduledTimer(timeInterval: 60 * 15, target: self, selector: #selector(cleanUp), userInfo: nil, repeats: false)
            isGoingToCleanNotifications = true
        }
    }
    
    @objc public func cleanUp() {
        log.info("CLEAN: Notifications are gross")
        notificationCenter.removeAllDeliveredNotifications()
        isGoingToCleanNotifications = false
    }
    
    @objc private func _showNotification(notification: NSNotification) {
        guard let currentGPU = notification.object as? String, let lastGPU = lastGPU else {
            return
        }
        
        print("\(currentGPU) vs \(lastGPU)")
        
        if(currentGPU != lastGPU) {
            self.lastGPU = currentGPU
            
            showNotification(currentGPU: currentGPU)
        }
    }
    
}
