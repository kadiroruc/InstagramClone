//
//  CollectionViewCell.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 7.11.2023.
//

import UIKit

class CommentsCell: UICollectionViewCell {
    var comment: Comment?{
        didSet{
            guard let comment = comment else {return}
            
            let firstString = NSAttributedString(string: comment.user.username, attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
            let secondString = NSAttributedString(string: " " + comment.text,attributes: [.font : UIFont.systemFont(ofSize: 14)])
            let combinedString = NSMutableAttributedString(attributedString: firstString)
            combinedString.append(secondString)
            textView.attributedText = combinedString
            
            profileImageView.loadImage(urlString: comment.user.profileImageUrl)
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        return textView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(textView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40/2
        
        
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
