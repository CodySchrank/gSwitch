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
    var _manager: GPUManager?
    
    var lastGPU: String?
    
    let log = SwiftyBeaver.self
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(_showNotification(notification:)), name: .probableGPUChange, object: nil)
        
        /** Removes notifications approx every 5 minutes */
        Timer.scheduledTimer(timeInterval: 60 * 5, target: self, selector: #selector(cleanUp), userInfo: nil, repeats: true)
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
        let notification = NSUserNotification()
        notification.title = "GPU Changed"
        notification.informativeText = currentGPU ?? ""
        
        // Manually display the notification
        notificationCenter.deliver(notification)
    }
    
    @objc public func cleanUp() {
        log.info("CLEAN: Notifications are gross")
        notificationCenter.removeAllDeliveredNotifications()
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
