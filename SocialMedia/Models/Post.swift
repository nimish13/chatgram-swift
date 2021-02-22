//
//  Post.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 17/02/21.
//

import Foundation

struct Post: FormattedDate {
    var user: User
    let body: String
    let timestamp: Double
    
    init(user: User, body: String, timestamp: Double) {
        self.user = user
        self.body = body
        self.timestamp = timestamp
    }
}
