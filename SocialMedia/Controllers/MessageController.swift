//
//  ViewController.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 19/02/21.
//

import UIKit

class MessageController: UIViewController {
    
    var messages = ["NewMessage"]
    var chatGroupId: String!
    var currentUser: User!
    var user: User!
    
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.messageCellNibName, bundle: nil), forCellReuseIdentifier: K.messageCell)
        tableView.tableFooterView = UIView()
    }


    @IBAction func sendButtonPressed(_ sender: UIButton) {
    }
}

extension MessageController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.messageCell, for: indexPath) as! MessageCell
        cell.messageLabel.text = user.fullName
        return cell
    }
    
    
}
