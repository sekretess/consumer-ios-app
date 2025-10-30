//
//  SignalProtocol.swift
//  sekretess
//
//  Created by Atakishiyev Elnur on 13.10.25.
//

import Foundation
import LibSignalClient
import SwiftData
import OSLog
import AppAuth
import AppAuthCore


class SignalProtocol{
    var sekretessInMemorySignalStore: SekretessInMemoryProtocolStore?;
    var database: DatabaseWrapper
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    init(){
        self.database = appDelegate.database!
        tryRestore()
    }
    
    private func generateKyberPreKeyRecord(count: Int)->[KyberPreKeyRecord]{
        var kyberPreKeyRecords: [KyberPreKeyRecord] = []
        for i in 0..<count + 1{
            let id = UInt32.random(in: 0...UInt32.max)
            let privateKey = PrivateKey.generate()
            let keyPair = KEMKeyPair.generate()
            let kyberPreKeyRecord = try?KyberPreKeyRecord(id: id, timestamp: UInt64(Date.timeIntervalSinceReferenceDate),
                                                          keyPair: keyPair, signature: privateKey.generateSignature(message: privateKey.publicKey.serialize()))
            try?sekretessInMemorySignalStore?.storeKyberPreKey(kyberPreKeyRecord!, id: kyberPreKeyRecord!.id, context: NullContext())
            kyberPreKeyRecords.append(kyberPreKeyRecord!)
        }
        return kyberPreKeyRecords
    }
    
    private func generatePreKey(count: Int)->[PreKeyRecord]{
        var preKeyRecords:[PreKeyRecord] = []
        for i in 0..<count{
            let privateKey = PrivateKey.generate()
            let preKeyRecord = try? PreKeyRecord(id: UInt32(i), publicKey: privateKey.publicKey,privateKey: privateKey)
            try?sekretessInMemorySignalStore?.storePreKey(preKeyRecord!, id: preKeyRecord!.id, context: NullContext())
            preKeyRecords.append(preKeyRecord!)
        }
        return preKeyRecords
    }
    
    private func tryRestore(){
        let identityKeyPair = try?database.getIdentityKeyPair()
        if identityKeyPair == nil{
            initializeNew()
        }else{
            restoreCryptKeys()
        }
    }
    
    private func restoreCryptKeys(){
        let registrationId = database.getRegistrationId()
        let identityKeyPair = try?database.getIdentityKeyPair()
        //Restore identityKeyPair
        sekretessInMemorySignalStore = SekretessInMemoryProtocolStore(identity: identityKeyPair!, registrationId: registrationId)
        
        //Restore signed pre key
        let signedPreKey = try?database.getSignedPreKey()
        try?sekretessInMemorySignalStore?.storeSignedPreKey(signedPreKey!, id: signedPreKey!.id, context: NullContext())
        
        //Restore One time preKeys
        let preKeyRecords = database.findAllPreKeyRecords()
        let nullContext = NullContext()
        preKeyRecords.forEach{ preKeyRecord in
            try?sekretessInMemorySignalStore?.storePreKey(preKeyRecord, id: preKeyRecord.id, context: nullContext)
        }
        
        //Restore kyberPreKeys
        try?sekretessInMemorySignalStore!.loadKyberPreKey()
    }
    
    private func initializeNew(){
        do{
            database.clearKeys()
            
            let registrationId = UInt32.random(in: 0...255)
            let identityKeyPair = IdentityKeyPair.generate()
            sekretessInMemorySignalStore = SekretessInMemoryProtocolStore(identity : identityKeyPair, registrationId: registrationId)
            
            let signedPreKeyId = UInt32.random(in: 0...UInt32.max-1)
            let signature = identityKeyPair.privateKey.generateSignature(message: identityKeyPair.publicKey.serialize())
            let signedPreKeyRecord = try SignedPreKeyRecord(id: signedPreKeyId, timestamp: UInt64(Date().timeIntervalSince1970),
                                                            privateKey: identityKeyPair.privateKey,
                                                            signature: signature)
            try sekretessInMemorySignalStore?.storeSignedPreKey(signedPreKeyRecord, id: signedPreKeyId , context: NullContext())
            let preKeyRecords = generatePreKey(count: 50)
            let preKeyRecordStrs = extractPublicKeysFromOpk(opks: preKeyRecords)
            let kyberPreKeyRecords = generateKyberPreKeyRecord(count: 50)
            let kyberPreKeyRecordStrs = extractPublicKeysFromKyberOpk(kyberOpks: kyberPreKeyRecords)
            
            //Generating lastResortPostQuantum Keys
            let lastResortKyberPreKeyRecord = kyberPreKeyRecords.last!
            let keyBundle = KeyBundle(regId: registrationId, ik: identityKeyPair.publicKey.serialize().base64EncodedString(),
                                      spk: try!signedPreKeyRecord.publicKey().serialize().base64EncodedString() ,
                                      opk: preKeyRecordStrs, spkSignature: signature.base64EncodedString(), spkID: String(signedPreKeyId),
                                      PQSPK: try!lastResortKyberPreKeyRecord.publicKey().serialize().base64EncodedString(),
                                      PQSPKID: String(lastResortKyberPreKeyRecord.id),
                                      PQSPKSignature: lastResortKyberPreKeyRecord.signature.base64EncodedString(), OPQK: kyberPreKeyRecordStrs)
            let idToken = appDelegate.authState?.lastTokenResponse?.idToken
            upsertKeys(keyBundle: keyBundle, bearerToken: idToken!){
                self.database.storeIdentityKeyPair(identityKeyPair: identityKeyPair, registrationId: registrationId)
                self.database.storeSignedPreKeyRecord(signedPreKeyRecord: signedPreKeyRecord)
                preKeyRecords.forEach{preKeyRecord in
                    self.database.storePreKeyRecord(preKeyRecord: preKeyRecord)
                }
                
                kyberPreKeyRecords.forEach{kyberPreKeyRecord in
                    self.database.storeKyberPreKeyRecord(kyberPreKeyRecord: kyberPreKeyRecord)
                }
            }
            
        }catch let error{
            os_log("error occurred during initialize encryption key ", error.localizedDescription)
        }
    }
    
    private func extractPublicKeysFromOpk(opks: [PreKeyRecord])->[String]{
        var result:[String] = []
        for opk in opks{
            result.append(try!opk.publicKey().serialize().base64EncodedString())
        }
        return result
    }
    
    private func extractPublicKeysFromKyberOpk(kyberOpks:[KyberPreKeyRecord])->[String]{
        var result: [String] = []
        for i in 0..<kyberOpks.count - 1{//Keep last item for last resort PQSPK
            result.append(try!kyberOpks[i].publicKey().serialize().base64EncodedString())
        }
        
        return result
    }
}
