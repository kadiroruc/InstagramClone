//
//  HomePostCell.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 25.10.2023.
//

import UIKit

protocol HomePostCellDelegate{
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell{
    
    var delegate: HomePostCellDelegate?
    
    var post: Post?{
        didSet{
            guard let postImageUrl = post?.imageUrl else {return}
            likeButton.setImage(post?.hasLiked == true ? UIImage(named: "like_selected")?.withRenderingMode(.alwaysOriginal) : UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
            
            photoImageView.loadImage(urlString: postImageUrl)
            
            usernameLabel.text = post?.user.username
            guard let profileImageView = post?.user.profileImageUrl else {return}
            userProfileImageView.loadImage(urlString: profileImageView)
            
            setupAttributedCaption()
        }
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let optionsButton: UIButton = {
        let button = UIButton()
        button.setTitle("...", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 44)
        return button
    }()
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    @objc func handleLike(){
        delegate?.didLike(for: self)
    }
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "comment")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    let sendMessageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "send2")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    let bookmarkMessageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ribbon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    @objc func handleComment(){
        guard let post = self.post else {return}
        delegate?.didTapComment(post: post)
    }
    
    fileprivate func setupAttributedCaption(){
        guard let post = self.post else {return}
        
        let firstString = NSAttributedString(string: post.user.username ,attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
        let secondString = NSAttributedString(string: "  \(post.caption)",attributes: [.font : UIFont.systemFont(ofSize: 14)])
        let thirdString = NSAttributedString(string: "\n\n",attributes: [.font: UIFont.systemFont(ofSize: 4)]) //small gap
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        let fourthString = NSAttributedString(string: timeAgoDisplay,attributes: [.font: UIFont.systemFont(ofSize: 14),.foregroundColor: UIColor.gray])

        let combinedString = NSMutableAttributedString(attributedString: firstString)

        combinedString.append(secondString)
        combinedString.append(thirdString)
        combinedString.append(fourthString)
        
        captionLabel.attributedText = combinedString
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(userProfileImageView)
        addSubview(photoImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        userProfileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        optionsButton.anchor(top: topAnchor, left: nil, bottom: photoImageView.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 44, height: 0)
        
        usernameLabel.anchor(top: topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    
        setupActionButtons()
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

    }
    fileprivate func setupActionButtons(){
        let stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,sendMessageButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 120, height: 40)
        
        addSubview(bookmarkMessageButton)
        bookmarkMessageButton.anchor(top: photoImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 30)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
