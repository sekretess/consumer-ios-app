//
//  SessionModel.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 17.10.25.
//

import Foundation
import SwiftData

@Model
class SessionModel{
    var deviceId : UInt32
    var name: String
    var session: String
    
    init(deviceId: UInt32, name: String, session: String) {
        self.deviceId = deviceId
        self.name = name
        self.session = session
    }
}
