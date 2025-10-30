//
//  KyberPreKeyRecordModel.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 14.10.25.
//

import Foundation
import SwiftData

@Model
class KyberPreKeyRecordModel{
    var id: UInt32
    var kyberPreKeyRecord: String
    var signedPreKeyId: UInt32?
    var baseKey: String?
    var used: Bool?
    
    init(id:UInt32, kyberPreKeyRecord: String,signedPreKeyId: UInt32, baseKey:String, used: Bool) {
        self.id = id
        self.kyberPreKeyRecord = kyberPreKeyRecord
        self.signedPreKeyId = signedPreKeyId
        self.baseKey = baseKey
        self.used = used
    }
    
    init(id: UInt32, kyberPreKeyRecord: String){
        self.id = id
        self.kyberPreKeyRecord = kyberPreKeyRecord
    }
}
