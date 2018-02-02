//
//  ViewController.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 1/31/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import UIKit


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
        
        AssetProvider.getThemeFavorite(periodPredicate: .oneMonthAgo, sortDescriptors: [.creationDate]).themePromise.then { theme in
            dump(theme)
            }.catch { err in
                print("The error is \(err)")
        }
    }
    
    
    private func updateCollection(_ images: [UIImage]) {
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
