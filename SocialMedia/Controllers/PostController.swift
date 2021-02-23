//
//  FeedViewController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 15/02/21.
//

import UIKit
import Firebase

class PostController: UIViewController {
    
    let db = Firestore.firestore()
    let spinner = SpinnerViewController()
    
    var postsCollection = [Post]()
    
    @IBOutlet weak var feedTextView: UITextView!
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTextView.delegate = self
        feedTextView.layer.borderWidth = 2
        feedTextView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.postCellNibName, bundle: nil), forCellReuseIdentifier: K.postCellIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
    }
    @IBAction func postButtonPressed(_ sender: UIButton) {
        if let content = feedTextView.text, content.count > 0 {
            let data: [String : Any] = [
                K.Post.bodyField: content,
                K.Post.userField: Auth.auth().currentUser!.uid,
                K.Post.timestampField: Date().timeIntervalSince1970
            ]
            db.collection(K.Post.collectionName).addDocument(data: data) { (optionalError) in
                if let error = optionalError {
                    GlobalUtility.showErrorAlert(error: error, vc: self)
                } else {
                    self.clearFeedContent()
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        clearFeedContent()
    }
    
    func clearFeedContent() {
        feedTextView.text = ""
        setButtonsState(condition: false)
    }
    
    func setButtonsState(condition: Bool) {
        postButton.isEnabled = condition
        cancelButton.isEnabled = condition
    }
    
}

extension PostController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        setButtonsState(condition: textView.text.count > 0)
    }
    
}

extension PostController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postsCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.postCellIdentifier, for: indexPath) as! PostCell
        let post = postsCollection[indexPath.row]
        cell.postContentLabel.text = post.body
        cell.userImageView.setImageForName(post.user.fullName, backgroundColor: UIColor(hex: post.user.hexcode), circular: true, textAttributes: nil)
        cell.ownerDisplayLabel.text = "<\(post.user.fullName)>"
        cell.dateLabel.text = post.displayDate(for: post.timestamp)
        return cell
    }
    
    
}


// MARK: Add Methods to fetch Posts and user for each Post using dispatchGroup
extension PostController {
    func loadPosts() {
        showActivityIndicator(with: spinner)
        let dispatchGroup = DispatchGroup()
        
        db.collection(K.Post.collectionName).order(by: K.Post.timestampField, descending: true).addSnapshotListener { (querySnapshot, optionalError) in
            if let error = optionalError {
                GlobalUtility.showErrorAlert(error: error, vc: self)
            } else {
                self.postsCollection = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    dispatchGroup.enter()
                    
                    let user = self.loadUser(id: data["user"] as! String, dispatchGroup: dispatchGroup)

                    let post = Post(
                        user: user,
                        body: data["body"] as! String,
                        timestamp: data["timestamp"] as! Double
                    )
                    self.postsCollection.append(post)
                }
                dispatchGroup.notify(queue: .main) {
                    self.hideActivityIndication(with: self.spinner)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadUser(id: String, dispatchGroup: DispatchGroup) -> User {
        let userRef = db.collection(K.User.collectionName).document(id)
        let user = User()
        userRef.getDocument { (document, error) in
            if let doc = document, let data = doc.data() {
                user.firebaseId = doc.documentID
                user.firstName = data["firstName"] as! String
                user.lastName = data["lastName"] as! String
                user.email = data["email"] as! String
                user.hexcode = data[K.User.hexcodeField] as! String
            }
            dispatchGroup.leave()
        }
        
        return user
    }
    
}
