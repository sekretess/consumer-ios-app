//
//  IdentityKeyMode.swift
//  sekretess
//
//  Created by Atakishiyev Elnur on 14.10.25.
//

import Foundation
import SwiftData

@Model
class IdentityKeyModel {
    var identityKey: String
    var registrationId: UInt32
    
    init( identityKey: String, registrationId: UInt32) {
        self.identityKey = identityKey
        self.registrationId = registrationId
    }
    
}
