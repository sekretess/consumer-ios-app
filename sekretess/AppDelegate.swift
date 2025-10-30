//
//  AppDelegate.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 22.09.25.
//

import UIKit
import AppAuthCore
import SwiftData

@main
class AppDelegate: UIResponder, UIApplicationDelegate{
    var modelContainer: ModelContainer?
    var database: DatabaseWrapper?
    var signalProtocol: SignalProtocol?
    var currentAuthorizationFlow : OIDExternalUserAgentSession?
    var authState : OIDAuthState?
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("app opened", url)
        if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: url){
            self.currentAuthorizationFlow = nil
            return true
        }
        
           // Analyze the URL and perform necessary actions
           return false
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do{
            modelContainer = try!ModelContainer(for: AuthStateModel.self, IdentityKeyModel.self,PreKeyRecordModel.self,
                                                SignedPreKeyRecordModel.self,KyberPreKeyRecordModel.self,SenderKeyModel.self,SessionModel.self)
            database = DatabaseWrapper(modelContainer: modelContainer!)
        }catch {
            print("Error occurred initialize modelContainer")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {        
        print("app started", connectingSceneSession)
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("app started", sceneSessions)
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           // URL handling code
        print("URL: \(url)")
        if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: url){
            self.currentAuthorizationFlow = nil
            return true
        }
        
           // Analyze the URL and perform necessary actions
           return false
       }

}

