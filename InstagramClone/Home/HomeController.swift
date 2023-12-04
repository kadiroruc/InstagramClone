//
//  HomeViewController.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 25.10.2023.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName , object: nil)
        

        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        setupNavigationItems()
        fetchAllPosts()

    }
    
    @objc func handleUpdateFeed(){
        handleRefresh()
    }
    @objc func handleRefresh(){
        posts.removeAll()
        fetchAllPosts()
    }
    fileprivate func fetchAllPosts(){
        fetchPosts()
        fetchFollowingUserIds()
    }
        
    fileprivate func fetchFollowingUserIds(){
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(currentUserUid).observeSingleEvent(of: .value) {[weak self] snapshot in
            guard let userIdsDictionary = snapshot.value as? [String:Any] else{return}
            
            userIdsDictionary.forEach { key,value in
                Database.fetchUserWithUID(uid: key) { user in
                    self?.fetchPostWithUser(user: user)
                }
            }
        }
    }
    
    var posts = [Post]()
    fileprivate func fetchPosts(){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        Database.fetchUserWithUID(uid: uid) { user in
            self.fetchPostWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostWithUser(user: User){
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value) {[weak self] snapshot in
            self?.collectionView.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String:Any] else{return}
            print(dictionaries)
            
            dictionaries.forEach { key,value in
                guard let dictionary = value as? [String:Any] else {return}

                var post = Post(user: user,dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else{return}
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value) { snapshot in
                    
                    
                    if let value = snapshot.value as? Int, value == 1{
                        post.hasLiked = true
                    }else{
                        post.hasLiked = false
                    }
                    
                }
                self?.posts.append(post)
                self?.posts.sort(by: { p1, p2 in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                self?.collectionView.reloadData()
            }
        }
    }
    
    func setupNavigationItems(){
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = view.frame.width+166
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        if posts.count > 0 {
            cell.post = posts[indexPath.item]
        }
        cell.delegate = self
        
        return cell
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexpath = collectionView.indexPath(for: cell) else {return}
        var post = self.posts[indexpath.item]
        guard let postId = post.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        let values = [uid:post.hasLiked == true ? 0 : 1]
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { error, ref in
            if let err = error{
                print(err)
                return
            }
            post.hasLiked = !post.hasLiked
            self.posts[indexpath.item] = post
            self.collectionView.reloadItems(at: [indexpath])
        }
        
        
    }
    

}
