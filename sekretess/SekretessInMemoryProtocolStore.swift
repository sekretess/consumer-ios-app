//
//  SekretessInMemoryProtocolStore.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 14.10.25.
//

import Foundation
import LibSignalClient
import OSLog

class SekretessInMemoryProtocolStore: @MainActor InMemorySignalProtocolStore {

     var database: DatabaseWrapper
    
    nonisolated override init(){
        var appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.database = appDelegate.database!
        super.init()
        
    }
    
    override nonisolated init(identity: IdentityKeyPair, registrationId: UInt32) {
        var appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.database = appDelegate.database!
        super.init(identity: identity, registrationId: registrationId)
    }
    
    override nonisolated func removePreKey(id: UInt32, context: any StoreContext) throws {
        do{
            try super.removePreKey(id: id, context: context)
            if database != nil{
                database.removePreKeyRecord(id: id)
            }
        }catch{
            os_log("An error occurred: %@", type: .error, String(describing: error))

        }
    }
    
    override nonisolated func storeSenderKey(from sender: ProtocolAddress, distributionId: UUID, record: SenderKeyRecord, context: any StoreContext) throws {
        do{
           try super.storeSenderKey(from: sender, distributionId: distributionId, record: record, context: context)
            if database != nil{
                database.storeSenderKey(from: sender, distributionId: distributionId, record: record)
            }
        }catch{
            
        }
    }
    
    override nonisolated func markKyberPreKeyUsed(id: UInt32, signedPreKeyId: UInt32, baseKey: PublicKey, context: any StoreContext) throws {
        do{
            try super.markKyberPreKeyUsed(id: id, signedPreKeyId: signedPreKeyId, baseKey: baseKey, context: context)
            if database != nil{
                database.markKyberPreKeyUsed(id: id, signedPreKeyId: signedPreKeyId, baseKey:  baseKey)
            }
        }catch{
            
        }
    }
    
      func loadKyberPreKey(){
        do{
            let kyberPreKeyRecordModels = database.findAllKyberPreKeyRecordModels()
            let context = NullContext()
            try?kyberPreKeyRecordModels?.forEach{ kyberPreKeyRecordModel in
                let kyberPreKeyRecord = try?KyberPreKeyRecord(bytes: Data(base64Encoded: kyberPreKeyRecordModel.kyberPreKeyRecord)!)
                try super.storeKyberPreKey(kyberPreKeyRecord!, id: kyberPreKeyRecord!.id, context: context)
                
                if (kyberPreKeyRecordModel.used != nil && kyberPreKeyRecordModel.used!){
                    try super.markKyberPreKeyUsed(id: kyberPreKeyRecord!.id, signedPreKeyId: kyberPreKeyRecordModel.signedPreKeyId!,
                                                  baseKey: PublicKey(Data(base64Encoded: kyberPreKeyRecordModel.baseKey!)!), context: context)
                }
            }
        }catch{
            
        }
    }
}
