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
        NotificationCenter.default.addObserver(self, selector: #selector(updateProcessMenuList(notification:)), name: .checkForHungryProcesses, object: nil)
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
    }
    
    @objc private func updateProcessMenuList(notification: NSNotification) {
        self.updateProcessMenuList()
    }
}
