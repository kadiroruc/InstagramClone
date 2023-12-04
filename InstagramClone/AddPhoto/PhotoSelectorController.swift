//
//  PhotoSelectorController.swift
//  InstagramClone
//
//  Created by Abdulkadir Oruç on 12.10.2023.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"
private let headerIdentifier = "Header"

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavigationButtons()
        collectionView.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        fetchPhotos()
        
    }
    
    var selectedImage:UIImage?
    var images = [UIImage]()
    var assets = [PHAsset]()
    
    fileprivate func fetchPhotos(){
        let fetchingOptions = PHFetchOptions()
        fetchingOptions.fetchLimit = 30
        fetchingOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate" , ascending: false)]
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchingOptions)
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { asset, count, stop in

                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) {[weak self] image, info in
                    self?.assets.append(asset)
                    if let image = image{
                        self?.images.append(image)
                        if self?.selectedImage == nil{
                            self?.selectedImage = image
                        }
                        if count == allPhotos.count - 1{
                            DispatchQueue.main.async {
                                self?.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }

    fileprivate func setupNavigationButtons(){
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    @objc func handleCancel(){
        dismiss(animated: true)
    }
    @objc func handleNext(){
        let sharePhotoVC = SharePhotoController()
        sharePhotoVC.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(sharePhotoVC, animated: true)
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoSelectorCell
        cell.photoImageView.image = images[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width-3)/4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    var header: PhotoSelectorHeader?
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! PhotoSelectorHeader
        self.header = header
        
        if let selectedImage = selectedImage{
            if let index = images.index(of: selectedImage){
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { image, info in
                    header.photoImageView.image = image
                }
            }
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        collectionView.reloadData()
        
        let indexpath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexpath, at: .bottom, animated: true)
    }
}
