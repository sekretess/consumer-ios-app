//
//  SignupViewController.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 09.10.25.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtVerifyPassword: UITextField!
    
    @IBAction func onAlreadyMemberClicked(_ sender: Any) {
        dismiss(animated: false)
    }
    @IBAction func onSignupClicked(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }       
}
