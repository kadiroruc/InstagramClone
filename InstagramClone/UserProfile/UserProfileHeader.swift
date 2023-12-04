//
//  UserProfileHeader.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 8.10.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserProfileHeader: UICollectionViewCell {
    
    var user:User? {
        didSet{
            guard let profileImageUrl = user?.profileImageUrl else{return}
            
            profileImageView.loadImage(urlString: profileImageUrl)
            
            usernameLabel.text = self.user?.username
            
            setupEditFollowButton()
        }
    }
    fileprivate func setupEditFollowButton(){
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if currentUserId != userId{
            
            //check if following
            Database.database().reference().child("following").child(currentUserId).child(userId).observeSingleEvent(of: .value) {[weak self] snapshot in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1{
                    DispatchQueue.main.async {
                        self?.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    }
                }else{
                    DispatchQueue.main.async {
                        self?.setupFollowStyle()
                    }
                }
            }
        }
    }
    
    @objc func handleEditProfileOrFollow(){
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if editProfileFollowButton.titleLabel?.text == "Unfollow"{
            //unfollow
            Database.database().reference().child("following").child(currentUserId).child(userId).removeValue {[weak self] error, ref in
                if let error = error{
                    print("Failed to unfollow user",error)
                    return
                }
                DispatchQueue.main.async {
                    self?.setupFollowStyle()
                }
            }
        }else{
            //follow
            let ref = Database.database().reference().child("following").child(currentUserId)
            let values = [userId:1]
            ref.updateChildValues(values) {[weak self] error, ref in
                if let error = error{
                    print("Failed to follow user",error)
                    return
                }
                DispatchQueue.main.async {
                    self?.editProfileFollowButton.setTitle("Unfollow", for: .normal)
                    self?.editProfileFollowButton.backgroundColor = .white
                    self?.editProfileFollowButton.setTitleColor(.black, for: .normal)
                }
            }
        }
    }
    
    fileprivate func setupFollowStyle(){
        self.editProfileFollowButton.setTitle("Follow", for: .normal)
        self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editProfileFollowButton.setTitleColor(.white, for: .normal)
        self.editProfileFollowButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        return imageView
    }()
    
    let gridButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"grid"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    let listButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    let usernameLabel:UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    let postsLabel:UILabel = {
        let label = UILabel()
        
        let firstString = NSAttributedString(string: "0\n",attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        let secondString = NSAttributedString(string: "following",attributes: [.foregroundColor : UIColor.lightGray,.font : UIFont.boldSystemFont(ofSize: 14)])
        let combinedString = NSMutableAttributedString(attributedString: firstString)
        
        combinedString.append(secondString)
        label.attributedText = combinedString
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let followersLabel:UILabel = {
        let label = UILabel()
        let firstString = NSAttributedString(string: "0\n",attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        let secondString = NSAttributedString(string: "following",attributes: [.foregroundColor : UIColor.lightGray,.font : UIFont.boldSystemFont(ofSize: 14)])
        let combinedString = NSMutableAttributedString(attributedString: firstString)
        
        combinedString.append(secondString)
        label.attributedText = combinedString
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let followingLabel:UILabel = {
        let label = UILabel()
        let firstString = NSAttributedString(string: "0\n",attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        let secondString = NSAttributedString(string: "following",attributes: [.foregroundColor : UIColor.lightGray,.font : UIFont.boldSystemFont(ofSize: 14)])
        let combinedString = NSMutableAttributedString(attributedString: firstString)
        
        combinedString.append(secondString)
        label.attributedText = combinedString
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    lazy var editProfileFollowButton:UIButton = {
        let button = UIButton()
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)

        profileImageView.layer.cornerRadius = 80/2
        profileImageView.clipsToBounds = true
        
        setupBottomToolBar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        setupUsersStatsView()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        
    }
    
    fileprivate func setupUsersStatsView(){
        let stackView = UIStackView(arrangedSubviews: [postsLabel,followersLabel,followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    fileprivate func setupBottomToolBar(){
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton,listButton,bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
