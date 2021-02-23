//
//  ViewController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 19/02/21.
//

import UIKit
import Firebase
import SwipeCellKit

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
                if !self.messages.isEmpty {
                    let index = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: index, at: .bottom, animated: false)
                }
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
        cell.delegate = self
        cell.messageLabel.text = message.body
        cell.messageSentAtLabel.isHidden = true
        if message.sender.firebaseId == currentUser.firebaseId {
            cell.chatUserImageView.isHidden = true
            cell.currentUserImageView.isHidden = false
            cell.messageLabel.textColor = UIColor.black
            cell.messageBubble.backgroundColor = UIColor(named: K.Message.chatMeColor)
        } else {
            cell.currentUserImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.Message.chatYouColor)
            cell.messageLabel.textColor = UIColor.white
            cell.chatUserImageView.isHidden = false
        }
        cell.currentUserImageView.setImageForName(currentUser.fullName, backgroundColor: UIColor(hex: currentUser.hexcode), circular: true, textAttributes: nil)
        cell.chatUserImageView.setImageForName(user.fullName, backgroundColor: UIColor(hex: user.hexcode), circular: true, textAttributes: nil)
        cell.messageSentAtLabel.text = message.displayDate(for: message.timestamp)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: MessageCell = tableView.cellForRow(at: indexPath) as! MessageCell
        cell.messageSentAtLabel.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: MessageCell = tableView.cellForRow(at: indexPath) as! MessageCell
        cell.messageSentAtLabel.isHidden = true
    }
}

extension MessageController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        if messages[indexPath.row].sender.firebaseId != currentUser.firebaseId {
            return nil
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            
            let message = self.messages[indexPath.row]
            self.db.collection(K.ChatGroup.collectionName).document(self.chatGroupId).collection(K.Message.collectionName).document(message.firebaseId).delete { (optionalError) in
                if let error = optionalError {
                    GlobalUtility.showErrorAlert(error: error, vc: self)
                } else {
                    self.messages.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    
}
