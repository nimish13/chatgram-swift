//
//  ViewController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 19/02/21.
//

import UIKit
import Firebase

class MessageController: UIViewController {
    
    var messages = [Message]()
    var chatGroupId = ""
    var currentUser: User!
    var user: User!
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.messageCellNibName, bundle: nil), forCellReuseIdentifier: K.messageCell)
        tableView.tableFooterView = UIView()
        loadMessages()
    }
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let message = messageField.text, !message.isEmpty {
            let data: [String: Any] = [
                K.Message.bodyFieldName: message,
                K.Message.senderFieldName: currentUser.firebaseId,
                K.Message.receiverFieldName: user.firebaseId,
                K.Message.timestampField: Date().timeIntervalSince1970
            ]
            db.collection(K.ChatGroup.collectionName).document(chatGroupId).collection(K.Message.collectionName).addDocument(data: data) { (optionalError) in
                if let error = optionalError {
                    GlobalUtility.showErrorAlert(error: error, vc: self)
                } else {
                    self.view.endEditing(true)
//                    self.reloadMessages()
                    self.messageField.text = ""
                }
            }
        }
    }
    
    func reloadMessages() {
        messages = []
        loadMessages()
    }
    
    func loadMessages() {
        db.collection(K.ChatGroup.collectionName).document(chatGroupId).collection(K.Message.collectionName).order(by: K.Message.timestampField, descending: false).addSnapshotListener() { (querySnapshot, optionaError) in
            if let error = optionaError {
                GlobalUtility.showErrorAlert(error: error, vc: self)
            } else {
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                    
                    var sender: User?
                    var receiver: User?
                    
                    if data[K.Message.senderFieldName] as! String == self.currentUser.firebaseId {
                        sender = self.currentUser
                        receiver = self.user
                    } else {
                        sender = self.user
                        receiver = self.currentUser
                    }
                    
                    let message = Message(
                        firebaseId: document.documentID,
                        body: data[K.Message.bodyFieldName] as! String,
                        sender: sender!,
                        receiver: receiver!,
                        timestamp: data[K.Message.timestampField] as! Double
                    )
                    self.messages.append(message)
                }

                self.tableView.reloadData()
                let index = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: index, at: .bottom, animated: false)
            }
        }
    }
}

extension MessageController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.messageCell, for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.body
        if message.sender.firebaseId == currentUser.firebaseId {
            cell.chatUserImageView.isHidden = true
            cell.currentUserImageView.isHidden = false
        } else {
            cell.currentUserImageView.isHidden = true
            cell.chatUserImageView.isHidden = false
        }
        cell.currentUserImageView.setImageForName(currentUser.fullName, backgroundColor: UIColor(hex: currentUser.hexcode), circular: true, textAttributes: nil)
        cell.chatUserImageView.setImageForName(user.fullName, backgroundColor: UIColor(hex: user.hexcode), circular: true, textAttributes: nil)
        cell.messageSentAtLabel.text = message.displayDate(for: message.timestamp)
        return cell
    }
}
