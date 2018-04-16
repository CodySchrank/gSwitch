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
    
    init(data: [String: Any]) {
        pid = data["pid"] as! String
        name = data["name"] as! String
    }
}

class ProcessManager {
    static var ProcessList = [Process]()
    
    public func getHungryProcesses() {
        ProcessManager.ProcessList.removeAll()
        
        let hungry = GSProcess.getTaskList()
        
        for process in hungry! {
            ProcessManager.ProcessList.append(Process(data: process as! [String : Any]))
        }
        
        for active in ProcessManager.ProcessList {
            print("Hungry process \(active.name) (\(active.pid))")
        }
    }
}
