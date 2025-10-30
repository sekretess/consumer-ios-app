//
//  DatabaseWrapper.swift
//  sekretess
//
//  Created by Atakishiyev Elnur on 14.10.25.
//

import Foundation
import SwiftData
import UIKit
import AppAuthCore
import AppAuth
import OSLog
import LibSignalClient


class DatabaseWrapper{
    var modelContext: ModelContext
    
    init(modelContainer: ModelContainer){
        modelContext = ModelContext(modelContainer)
    }
    
    func restoreAuthState()->OIDAuthState?{
        let fetchDescription = FetchDescriptor<AuthStateModel>()
        do{
            let restoredAuthState = try modelContext.fetch(fetchDescription)
            let authStateBase64 = restoredAuthState.first?.authState
            os_log("fetching authState from sqlite")
            if authStateBase64 != nil{
                os_log("restoring authState")
                let authStateData = Data(base64Encoded: authStateBase64!)
                os_log("authState restored")
                return try NSKeyedUnarchiver.unarchivedObject(ofClasses: [OIDAuthState.self], from: authStateData!)as? OIDAuthState
            }
        }catch {
            os_log("error occurred")
        }
        return nil
    }
    
    func storeAuthState(authState: OIDAuthState){
        let authStateData = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
        try?modelContext.delete(model: AuthStateModel.self, where: #Predicate { _ in true})
        modelContext.insert(AuthStateModel(authState: authStateData!.base64EncodedString()))
        try?modelContext.save()
    }
    
    func storeIdentityKeyPair(identityKeyPair: IdentityKeyPair, registrationId: UInt32){
        let identityKeyPairStr = identityKeyPair.serialize().base64EncodedString()
        try?modelContext.delete(model: IdentityKeyModel.self, where: #Predicate{item in item.registrationId == registrationId})
        modelContext.insert(IdentityKeyModel(identityKey: identityKeyPairStr, registrationId: registrationId))
    }
    
    func getIdentityKeyPair()throws->IdentityKeyPair?{
        let fetchDescription = FetchDescriptor<IdentityKeyModel>()
        do{
            let restoredIdentityKeyPair = try? modelContext.fetch(fetchDescription)
            if(restoredIdentityKeyPair == nil || restoredIdentityKeyPair!.isEmpty){
                return nil
            }
            
            let identityKeyPairBase64 = restoredIdentityKeyPair?.first!.identityKey
            if identityKeyPairBase64 != nil{
                let identityKeyPairData = Data(base64Encoded: identityKeyPairBase64!)
                return try!IdentityKeyPair(bytes: identityKeyPairData!)
            }
        }
        return nil
    }
    
    func getRegistrationId()->UInt32{
        let fetcDescriptor = FetchDescriptor<IdentityKeyModel>()
        do{
            let restoredIdentityKeyPair = try? modelContext.fetch(fetcDescriptor).first!
            return restoredIdentityKeyPair!.registrationId
        }
    }
    
    func storeSignedPreKeyRecord(signedPreKeyRecord: SignedPreKeyRecord){
        let signedPreKeyRecordStr = signedPreKeyRecord.serialize().base64EncodedString()
        try?modelContext.delete(model:SignedPreKeyRecordModel.self, where: #Predicate<SignedPreKeyRecordModel>{_ in true})
        modelContext.insert(SignedPreKeyRecordModel(signedPreKey: signedPreKeyRecordStr, id: signedPreKeyRecord.id))
    }
    
    func getSignedPreKey()throws->SignedPreKeyRecord?{
        var fetDescriptor = FetchDescriptor<SignedPreKeyRecordModel>()
        fetDescriptor.predicate = #Predicate<SignedPreKeyRecordModel>{ _ in true}
        do{
            let restoredSignedPreKeyRecord = try? modelContext.fetch(fetDescriptor)
            if(restoredSignedPreKeyRecord == nil || restoredSignedPreKeyRecord!.isEmpty){
                throw SignalError.invalidKeyIdentifier("no signedPreKey with this identifier")
            }
            let signedPreKeyRecordBase64 = restoredSignedPreKeyRecord?.first?.signedPreKey
            os_log("fetching signedPreKeyRecord from sqlite")
            return try SignedPreKeyRecord(bytes: Data(base64Encoded: signedPreKeyRecordBase64!)!)
        }
    }
    
    func storeKyberPreKeyRecord(kyberPreKeyRecord : KyberPreKeyRecord){
        let kyberPreKeyRecordStr = kyberPreKeyRecord.serialize().base64EncodedString()
        modelContext.insert(KyberPreKeyRecordModel(id:kyberPreKeyRecord.id, kyberPreKeyRecord: kyberPreKeyRecordStr))
        try?modelContext.save()
    }
    
    func findKyberPreKey(id:UInt32)throws->KyberPreKeyRecord?{
        var fetchDescriptor = FetchDescriptor<KyberPreKeyRecordModel>()
        fetchDescriptor.predicate = #Predicate<KyberPreKeyRecordModel>{ item in
            item.id==id
        }
        let kyberPreKeyRecordModel  = try?modelContext.fetch(fetchDescriptor)
        if(kyberPreKeyRecordModel == nil || kyberPreKeyRecordModel!.isEmpty){
            throw SignalError.invalidKeyIdentifier("no kyber prekey with this identifier")
        }
        return try KyberPreKeyRecord(bytes: Data(base64Encoded: kyberPreKeyRecordModel!.first!.kyberPreKeyRecord)!)
    }
    
    func storePreKeyRecord(preKeyRecord: PreKeyRecord){
        let preKeyRecordStr = preKeyRecord.serialize().base64EncodedString()
        modelContext.insert(PreKeyRecordModel(id:preKeyRecord.id, prekeyRecord: preKeyRecordStr))
        try?modelContext.save()
    }
    
    func findPreKeyRecord(id:UInt32)throws-> PreKeyRecord?{
        let predicate = #Predicate<PreKeyRecordModel>{ item in
            return item.id == id
        }
        let fetchDescriptor = FetchDescriptor<PreKeyRecordModel>(predicate: predicate)
        let preKeyRecordModel = try?modelContext.fetch(fetchDescriptor)
        if(preKeyRecordModel == nil || preKeyRecordModel!.isEmpty){
            throw SignalError.invalidKeyIdentifier("no prekey with this identifier")
        }
        return try PreKeyRecord(bytes: Data(base64Encoded: preKeyRecordModel!.first!.preKeyRecord)!)
    }
    
    func findAllPreKeyRecords()->[PreKeyRecord]{
        var result: [PreKeyRecord] = []
        let predicate = #Predicate<PreKeyRecordModel>{ _ in true}
        let fetchDescriptor = FetchDescriptor<PreKeyRecordModel>(predicate: predicate)
        let preKeyRecordModels = try?modelContext.fetch(fetchDescriptor)
        preKeyRecordModels?.forEach{preKeyRecordModel in
            result.append(try!PreKeyRecord(bytes: Data(base64Encoded: preKeyRecordModel.preKeyRecord)!))
        }
        return result
    }
    
    func findAllKyberPreKeyRecordModels()->[KyberPreKeyRecordModel]?{
        return try?modelContext.fetch(FetchDescriptor<KyberPreKeyRecordModel>(predicate: #Predicate<KyberPreKeyRecordModel>{_ in true}))
    }
    
    func removePreKeyRecord(id: UInt32){
        let predicate = #Predicate<PreKeyRecordModel>{ item in
            return item.id == id
        }
        let fetchDescriptor = FetchDescriptor<PreKeyRecordModel>(predicate: predicate)
        
        do{
            let result = try?modelContext.fetch(fetchDescriptor).first
            modelContext.delete(result!)
            try?modelContext.save()
        }
    }
    
    func markKyberPreKeyUsed(id: UInt32, signedPreKeyId: UInt32,baseKey: PublicKey){
        let predicate = #Predicate<KyberPreKeyRecordModel> {item in
            return item.id == id
        }
        let fetchDescriptor = FetchDescriptor<KyberPreKeyRecordModel>(predicate: predicate)
        
        do{
            let result = try?modelContext.fetch(fetchDescriptor)
            if !result!.isEmpty{
                let kyberPreKeyRecord = result?.first
                kyberPreKeyRecord!.used = true
                kyberPreKeyRecord!.signedPreKeyId = signedPreKeyId
                kyberPreKeyRecord!.baseKey = baseKey.serialize().base64EncodedString()
                modelContext.insert(kyberPreKeyRecord!)
                try?modelContext.save()
            }
        }
    }
    
    func storeSenderKey(from sender: ProtocolAddress, distributionId: UUID, record: SenderKeyRecord){
        let serviceId:String = (sender.serviceId==nil ? sender.serviceId.serviceIdUppercaseString : "")
        let senderKeyModel = SenderKeyModel(name: sender.name, serviceId: serviceId, deviceId: sender.deviceId,
                                            distributionId: distributionId.uuidString, senderKeyRecord: record.serialize().base64EncodedString())
        modelContext.insert(senderKeyModel)
        try?modelContext.save()
    }
    
    func storeSession(from sender: ProtocolAddress, session: SessionRecord){
        let sessionModel = SessionModel(deviceId: sender.deviceId, name: sender.name, session: session.serialize().base64EncodedString())
        modelContext.insert(sessionModel)
        try?modelContext.save()
    }
    
    func findSession(from sender: ProtocolAddress)->SessionRecord{
        let name = sender.name
        let deviceId = sender.deviceId
        let predicate = #Predicate<SessionModel>{ item in
            return (item.name == name && item.deviceId == deviceId)
        }
        let fetchDescriptor = FetchDescriptor<SessionModel>(predicate:  predicate)
        let sessionRecord = try?modelContext.fetch(fetchDescriptor).first
        return try!SessionRecord(bytes: Data(base64Encoded: sessionRecord!.session)!)
    }
    
