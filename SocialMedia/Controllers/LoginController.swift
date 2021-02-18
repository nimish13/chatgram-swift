//
//  LoginViewController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 15/02/21.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let errorMessage = error {
                    GlobalUtility.showErrorAlert(error: errorMessage, vc: self)
                } else {
                    GlobalUtility.switchController(identifier: K.mainBarIdentifier)
                }
            }
        }
    }
    
}

extension LoginController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
}
