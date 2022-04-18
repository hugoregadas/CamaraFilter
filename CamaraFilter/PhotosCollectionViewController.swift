//
//  PhotosCollectionViewController.swift
//  CamaraFilter
//
//  Created by Hugo Regadas on 18/04/2022.
//

import Foundation
import UIKit
import Photos
import RxSwift

class PhotosCollectionViewController : UICollectionViewController {
    //MARK: - Public var
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotoSubject.asObservable()
    }
    //MARK: - Private var
    private var images = [PHAsset]()
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        populatePhotos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.selectedPhotoSubject.onCompleted()
    }
}

//MARK: - Privates methods update UI
private extension PhotosCollectionViewController {
    func populatePhotos() {
        //Adicionamos o weak self, para garantir que não ficamos num retain cycle
        PHPhotoLibrary.requestAuthorization {[weak self] status in
            if status == .authorized {
                //access the photos from photo library
                let assests = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                
                assests.enumerateObjects {(objc, count , stop) in
                    self?.images.append(objc)
                }
                
                self?.images.reverse()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
        
    }
}

//MARK: - CollectionView delegates & dataSouce
extension PhotosCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("Photos collection View Cell is not found")
        }
        
        let asset = self.images[indexPath.row]
        let manager = PHImageManager.default()
        
        manager.requestImage(for: asset, targetSize: cell.photoImageView.frame.size, contentMode: .aspectFit, options: nil) {image, _ in
            
            DispatchQueue.main.async {
                cell.photoImageView.image = image
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedAsset = self.images[indexPath.row]
        let manager = PHImageManager.default()
        
        manager.requestImage(for: selectedAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: nil) { [weak self]image, _ in
            guard let newImage = image else { return }
            self?.selectedPhotoSubject.onNext(newImage)
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
