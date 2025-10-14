//
//  PreKeyRecordModel.swift
//  sekretess
//
//  Created by Atakishiyev Elnur on 14.10.25.
//

import Foundation
import SwiftData

@Model
class PreKeyRecordModel{        
    var preKeyRecord: String
    
    init(prekeyRecord: String){
        self.preKeyRecord = prekeyRecord
    }
}
