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
import SwiftyBeaver

struct Process {
    var pid : String
    var name : String
    
    init(data: [String: String]) {
        pid = data["pid"]!
        name = data["name"]!
    }
}

class ProcessManager {
    let log = SwiftyBeaver.self
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(_updateProcessMenuList(notification:)), name: .checkForHungryProcesses, object: nil)
        
        /** Maybe poll for more useful information like vram or gpu usage? */
    }
    
    public func getHungryProcesses() -> [Process] {
        var processList = [Process]()
        
        let hungry = GSProcess.getTaskList()
        
        for process in hungry! {
            processList.append(Process(data: process as! [String : String]))
        }
        
        return processList
    }

    public func updateProcessMenuList() {
        let hungry = self.getHungryProcesses()
        
        NotificationCenter.default.post(name: .updateProcessListInMenu, object: hungry)
        log.info("UPDATE: Polling for hungry processes")
    }
    
    @objc private func _updateProcessMenuList(notification: NSNotification) {
        self.updateProcessMenuList()
    }
}
