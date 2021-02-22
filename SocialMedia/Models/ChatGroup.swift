//
//  ChatGroup.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 22/02/21.
//

import Foundation

class ChatGroup {
    let firebaseId: String
    var lastMessage: Message?
    
    init(id: String) {
        self.firebaseId = id
    }
}
