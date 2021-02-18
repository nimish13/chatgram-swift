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
    
    var postsCollection = [Post]()
    
    @IBOutlet weak var feedTextView: UITextView!
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTextView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        feedTextView.layer.borderWidth = 2
        feedTextView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        tableView.register(UINib(nibName: K.postCellNibName, bundle: nil), forCellReuseIdentifier: K.postCellIdentifier)
        tableView.tableFooterView = UIView()
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
    
    func loadPosts() {
        db.collection(K.Post.collectionName).order(by: "timestamp", descending: false).addSnapshotListener { (querySnapshot, optionalError) in
            if let error = optionalError {
                GlobalUtility.showErrorAlert(error: error, vc: self)
            } else {
                self.postsCollection = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    self.loadUser(id: data["user"] as! String){ (user) in
                        let post = Post(
                            user: user,
                            body: data["body"] as! String,
                            timestamp: data["timestamp"] as! Double
                        )
                        self.postsCollection.append(post)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func loadUser(id: String, addPost:@escaping (User) -> Void) {
        let userRef = db.collection(K.User.collectionName).document(id)
        let user = User()
        userRef.getDocument { (document, error) in
            if let doc = document, let data = doc.data() {
                user.firstName = data["firstName"] as! String
                user.lastName = data["lastName"] as! String
                user.email = data["firstName"] as! String
            }
            addPost(user)
        }
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
        cell.ownerDisplayLabel.text = "<\(post.user.fullName)>"
        cell.dateLabel.text = post.displayFormattedDate()
        return cell
    }
    
    
}
