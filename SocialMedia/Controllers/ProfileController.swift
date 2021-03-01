//
//  ProfileController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 16/02/21.
//

import UIKit
import Firebase
import InitialsImageView
import SwipeCellKit

class ProfileController: UIViewController {
    
    let db = Firestore.firestore()
    let spinner = SpinnerViewController()
    var postsCollection = [Post]()
    
    var user: User! {
        didSet {
            if user != nil {
                loadPosts()
                setProfileImage(for: user, imageView: profilePhotoImageView)
            }
        }
    }
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.postCellNibName, bundle: nil), forCellReuseIdentifier: K.postCellIdentifier)
        tableView.tableFooterView = UIView()
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showActivityIndicator(with: spinner)
        fetchUser()
    }
    
    func fetchUser() {
        if let currentUser = Auth.auth().currentUser {
            let userRef = db.collection(K.User.collectionName).document(currentUser.uid)
            
            userRef.getDocument { [weak self] (document, error) in
                guard let strongSelf = self else { return }
                if let doc = document, let data = doc.data() {
                    strongSelf.user = User(
                        firebaseId: doc.documentID,
                        firstName: data[K.User.firstNameField] as! String,
                        lastName: data[K.User.lastNameField] as! String,
                        email: data[K.User.emailField] as! String,
                        hexcode: data[K.User.hexcodeField] as! String,
                        profileUrl: data[K.User.profileURLField] as? String
                    )
                    DispatchQueue.main.async {
                        strongSelf.nameLabel.text = strongSelf.user.fullName
                        strongSelf.emailLabel.text = strongSelf.user.email
                    }
                }
            }

        }
    }
    
    func loadPosts() {
        db.collection(K.Post.collectionName).whereField(K.Post.userField, isEqualTo: Auth.auth().currentUser!.uid).order(by: K.Post.timestampField, descending: true).addSnapshotListener { [weak self] (querySnapshot, optionalError) in
            
            guard let strongSelf = self  else { return }
            
            if let error = optionalError {
                GlobalUtility.showErrorAlert(error: error, vc: strongSelf)
            } else {
                strongSelf.postsCollection = []
                for document in querySnapshot!.documents {
                    let data = document.data()

                    let post = Post(
                        firebaseId: document.documentID,
                        user: strongSelf.user,
                        body: data["body"] as! String,
                        timestamp: data["timestamp"] as! Double
                    )
                    strongSelf.postsCollection.append(post)
                    DispatchQueue.main.async {
                        strongSelf.hideActivityIndication(with: strongSelf.spinner)
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == K.editProfileIdentifier {
            if let destinationVc = segue.destination as? EditProfileController {
                destinationVc.user = user
            }
        }
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

extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        postsCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.postCellIdentifier, for: indexPath) as! PostCell
        cell.delegate = self
        let post = postsCollection[indexPath.row]
        cell.postContentLabel.text = post.body
        cell.ownerDisplayLabel.text = post.user.fullName
        setProfileImage(for: post.user, imageView: cell.userImageView)
        cell.dateLabel.text = post.displayDate(for: post.timestamp)
        return cell
    }
}

extension ProfileController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            
            let post = self.postsCollection[indexPath.row]
            self.db.collection(K.Post.collectionName).document(post.firebaseId).delete { (optionalError) in
                if let error = optionalError {
                    GlobalUtility.showErrorAlert(error: error, vc: self)
                }
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
}
