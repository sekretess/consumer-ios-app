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
    
    init( identityKey: String) {
        self.identityKey = identityKey
    }
    
}
