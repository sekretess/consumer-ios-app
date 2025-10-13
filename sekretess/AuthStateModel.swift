//
//  AuthStateModel.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 12.10.25.
//

import Foundation
import SwiftData

@Model
class AuthStateModel{
    var authState: String
    
    init(authState: String) {
        self.authState = authState
    }
    
}
