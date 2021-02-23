//
//  Post.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 17/02/21.
//

import Foundation

struct Post: FormattedDate {
    var firebaseId: String
    var user: User
    let body: String
    let timestamp: Double
}
