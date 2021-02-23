//
//  MessageCell.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 19/02/21.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageSentAtLabel: UILabel!
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var chatUserImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageBubble.layer.cornerRadius = messageBubble.frame.size.height / 5
//        messageBubble.backgroundColor = UIColor.red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
