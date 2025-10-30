//
//  SignedPreKeyRecordModel.swift
//  sekretess
//
//  Created by Atakishiyev Elnur on 14.10.25.
//

import Foundation
import SwiftData

@Model
class SignedPreKeyRecordModel {
    
    var signedPreKey: String
    var id: UInt32
    
    init(signedPreKey: String, id: UInt32) {
        self.signedPreKey = signedPreKey
        self.id = id
    }
}
