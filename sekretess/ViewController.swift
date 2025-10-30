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
import OSLog

class ViewController: UIViewController {

    let logger = Logger(subsystem: "io.sekretess", category: "ViewController")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func onLoginButtonClicked(_ sender: Any) {
        if appDelegate.authState == nil{
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
                        self.appDelegate.authState = authState
                        self.appDelegate.database!.storeAuthState(authState:authState)
                        os_log("Got auth tokens. Access token.")
                        self.handleAuthSuccess()
                    }else{
                        os_log("Auth error")
                        self.appDelegate.authState = nil
                    }
                }
            }
        }else{
            handleAuthSuccess()
            os_log("Already authorized")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appDelegate.authState = appDelegate.database!.restoreAuthState()
        if appDelegate.authState == nil{
            os_log("Not authorized opening auth page")
        }else{
            os_log("Authorized skipped auth page")
            handleAuthSuccess()
        }
    }
    
    func handleAuthSuccess(){
        
        let tokenRefreshRequest = appDelegate.authState?.tokenRefreshRequest()
        OIDAuthorizationService.perform(tokenRefreshRequest!){tokenResponse, error in
            if let error = error {
                os_log("Error occurred during update token state")
                self.appDelegate.authState = nil
            }else{
                self.appDelegate.signalProtocol = SignalProtocol()
                self.performSegue(withIdentifier: "segueShowMessageCollectionViewController", sender: self)
                os_log("Auth State updated success!" )
                let webSocket = WebSocketClient(url: URL(string:"wss://echo.websocket.org")!)
                webSocket.connect()
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                     webSocket.send(message: "Hello from Swift!")
                 }
                webSocket.receive()
            }
        }
    }
    
    

    

}

