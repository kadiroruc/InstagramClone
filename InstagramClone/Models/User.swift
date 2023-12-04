//
//  User.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 8.10.2023.
//

import Foundation

struct User{
    let username: String
    let profileImageUrl: String
    let uid: String
    
    init(uid: String, dictionary: [String:Any]){
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = uid
    }
}
