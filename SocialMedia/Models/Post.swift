//
//  Post.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 17/02/21.
//

import Foundation

struct Post {
    let user: User
    let body: String
    let timestamp: Double
    
    init(user: User, body: String, timestamp: Double) {
        self.user = user
        self.body = body
        self.timestamp = timestamp
    }
    func displayFormattedDate() -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short //Set time style
        dateFormatter.dateStyle = .medium //Set date style
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}
