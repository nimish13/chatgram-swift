//
//  Constants.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 15/02/21.
//

struct K {
    static let appName = "ChatGram 💬"
    static let postCellIdentifier = "PostCell"
    static let editProfileIdentifier = "editProfile"
    static let postCellNibName = "PostCell"
    static let mainBarIdentifier = "MainTabBarController"
    static let loginNavIdentifier = "LoginNavigationController"
    struct Auth {
        static let loginIdentifier = "loginDone"
        static let registerIdentifier = "registerDone"
    }
    struct Post {
        static let collectionName = "posts"
        static let userField = "user"
        static let ownerField = "owner"
        static let bodyField = "body"
        static let timestampField = "timestamp"
    }
    
    struct User {
        static let collectionName = "users"
        static let firstNameField = "firstName"
        static let lastNameField = "lastName"
        static let emailField = "email"
    }
}
