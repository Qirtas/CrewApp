//
//  ReachabilitySwift.swift
//  Productivity
//
//  Created by SPS on 13/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import UIKit
import ReachabilitySwift

protocol ReachabilityDelegate:class{
    func networkAvailable()
    func networkNotAvailable()
}

class ReachabilityManager: NSObject {
    //Boolean to track network reachability
    var isNetworkAvailable : Bool {
        return reachabilityStatus != .notReachable
    }
    
    // Tracks current NetworkStatus (notReachable, reachableViaWiFi, reachableViaWWAN)
    var reachabilityStatus: Reachability.NetworkStatus = .notReachable
    
    let reachability = Reachability()!
    
    var delegate:ReachabilityDelegate?
    
    init(delegate:ReachabilityDelegate) {
        self.delegate = delegate
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            debugPrint("Network became unreachable")
            delegate?.networkNotAvailable()
        case .reachableViaWiFi:
            debugPrint("Network reachable through WiFi")
            delegate?.networkAvailable()
        case .reachableViaWWAN:
            debugPrint("Network reachable through Cellular Data")
            delegate?.networkAvailable()
        }
    }
    
    /// Starts monitoring the network availability status
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            debugPrint("Could not start reachability notifier")
        }
    }
    
    /// Stops monitoring the network availability status
    func stopMonitoring(){
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
}

