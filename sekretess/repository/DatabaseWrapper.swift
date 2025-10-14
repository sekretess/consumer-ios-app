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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var modelContext: ModelContext
    
    init(){
        modelContext = ModelContext(appDelegate.modelContainer!)
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
        modelContext.insert(AuthStateModel(authState: authStateData!.base64EncodedString()))
        try?modelContext.save()
    }
    
    func storeIdentityKeyPair(identityKeyPair: IdentityKeyPair){
        let identityKeyPairStr = identityKeyPair.serialize().base64EncodedString()
        modelContext.insert(IdentityKeyModel(identityKey: identityKeyPairStr))
    }
    
    func restoreIdentityKeyPair()->IdentityKeyPair?{
        let fetchDescription = FetchDescriptor<IdentityKeyModel>()
        do{
            let restoredIdentityKeyPair = try? modelContext.fetch(fetchDescription)
            let identityKeyPairBase64 = restoredIdentityKeyPair?.first?.identityKey
            os_log("fetching identityKeyPair from sqlite")
            if identityKeyPairBase64 != nil{
                os_log("restoring identityKeyPair")
                let identityKeyPairData = Data(base64Encoded: identityKeyPairBase64!)
                os_log("identityKeyPair restored")
                return try? IdentityKeyPair(bytes: identityKeyPairData!)
            }
        }
        return nil
    }
    
    func storeSignedPreKeyRecord(signedPreKeyRecord: SignedPreKeyRecord){
        let signedPreKeyRecordStr = signedPreKeyRecord.serialize().base64EncodedString()
        modelContext.insert(SignedPreKeyRecordModel(signedPreKey: signedPreKeyRecordStr))
    }
    
    func restoreSignedPreKeyRecord()->SignedPreKeyRecord?{
        let fetchDescription = FetchDescriptor<SignedPreKeyRecordModel>()
        do{
            let restoredSignedPreKeyRecord = try? modelContext.fetch(fetchDescription)
            let signedPreKeyRecordBase64 = restoredSignedPreKeyRecord?.first?.signedPreKey
            os_log("fetching signedPreKeyRecord from sqlite")
            return try?SignedPreKeyRecord(bytes: Data(base64Encoded: signedPreKeyRecordBase64!)!)
        }
    }
    
    func storePreKeyRecord(preKeyRecord: PreKeyRecord){
        let preKeyRecordStr = preKeyRecord.serialize().base64EncodedString()
        modelContext.insert(PreKeyRecordModel(prekeyRecord: preKeyRecordStr))
    }
}
