//
//  ViewController.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 22.09.25.
//

import UIKit
import LibSignalClient
import AppAuthCore
import AppAuth
import SwiftData
import OSLog

class ViewController: UIViewController {

    let logger = Logger(subsystem: "io.sekretess", category: "ViewController")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var authState : OIDAuthState?
    @IBAction func onLoginButtonClicked(_ sender: Any) {
        if self.authState == nil{
            let issuer = URL(string: "https://auth.test.sekretess.io/realms/consumer")!
            let redirectUrl = URL(string: "sekretess://oauth2redirect")!                
            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer){configuration, error in
                guard let config = configuration else{
                    os_log("Error retrieving discovery document: %s")
                    return
                }
                if error != nil{
                    os_log("Error occurred ")
                    return
                }
                let request = OIDAuthorizationRequest(configuration: config,
                                                      clientId: "consumer_client",
                                                      scopes: ["email", "roles", "profile", "web-origins", "acr", "openid"],
                                                      redirectURL: redirectUrl,
                                                      responseType: OIDResponseTypeCode,
                                                      additionalParameters: nil
                )
            
                
                self.appDelegate.currentAuthorizationFlow =
                OIDAuthState.authState(byPresenting: request, presenting: self){ authState, error in
                    if let authState = authState{
                        self.authState = authState
                        self.storeAuthState(authState:authState)
                        os_log("Got auth tokens. Access token.")
                        self.performSegue(withIdentifier: "segueShowMessageCollectionViewController", sender: self)
                    }else{
                        os_log("Auth error")
                        self.authState = nil
                    }
                }
            }
        }else{
            performSegue(withIdentifier: "segueShowMessageCollectionViewController", sender: self)
            os_log("Already authorized")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restoreAuthState()
    }
    
    
    func restoreAuthState(){
        let fetchDescription = FetchDescriptor<AuthStateModel>()
        do{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let modelContext = ModelContext(appDelegate.modelContainer!)
            let restoredAuthState = try modelContext.fetch(fetchDescription)
            let authStateBase64 = restoredAuthState.first?.authState
            os_log("fetching authState from sqlite")
            if authStateBase64 != nil{
                os_log("restoring authState")
                let authStateData = Data(base64Encoded: authStateBase64!)
                self.authState = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [OIDAuthState.self], from: authStateData!) as? OIDAuthState
                os_log("authState restored")
            }
            
            if self.authState == nil{
                os_log("Not authorized opening auth page")
            }else{
                os_log("Authorized skipped auth page")
                performSegue(withIdentifier: "segueShowMessageCollectionViewController", sender: self)
            }
        }catch {
            os_log("error occurred")
        }
    }
    
    func storeAuthState(authState: OIDAuthState){
        let authStateData = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
        let modelContext = ModelContext(appDelegate.modelContainer!)
        modelContext.insert(AuthStateModel(authState: authStateData!.base64EncodedString()))
        try?modelContext.save()
    }


}

