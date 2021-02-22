//
//  ChatCell.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 22/02/21.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
