//
//  FeedViewController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 15/02/21.
//

import UIKit
import Firebase

class FeedViewController: UIViewController {
        
    let db = Firestore.firestore()
    
    @IBOutlet weak var feedTextView: UITextView!
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedTextView.delegate = self
        feedTextView.layer.borderWidth = 2
        feedTextView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        if let content = feedTextView.text, content.count > 0 {
            let data: [String : Any] = [
                K.Post.ownerField: Auth.auth().currentUser!.email!,
                K.Post.bodyField: content,
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

extension FeedViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        setButtonsState(condition: textView.text.count > 0)
    }
    
}
