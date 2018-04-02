//
//  CustomProtocols.swift
//  botsocial
//
//  Created by Aamir  on 02/04/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import Foundation

// MARK: Handle Collector Protocol
protocol HandleCollector:class {
    var handles:Set<UInt> {get set}
    func addHandle(_ handle:UInt?)
    func clearHandles()
}

extension HandleCollector {
    func clearHandles() {
        for handle in self.handles {
            APIService.sharedInstance.cancelHandle(handle)
        }
        self.handles.removeAll()
    }
    
    func addHandle(_ handle:UInt?) {
        if let handle = handle, self.handles.contains(handle) == false {
            self.handles.insert(handle)
        }
        
    }
}
