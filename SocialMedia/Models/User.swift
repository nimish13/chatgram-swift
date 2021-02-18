//
//  User.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 17/02/21.
//

import Foundation

class User {
    
    var firstName: String
    var lastName: String
    var email: String
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(firstName: String, lastName: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
    
    convenience init() {
        self.init(firstName: "Anonymous", lastName: "User", email: "ghost@chatgram.com")
    }
    
}
