//
//  Message.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 22/02/21.
//

import Foundation

struct Message: FormattedDate {
    var firebaseId: String
    var body: String
    var sender: User
    var receiver: User
    var timestamp: Double
}
