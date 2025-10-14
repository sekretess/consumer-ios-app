//
//  SignalProtocol.swift
//  sekretess
//
//  Created by Atakishiyev Elnur on 13.10.25.
//

import Foundation
import LibSignalClient
import SwiftData


class SignalProtocol{
    var inMemoryStore: InMemorySignalProtocolStore?;
    
    //Initialize signal protocol
    func initialize(){
        
        let identityKeyPair = IdentityKeyPair.generate()
        inMemoryStore = InMemorySignalProtocolStore(identity: identityKeyPair, registrationId: 1)
        
        let signedPreKeyId = UInt32.random(in: 0...UInt32.max )
        let signedPreKeyRecord = try?SignedPreKeyRecord(id: signedPreKeyId, timestamp: UInt64(Date().timeIntervalSince1970),
                                                        privateKey: identityKeyPair.privateKey,
                                                        signature: identityKeyPair.privateKey.generateSignature(message: identityKeyPair.publicKey.serialize()))
                
        try?inMemoryStore!.storeSignedPreKey(signedPreKeyRecord!, id: signedPreKeyRecord!.id , context: NullContext())
        generatePreKey(count: 50, store: inMemoryStore!)
        generateKyberPreKeyRecord(count: 50, store: inMemoryStore!)
    }
    
    func generateKyberPreKeyRecord(count: Int, store: InMemorySignalProtocolStore){
        for i in 0..<count{
            let privateKey = PrivateKey.generate()
            let keyPair = KEMKeyPair.generate()
            let kyberPreKeyRecord = try?KyberPreKeyRecord(id: UInt32(i), timestamp: UInt64(Date.timeIntervalSinceReferenceDate),
                                                          keyPair: keyPair, signature: privateKey.generateSignature(message: privateKey.publicKey.serialize()))
            try?store.storeKyberPreKey(kyberPreKeyRecord!, id: kyberPreKeyRecord!.id, context: NullContext())
        }
    }
    
    func generatePreKey(count: Int, store: InMemorySignalProtocolStore){
        for i in 0..<count{
            let privateKey = PrivateKey.generate()
            let preKeyRecord = try? PreKeyRecord(id: UInt32(i), publicKey: privateKey.publicKey,privateKey: privateKey)
            try?store.storePreKey(preKeyRecord!, id: preKeyRecord!.id, context: NullContext())
        }
    }
    
    
    //Restore signal protocol state from db
    func restore(){
        
    }
    
}
