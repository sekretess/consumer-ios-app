//
//  SenderKeyModel.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 16.10.25.
//

import Foundation
import SwiftData


@Model
class SenderKeyModel{
    var name: String
    var serviceId: String
    var deviceId : UInt32
    var distributionId: String
    var senderKeyRecord: String
    
    init(name: String, serviceId: String, deviceId: UInt32, distributionId: String, senderKeyRecord: String) {
        self.name = name
        self.serviceId = serviceId
        self.deviceId = deviceId
        self.distributionId = distributionId
        self.senderKeyRecord = senderKeyRecord
    }
}
