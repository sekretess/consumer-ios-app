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
    
    init(signedPreKey: String) {
        self.signedPreKey = signedPreKey
    }
}
