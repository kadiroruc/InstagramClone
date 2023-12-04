//
//  CustomImageView.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 24.10.2023.
//

import UIKit
var imageCache = [String:UIImage]()

class CustomImageView: UIImageView{
    
    var lastURLUsedtoLoadImage: String?
    func loadImage(urlString: String){
        lastURLUsedtoLoadImage = urlString
        
        self.image = nil
        
//        if let cachedImage = imageCache[urlString]{
//            self.image = image
//            return
//        }
        
        guard let imageUrl = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: imageUrl) {[weak self] data, response, error in
            if let err = error{
                print("Failed to catch post image",err)
                return
            }
            if imageUrl.absoluteString != self?.lastURLUsedtoLoadImage{
                return
            }
            guard let data = data else {return}
            
            guard let image = UIImage(data: data) else {return}
            
            imageCache[imageUrl.absoluteString] = image
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}
