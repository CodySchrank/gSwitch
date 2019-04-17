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
    private let log = SwiftyBeaver.self
    
    private let notificationCenter = NSUserNotificationCenter.default
    
    private var _manager: GPUManager?
    private var lastGPU: String?
    
    private var isGoingToCleanNotifications = false
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(_showNotification(notification:)), name: .probableGPUChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(_showExternalDisplayNotification(notification:)), name: .externalDisplayConnect, object: nil)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    public func inject(manager: GPUManager) {
        _manager = manager
        
        lastGPU = manager.currentGPU
    }
    
    public func showExternalDisplayNotification() {
        if UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS) == 0 {
            return
        }
        
        DispatchQueue.main.async {
            sleep(3)
            
            self.log.info("Showing external display notification")
            
            let notification = NSUserNotification()
            notification.title = "External Display Connected"
            notification.informativeText = "Mode returned to Dynamic Switching"
            
            self.notificationCenter.deliver(notification)
            
            self.checkIfMaidOnTheWay()
        }
    }
    
    public func showNotification(currentGPU: String?) {
        if UserDefaults.standard.integer(forKey: Constants.GPU_CHANGE_NOTIFICATIONS) == 0 {
            return
        }
        
        log.info("Showing GPU Change Notification")
        
        let notification = NSUserNotification()
        notification.title = "GPU Changed"
        notification.informativeText = currentGPU ?? ""
        
        notificationCenter.deliver(notification)
        
        checkIfMaidOnTheWay()
    }
    
    public func cleanUp() {
        log.info("CLEAN: Notifications are gross")
        notificationCenter.removeAllDeliveredNotifications()
        isGoingToCleanNotifications = false
    }
    
    @objc private func _showExternalDisplayNotification(notification: NSNotification) {
        self.showExternalDisplayNotification()
    }
    
    @objc private func _showNotification(notification: NSNotification) {
        guard let currentGPU = notification.object as? String, let lastGPU = lastGPU else {
            return
        }
        
        if(currentGPU != lastGPU) {
            self.lastGPU = currentGPU
            
            showNotification(currentGPU: currentGPU)
        }
    }
    
    private func checkIfMaidOnTheWay() {
        if !isGoingToCleanNotifications {
            log.info("Called the maid")
            
            DispatchQueue.main.async {
                /** Removes notifications in approx 5 mins */
                self.isGoingToCleanNotifications = true
                
                Timer.scheduledTimer(withTimeInterval: 60 * 5, repeats: false, block: {
                    (Timer) in
                    self.cleanUp()
                })
            }
        }
    }
    
}
