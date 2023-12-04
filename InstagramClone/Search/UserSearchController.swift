//
//  UserSearchController.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 1.11.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout,UISearchBarDelegate{
    let cellId = "cellId"
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Username"
        sb.barTintColor = .gray
        sb.searchTextField.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        return sb
    }()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let lowercaseText = searchBar.text?.lowercased() {
            searchBar.text = lowercaseText
        }
        
        filteredUsers = users.filter({ user in
            return user.username.contains(searchText)
        })
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        navigationController?.navigationBar.addSubview(searchBar)
        let navBar = navigationController?.navigationBar
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    var filteredUsers = [User]()
    var users = [User]()
    fileprivate func fetchUsers(){
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value) {[weak self] snapshot in
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            dictionaries.forEach { key,value in
                if key == Auth.auth().currentUser?.uid{
                    return
                }
                
                guard let userDictionary = value as? [String:Any] else {return}
                
                let user = User(uid: key, dictionary: userDictionary)
                self?.users.append(user)
            }
            self?.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let user = filteredUsers[indexPath.item]
        let userProfileController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        
        navigationController?.pushViewController(userProfileController, animated: true)
    }
}
