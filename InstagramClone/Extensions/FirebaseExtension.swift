//
//  FirebaseExtension.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 27.10.2023.
//

import FirebaseDatabase

extension Database{
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()){
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let userDictionary = snapshot.value as? [String:Any] else{return}
            let user = User(uid: uid, dictionary: userDictionary)
            
            completion(user)
        }
    }
}
