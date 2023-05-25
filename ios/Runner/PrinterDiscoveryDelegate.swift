//
//  PrinterDiscoveryDelegate.swift
//  Runner
//
//  Created by Arshad on 08/03/2023.
//

import Foundation

class PrinterDiscoveryDelegate: NSObject, Epos2DiscoveryDelegate {
    var onDiscoveryCallback: ((_ deviceInfo: Epos2DeviceInfo) -> Void)?
    var onDiscoveryCompleteCallback: ((_ devices: [Epos2DeviceInfo]) -> Void)?
    
    func onDiscovery(_ deviceInfo: Epos2DeviceInfo) {
        onDiscoveryCallback?(deviceInfo)
    }
    
    func onDiscoveryComplete(devices: [Epos2DeviceInfo]) {
        onDiscoveryCompleteCallback?(devices)
    }
}

