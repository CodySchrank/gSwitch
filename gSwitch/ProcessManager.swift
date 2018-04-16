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
        
        if(hungry.count > 0) {
            print("NOTIFY: Update gpu dependencies in menu.")
        }
        
        
    }
}
