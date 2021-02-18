//
//  EditProfileController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 18/02/21.
//

import UIKit
import Firebase

class EditProfileController: UIViewController {
    
    var user: User!
    let db = Firestore.firestore()
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if let firstName = firstNameField.text, !firstName.isEmpty, let lastName = lastNameField.text, !lastName.isEmpty {
            db.collection(K.User.collectionName).document(Auth.auth().currentUser!.uid).setData([
                K.User.firstNameField: firstName,
                K.User.lastNameField: lastName,
                K.User.emailField: user.email
            ]) { optionalError in
                if let error = optionalError {
                    GlobalUtility.showErrorAlert(error: error, vc: self)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
//                    self.dismiss(animated: true, completion: nil)
                }
            }
        }

    }
    
}