    func findSessions(from senders:[ProtocolAddress])->[SessionRecord]{
        var sessions :[SessionRecord]=[]
        for sender in senders {
            let sessionRecord = findSession(from: sender)
            sessions.append(sessionRecord)
        }
        
        return sessions
    }
    
    func findSenderKey(sender: ProtocolAddress, distributionId: String)->SenderKeyRecord?{
        let name = sender.name
        let deviceId = sender.deviceId
        
        let predicate = #Predicate<SenderKeyModel>{item in
            return (item.name == name && item.deviceId == deviceId && item.distributionId == distributionId)
        }
        let fetchDescriptor = FetchDescriptor<SenderKeyModel>(predicate:predicate)
        let senderKeyModel = try?modelContext.fetch(fetchDescriptor).first
        let senderKeyRecord = try?SenderKeyRecord(bytes: Data(base64Encoded: senderKeyModel!.senderKeyRecord)!)
        return senderKeyRecord
    }
    

    
    func clearKeys(){
        try?modelContext.delete(model: IdentityKeyModel.self, where: #Predicate<IdentityKeyModel>{_ in true})
        try?modelContext.delete(model: PreKeyRecordModel.self, where: #Predicate<PreKeyRecordModel>{ _ in true})
        try?modelContext.delete(model: KyberPreKeyRecordModel.self, where: #Predicate<KyberPreKeyRecordModel>{ _ in true})
        try?modelContext.delete(model: SignedPreKeyRecordModel.self, where: #Predicate<SignedPreKeyRecordModel>{_ in true})
    }
}
