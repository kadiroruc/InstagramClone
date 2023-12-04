//
//  ViewController.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 27.09.2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let plusPhotoButton : UIButton = {
        let button = UIButton()
        let icon = UIImage(systemName: "plus.circle")
        button.setImage(icon, for: .normal)
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action:#selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker,animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage{
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.originalImage] as? UIImage{
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        dismiss(animated: true)
        
    }
    
    let emailTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    @objc func handleTextInputChange(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0
        if isFormValid{
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }else{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        } 
    }
    let usernameTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let passwordTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("SignUp", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    let alreadyHaveAccountButton: UIButton={
        let button = UIButton()
        let firstString = NSAttributedString(string: "Already have an account?",attributes: [.font:UIFont.systemFont(ofSize: 14),.foregroundColor:UIColor.lightGray])
        let secondString = NSAttributedString(string: " Sign In",attributes: [.font:UIFont.boldSystemFont(ofSize: 14),.foregroundColor:UIColor.rgb(red: 17, green: 154, blue: 237)])
        let combinedString = NSMutableAttributedString(attributedString: firstString)
        combinedString.append(secondString)
        button.setAttributedTitle(combinedString, for: .normal)
        
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    @objc func handleAlreadyHaveAccount(){
        _ = navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        setViews()
    }
    
    func setViews(){
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 80, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        
        plusPhotoButton.imageView?.heightAnchor.constraint(equalToConstant: 140).isActive = true
        plusPhotoButton.imageView?.widthAnchor.constraint(equalToConstant: 140).isActive = true
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 50)
        
    }
    
    fileprivate func setupInputFields(){
        let stackView = UIStackView(arrangedSubviews: [emailTextField,usernameTextField,passwordTextField,signUpButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
    
    @objc func handleSignUp(){
        guard let email = emailTextField.text, email.count > 0 else{return}
        guard let password = passwordTextField.text, password.count > 0 else{return}
        guard let username = usernameTextField.text, username.count > 0 else{return}
        
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if let error = error{
                print("Failed to create user",error)
                return
            }
            
            guard let image = self.plusPhotoButton.imageView?.image else{return}
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else{return}
            let filename = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData) { metadata, error in
                if let error = error{
                    print(error)
                    return
                }
                storageRef.downloadURL { url, error in
                    if let imageUrl = url{
                        let profileImageUrl = imageUrl.absoluteString
                        
                        guard let uid = user?.user.uid else{return}
                        let dictionaryValues = ["username":username, "profileImageUrl":profileImageUrl]
                        let values = [uid:dictionaryValues]

                        Database.database().reference().child("users").updateChildValues(values,withCompletionBlock: { err, ref in
                            if let err = error{
                                print("Failed to save user info into db")
                                return
                            }
                            print("Sucessfully saved user info into db")
//                            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
//                            mainTabBarController.setupViewControllers()
//
                            self.dismiss(animated: true)
                        })
                    }
                }
            }
        }
    }
}


