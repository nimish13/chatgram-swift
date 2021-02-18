//
//  PostCell.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 16/02/21.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ownerDisplayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
