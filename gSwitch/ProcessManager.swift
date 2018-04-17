//
//  ProcessManager.swift
//  GSwitch
//
//  Created by Cody Schrank on 4/15/18.
//  Copyright © 2018 CodySchrank. All rights reserved.
//

import Foundation
import AppKit
import IOKit

struct Process {
    var pid : String
    var name : String
    
    init(data: [String: String]) {
        pid = data["pid"]!
        name = data["name"]!
    }
}

class ProcessManager {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(_updateProcessMenuList(notification:)), name: .checkForHungryProcesses, object: nil)
        
        /** Only poll to clear out old gpu dependencies from menu when the gpu doesn't get switched */
        /** Maybe poll for more useful information like vram or gpu usage? */
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(_updateProcessMenuList(notification:)), userInfo: nil, repeats: true)
    }
    
    public func getHungryProcesses() -> [Process] {
        var ProcessList = [Process]()
        
        let hungry = GSProcess.getTaskList()
        
        for process in hungry! {
            ProcessList.append(Process(data: process as! [String : String]))
        }
        
        return ProcessList
    }

    public func updateProcessMenuList() {
        let hungry = self.getHungryProcesses()
        
        NotificationCenter.default.post(name: .updateProcessListInMenu, object: hungry)
        print("UPDATE: Polling for hungry processes")
    }
    
    @objc private func _updateProcessMenuList(notification: NSNotification) {
        self.updateProcessMenuList()
    }
}
