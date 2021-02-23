//
//  Constants.swift
//  SocialMedia
//
//  Created by Nimish Gupta13 on 15/02/21.
//

struct K {
    static let defaultErrorMessage = "Something went wrong. Please try again later."
    static let appName = "ChatGram 💬"
    static let postCellIdentifier = "PostCell"
    static let messageCellNibName = "MessageCell"
    static let chatCellNibName = "ChatCell"
    static let chatCell = "ChatCell"
    static let messageControllerStoryBoardIdentifier = "messageViewControllerIdentifier"
    static let messageCell = "messageCell"
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
    
    struct ChatGroup {
        static let collectionName = "chatGroups"
        static let usersFieldName = "users"
        static let timestampField = "timestamp"
    }
    
    struct User {
        static let collectionName = "users"
        static let firstNameField = "firstName"
        static let lastNameField = "lastName"
        static let emailField = "email"
        static let hexcodeField = "hexcode"
    }
    
    struct Message {
        static let collectionName = "messages"
        static let senderFieldName = "sender"
        static let receiverFieldName = "receiver"
        static let bodyFieldName = "body"
        static let timestampField = "timestamp"
    }
}
