//
//  RegistrationViewController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 15/02/21.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailField.text, !email.isEmpty, let password = passwordField.text, !password.isEmpty, let firstName = firstNameField.text, !firstName.isEmpty, let lastName = lastNameField.text, !lastName.isEmpty {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let errorMessage = error {
                    GlobalUtility.showErrorAlert(error: errorMessage, vc: self)
                } else {
                    self.createUser(firstname: firstName, lastName: lastName, authResult: authResult!)
                }
            }
        } else {
            GlobalUtility.showErrorAlert(error: RuntimeError("Please provide all the information"), vc: self)
        }
    }
    
    func createUser(firstname: String, lastName: String, authResult: AuthDataResult) {
        db.collection(K.User.collectionName).document(authResult.user.uid).setData([
            K.User.firstNameField: firstname,
            K.User.lastNameField: lastName,
            K.User.emailField: authResult.user.email!
        ]) { optionalError in
            if let error = optionalError {
                GlobalUtility.showErrorAlert(error: error, vc: self)
            } else {
                GlobalUtility.switchController(identifier: K.mainBarIdentifier)
            }
        }
    }
}

extension RegistrationController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
}
