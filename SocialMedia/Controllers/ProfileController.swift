//
//  ProfileController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 16/02/21.
//

import UIKit
import Firebase

class ProfileController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GlobalUtility.switchController(identifier: K.loginNavIdentifier)
        } catch let error {
            GlobalUtility.showErrorAlert(error: error, vc: self)
        }
    }
    
}
