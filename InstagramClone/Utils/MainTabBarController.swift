//
//  MainTabBarController.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 8.10.2023.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController,UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2{
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: photoSelectorController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            return false
        }else{
            return true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                let loginViewController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginViewController)
                navController.modalPresentationStyle = .fullScreen
                
                self.present(navController,animated: true)

            }
        }

        setupViewControllers()
    }
    
    func setupViewControllers(){
        //home
        let homeNavController = templateNavController(unselectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!,rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //search
        let searchNavController = templateNavController(unselectedImage: UIImage(named: "search_unselected")!, selectedImage: UIImage(named: "search_selected")!,rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))

        //plus
        let plusNavController = templateNavController(unselectedImage: UIImage(named: "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!)
        //like
        let likeNavController = templateNavController(unselectedImage: UIImage(named: "like_unselected")!, selectedImage: UIImage(named: "like_selected")!)
        
        //userProfile
        let profileNavController = templateNavController(unselectedImage: UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!,rootViewController: UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        

        tabBar.tintColor = .black
        tabBar.backgroundColor = .systemGray5
        
        viewControllers = [homeNavController,
                           searchNavController,
                           plusNavController,
                           likeNavController,
                           profileNavController]
        //modify tabbar items insets
        guard let items = tabBar.items else{return}
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage:UIImage, selectedImage:UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController{
        let vc = rootViewController
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
