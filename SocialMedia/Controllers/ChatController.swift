//
//  ChatController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 16/02/21.
//

import UIKit
import DropDown
import Firebase

class ChatController: UIViewController {
    
    let db = Firestore.firestore()
    let dropDown = DropDown()
    var users = [User]()
    var currentUser: User! {
        didSet {
            if currentUser != nil {
                fetchUsers()
            }
        }
    }
    
    @IBOutlet weak var addNewChatButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        if let currentUser = Auth.auth().currentUser {
            let userRef = db.collection(K.User.collectionName).document(currentUser.uid)
            
            userRef.getDocument { [weak self] (document, error) in
                guard let strongSelf = self else { return }
                if let doc = document, let data = doc.data() {
                    strongSelf.currentUser = User(
                        firebaseId: doc.documentID,
                        firstName: data["firstName"] as! String,
                        lastName: data["lastName"] as! String,
                        email: data["email"] as! String
                    )
                }
            }

        }
    }
    
    
    func fetchUsers() {
        db.collection(K.User.collectionName).whereField(K.User.emailField, isNotEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { (querySnapshot, optionalError) in
            if let error = optionalError {
                GlobalUtility.showErrorAlert(error: error, vc: self)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let user = User(firebaseId: document.documentID, firstName: data[K.User.firstNameField] as! String, lastName: data[K.User.lastNameField] as! String, email: data[K.User.emailField] as! String)
                    self.users.append(user)
                }
                self.initDropDown()
            }
        }
    }
    
    @IBAction func addNewChatPressed(_ sender: UIBarButtonItem) {
        dropDown.show()
    }
    
    func switchToMessageController(chatGroupId: String, user: User) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: K.messageControllerStoryBoardIdentifier) as! MessageController
        
        newViewController.user = user
        newViewController.chatGroupId = chatGroupId
        newViewController.currentUser = currentUser
        
        navigationController?.pushViewController(newViewController, animated: true)
    }
    
}

extension ChatController {
    
    func initDropDown() {
        dropDown.anchorView = addNewChatButton
        dropDown.dataSource = self.users.map { "\($0.fullName) - \($0.email)" }
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            
            guard let self = self else {
                return
            }
            
            let user = self.users[index]
            let currentUserId = Auth.auth().currentUser!.uid
            self.db.collection(K.ChatGroup.collectionName).whereField(K.ChatGroup.usersFieldName, in: [[currentUserId, user.firebaseId],[user.firebaseId, currentUserId]]).getDocuments { (querySnapshot, error) in
                if let error = error {
                    GlobalUtility.showErrorAlert(error: error, vc: self)
                } else {
                    if querySnapshot!.documents.count > 0 {
                        self.switchToMessageController(chatGroupId: querySnapshot!.documents[0].documentID, user: user)
                        
                    } else {
                        var ref: DocumentReference? = nil
                        let data = [K.ChatGroup.usersFieldName:[currentUserId, user.firebaseId]]
                        ref = self.db.collection(K.ChatGroup.collectionName).addDocument(data: data) { (error) in
                            if let error = error {
                                GlobalUtility.showErrorAlert(error: error, vc: self)
                            } else {
                                self.switchToMessageController(chatGroupId: ref!.documentID, user: user)
                            }
                        }
                    }
                }
            }

        }
    }
}
