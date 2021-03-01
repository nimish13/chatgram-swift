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
    
    let spinner = SpinnerViewController()
    let db = Firestore.firestore()
    let dropDown = DropDown()
    var users = [User]()
    var usersWithCurrentUser = [User]()
    var usersFetched = false {
        didSet {
            if usersFetched {
                fetchChats()
            }
        }
    }
    var currentUser: User! {
        didSet {
            if currentUser != nil {
                fetchUsers()
            }
        }
    }
    var chats = [ChatGroup]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewChatButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.chatCellNibName, bundle: nil), forCellReuseIdentifier: K.chatCell)
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        createSpinnerView()
        showActivityIndicator(with: spinner)
        fetchCurrentUser()
        
    }
    
    func fetchChats() {
        chats = []
        let dispatchGroup = DispatchGroup()
        
        self.db.collection(K.ChatGroup.collectionName).whereField(K.ChatGroup.usersFieldName, arrayContains: currentUser.firebaseId).order(by: K.ChatGroup.timestampField, descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                GlobalUtility.showErrorAlert(error: error, vc: self)
            } else {
                for document in querySnapshot!.documents {
                    dispatchGroup.enter()
                    let chatGroup = ChatGroup(id: document.documentID)
                    self.fetchLastChatMessage(chatGroup: chatGroup, dispatchGroup: dispatchGroup)
                }
                dispatchGroup.notify(queue: .main) {
                    self.hideActivityIndication(with: self.spinner)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchLastChatMessage(chatGroup: ChatGroup, dispatchGroup: DispatchGroup) {
        db.collection(K.ChatGroup.collectionName).document(chatGroup.firebaseId).collection(K.Message.collectionName).order(by: K.Message.timestampField, descending: true).limit(to: 1).getDocuments { (querySnapshot, error) in
            if let error = error {
                GlobalUtility.showErrorAlert(error: error, vc: self)
            } else {
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                    let optionalSender = self.usersWithCurrentUser.first { $0.firebaseId == data[K.Message.senderFieldName] as! String }
                    let optionalReceiver = self.usersWithCurrentUser.first { $0.firebaseId == data[K.Message.receiverFieldName] as! String }
                    if let sender = optionalSender, let receiver = optionalReceiver {
                        let message = Message(firebaseId: document.documentID, body: data[K.Message.bodyFieldName] as! String, sender: sender, receiver: receiver, timestamp: data[K.Message.timestampField] as! Double)
                        chatGroup.lastMessage = message
                        self.chats.append(chatGroup)
                    }
                }
                dispatchGroup.leave()
            }
        }
    }
    
    func fetchCurrentUser() {
        if let currentUser = Auth.auth().currentUser {
            let userRef = db.collection(K.User.collectionName).document(currentUser.uid)
            
            userRef.getDocument { [weak self] (document, error) in
                guard let strongSelf = self else { return }
                if let doc = document, let data = doc.data() {
                    strongSelf.currentUser = User(
                        firebaseId: doc.documentID,
                        firstName: data[K.User.firstNameField] as! String,
                        lastName: data[K.User.lastNameField] as! String,
                        email: data[K.User.emailField] as! String,
                        hexcode: data[K.User.hexcodeField] as! String,
                        profileUrl: data[K.User.profileURLField] as? String
                    )
                }
            }
            
        }
    }
    
    
    func fetchUsers() {
        users = []
        usersWithCurrentUser = []
        db.collection(K.User.collectionName).order(by: K.User.firstNameField, descending: true).getDocuments { (querySnapshot, optionalError) in
            if let error = optionalError {
                GlobalUtility.showErrorAlert(error: error, vc: self)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let user = User(firebaseId: document.documentID, firstName: data[K.User.firstNameField] as! String, lastName: data[K.User.lastNameField] as! String, email: data[K.User.emailField] as! String, hexcode:  data[K.User.hexcodeField] as! String, profileUrl: data[K.User.profileURLField] as? String)
                    self.usersWithCurrentUser.append(user)
                }
                self.users = self.usersWithCurrentUser.filter { $0.firebaseId != Auth.auth().currentUser?.uid ?? ""}
                self.usersFetched = true
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
                        let data: [String: Any] = [
                            K.ChatGroup.usersFieldName: [currentUserId, user.firebaseId],
                            K.ChatGroup.timestampField: Date().timeIntervalSince1970
                        ]
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

extension ChatController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.chatCell, for: indexPath) as! ChatCell
        let chat = chats[indexPath.row]
        if let lastMessage = chat.lastMessage {
            if lastMessage.sender.firebaseId == currentUser.firebaseId {
                cell.userName.text = lastMessage.receiver.fullName
                cell.userImageView.setImageForName(lastMessage.receiver.fullName, backgroundColor: UIColor(hex: lastMessage.receiver.hexcode), circular: true, textAttributes: nil)
            } else {
                cell.userName.text = lastMessage.sender.fullName
                setProfileImage(for: lastMessage.sender, imageView: cell.userImageView)
            }
            cell.message.text = lastMessage.body
            cell.timestamp.text = lastMessage.displayDate(for: lastMessage.timestamp)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
        let user = chat.lastMessage!.sender.firebaseId == currentUser.firebaseId ? chat.lastMessage!.receiver : chat.lastMessage!.sender
        switchToMessageController(chatGroupId: chat.firebaseId, user: user)
    }
    
}
