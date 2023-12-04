//
//  SharePhotoController.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 21.10.2023.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    var selectedImage: UIImage?{
        didSet{
            self.imageView.image = selectedImage
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
        
    }
    @objc func handleShare(){
        guard let caption = textView.text, caption.count > 0 else{return}
        guard let image = selectedImage else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.5)else {return}
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        storageRef.putData(uploadData) {[weak self] metadata, error in
            if let error = error{
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                }
                print("Failed to upload post image",error)
                return
            }
            storageRef.downloadURL { url, error in
                if let imageUrl = url{
                    self?.saveToDatabaseWithImageURL(imageUrl: imageUrl.absoluteString)
                }
            }
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    fileprivate func saveToDatabaseWithImageURL(imageUrl:String){
        guard let caption = textView.text else {return}
        guard let image = selectedImage else {return}
        guard let uid = Auth.auth().currentUser?.uid else{return}
        let databaseRef = Database.database().reference().child("posts").child(uid)
        let postRef = databaseRef.childByAutoId()
        let values = ["imageUrl":imageUrl, "caption":caption,"imageWidth":image.size.width,"imageHeight":image.size.height,"creationDate":Date().timeIntervalSince1970] as [String:Any]
        
        postRef.updateChildValues(values) {[weak self] error, ref in
            if let err = error{
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                }
                print("Failed to save post to db",err)
                return
            }
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
                
                NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
            }
        }
    }
    
    fileprivate func setupImageAndTextViews(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
    }
    
}
