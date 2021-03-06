//
//  Network.swift
//  TawkDemo
//
//  Created by Sanjay Thakkar on 05/03/21.
//

import Foundation
import Network


class NetworkManager
{
    static var shared = NetworkManager()
    let monitor = NWPathMonitor()
    var currentReachableStatus = false
    func startMonitoring( reachable:@escaping (Bool)->Void)
    {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.currentReachableStatus = true
                reachable(true)
            } else {
                self.currentReachableStatus = false
                reachable(false)
            }
            print(path.isExpensive)
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
}
