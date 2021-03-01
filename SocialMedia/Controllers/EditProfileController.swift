//
//  EditProfileController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 18/02/21.
//

import UIKit
import FirebaseStorage
import Firebase
import SDWebImage

class EditProfileController: UIViewController {
    
    var user: User!
    let spinner = SpinnerViewController()
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileImage(for: user, imageView: userImageView)
        firstNameField.text = user.firstName
        lastNameField.text = user.lastName
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if let firstName = firstNameField.text, !firstName.isEmpty, let lastName = lastNameField.text, !lastName.isEmpty {
            db.collection(K.User.collectionName).document(Auth.auth().currentUser!.uid).updateData([
                K.User.firstNameField: firstName,
                K.User.lastNameField: lastName
            ]) { optionalError in
                if let error = optionalError {
                    GlobalUtility.showErrorAlert(error: error, vc: self)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        
    }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func profileUploadButtonPressed(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            self.showActivityIndicator(with: self.spinner)
        }
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let imageData = editedImage.pngData() {
            let imageRef = storage.child("ProfileImages/\(user.firebaseId)/profileImage.png")
            imageRef.putData(imageData, metadata: nil) { (_, optionalError) in
                if let error = optionalError {
                    self.hideActivityIndication(with: self.spinner)
                    GlobalUtility.showErrorAlert(error: error, vc: self)
                } else {
                    imageRef.downloadURL { (url, error) in
                        if let imageUrl = url {
                            self.db.collection(K.User.collectionName).document(self.user.firebaseId).updateData([K.User.profileURLField: imageUrl.absoluteString]) { (error) in
                                if let error = error {
                                    GlobalUtility.showErrorAlert(error: error, vc: self)
                                }
                                self.user.profileUrl = imageUrl.absoluteString
                                DispatchQueue.main.async {
                                    self.setProfileImage(for: self.user, imageView: self.userImageView)
                                }
                                self.hideActivityIndication(with: self.spinner)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
