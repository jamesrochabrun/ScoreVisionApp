//
//  ViewController.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 1/31/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import UIKit
import Photos
import PromiseKit

final class PhotoListController: UIViewController {

    lazy var photoPickerManager: PhotoPickerManager = {
        let manager = PhotoPickerManager(presentingController: self)
        manager.delegate = self
        return manager
    }()
    
    lazy var photoListControllerDatasource: PhotoListControllerDatasource = {
        return PhotoListControllerDatasource(images: [])
    }()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var countLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoCollectionView.dataSource = photoListControllerDatasource
        
//        AssetProvider.getThemeFavorite(periodPredicate: .oneMonthAgo, sortDescriptors: [.creationDate]).themePromise.then { theme in
//           // dump(theme)
//            self.updateCollection(theme)
//            }.catch { err in
//                print("the error is \(err)")
//        }
        
        AssetProvider.getSmartAlbum(subType: .smartAlbumFavorites, periodPredicate: .oneMonthAgo, sortDescriptors: [.creationDate]).themePromise.then { theme in
            self.updateCollection(theme)
            }.catch { error in
                print("the error here is that \(error)")
        }
    }
    
    // helper for testing
    private func updateUI(_ images: [UIImage]) {
        self.countLabel.text = "count of images = \(images.count)"
        self.photoListControllerDatasource.updateData(images: images)
        self.photoCollectionView.reloadData()
    }
    
    @IBAction func launchLibrary(_ sender: UIButton) {
        photoPickerManager.presentPhotoPicker(from: CameraSourceType.librarySource, animated: true)
    }
    
    @IBAction func launchCamera(_ sender: UIButton) {
        photoPickerManager.presentPhotoPicker(from: CameraSourceType.cameraSource, animated: true)
    }
}

class PhotoListControllerDatasource: NSObject, UICollectionViewDataSource {
    
    private var images: [UIImage] = []
    
     init(images: [UIImage]) {
        self.images = images
        super.init()
    }
    
    func updateData(images: [UIImage]) {
        self.images = images
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
}

extension PhotoListController: PhotoPickerManagerDelegate {
    
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage) {
        // here is our image from Library or camera
        photoImageView.image = image
        manager.dismissPhotoPicker(animated: true) {
            print("dismiss")
        }
    }
}

// MARK: - Use this just for test result images
extension PhotoListController {
    
    private func updateCollection(_ theme: Theme) {
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .fast
        options.isSynchronous = false
        
        for asset in theme.potentialAssets {
            print("KMTEST \(asset.isFavorite)")
        }
        
        
        self.createAndReturnImages(with :theme.potentialAssets, options: options).then { images in
            self.updateUI(images)
            }.catch { error in
                print("the error here is \(error)")
        }
    }
    
    private func createAndReturnImages(with assets: [PHAsset], options: PHImageRequestOptions) -> Promise<[UIImage]> {
        return Promise { fullfill, reject in
            var images: [UIImage] = []
            let _ = assets.map {
                PHImageManager.default().requestImage(for: $0, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: options, resultHandler: { response, options in
                    guard let image = response else {
                        print("Big error here")
                        reject(CSCError.invalidImage)
                        return
                    }
                    images.append(image)
                })
            }
            DispatchQueue.main.async {
                fullfill(images)
            }
        }
    }
}
