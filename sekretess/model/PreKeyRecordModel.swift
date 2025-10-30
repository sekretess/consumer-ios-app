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
    var id: UInt32
    var preKeyRecord: String
    
    init(id: UInt32, prekeyRecord: String){
        self.id = id
        self.preKeyRecord = prekeyRecord
    }
}
