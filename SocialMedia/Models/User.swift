//
//  User.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 17/02/21.
//

import Foundation

class User {
    
    var firebaseId: String
    var profileUrl: String?
    var firstName: String
    var lastName: String
    var email: String
    var hexcode: String
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(firebaseId: String, firstName: String, lastName: String, email: String, hexcode: String, profileUrl: String? = nil) {
        self.firebaseId = firebaseId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.hexcode = hexcode
        self.profileUrl = profileUrl
    }
    
    convenience init() {
        self.init(firebaseId: "", firstName: "Anonymous", lastName: "User", email: "ghost@chatgram.com", hexcode: "#ABEBC6")
    }
    
}
