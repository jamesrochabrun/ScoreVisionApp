//
//  ViewController.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 1/31/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import UIKit
import PromiseKit
import Photos

final class PhotoListController: UIViewController {

    lazy var photoPickerManager: PhotoPickerManager = {
        let manager = PhotoPickerManager(presentingController: self)
        manager.delegate = self
        return manager
    }()
    
    var alternatePhotos: [PHAsset] = [] {
        didSet {
            self.alternatePhotosCollectionView.reloadData()
        }
    }
    
    private let imageManager = PHCachingImageManager()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    @IBOutlet weak var alternatePhotosCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - camera and library picker
extension PhotoListController: PhotoPickerManagerDelegate {
    
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage, asset: PHAsset?) {
        // here is our image from Library or camera
        photoImageView.image = image
        self.classificationLabel.text = "Analaysing..."
        
        // do exampleVerify or exampleDetect
        guard let asset = asset else { return }
        
        // do near dup stuff
        self.alternatePhotos = self.getAlternatePhotosFrom(asset: asset, comparing: 0)
        
        // do Kairos stuff
        //performAnalysisOf(asset: asset)

        manager.dismissPhotoPicker(animated: true, completion: nil)
    }
    
    private func performAnalysisOf(asset: PHAsset) {
        asset.getURL(completionHandler: { url in
            KairosAPI.sharedInstance.exampleDetect(String(describing: url!)).then { text in
                self.classificationLabel.text = text
                }.catch(execute: { err in
                    print("ERROR \(err)")
                    self.classificationLabel.text = "No able to clasify"
                })
        })
    }
    
    @IBAction func launchLibrary(_ sender: UIButton) {
        photoPickerManager.presentPhotoPicker(from: CameraSourceType.librarySource, animated: true)
    }
    
    @IBAction func launchCamera(_ sender: UIButton) {
        photoPickerManager.presentPhotoPicker(from: CameraSourceType.cameraSource, animated: true)
    }
}

/// MARK: - Alternate dups

extension PhotoListController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func getSimilarTimeStampAssets(from collectioAssets: [PHAsset], compare asset: PHAsset, interval: Double ) -> [PHAsset] {
        
        var filteredAssets: [PHAsset] = []
        
        collectioAssets.map {
            print("AP  getSimilarTimeStampAssets date asset \($0.creationDate!)")
        }
        
       var suffix: [PHAsset] = []
        var prefix: [PHAsset] = []
        
//        /// first get index of asset and to fo forward swap the prefix at the end of the array
        if let index = collectioAssets.index(of: asset) {
            prefix = Array(collectioAssets.prefix(upTo: index))
            suffix = Array(collectioAssets.suffix(from: index))
        }
        
        let alternateSuffix = self.getAlternateFrom(suffix: suffix, compare: asset, interval: interval)
        let alternateprefix = self.getAlternateFrom(prefix: prefix, compare: asset, interval: interval)
        
        /// now we need to add one by one the items here
        for asset in alternateSuffix {
            
        }
        
        
        return filteredAssets
    }
    
    private func getAlternateFrom(prefix: [PHAsset], compare asset: PHAsset, interval: Double) -> [PHAsset] {
        
        let staticAssetCreationTime = asset.creationDate?.timeIntervalSince1970
        var startingTime: TimeInterval = asset.creationDate!.timeIntervalSince1970
        
        print("startingTime date \(asset.creationDate!)")
        let _ = prefix.reversed().map {
            print("AP prefix date asset \(String(describing: $0.creationDate))")
        }
        
        var filteredAssets: [PHAsset] = []
        
        for assetT in prefix.reversed() {
            if startingTime - assetT.creationDate!.timeIntervalSince1970 < interval {
                filteredAssets.append(assetT)
                print("ADDED date \(assetT.creationDate!)")
            } else {
                print("NOT added with date \(assetT.creationDate!)")
            }
            startingTime = assetT.creationDate!.timeIntervalSince1970

            let rest = staticAssetCreationTime! - startingTime
            if rest > 40 {
                print("AP startingTime is \(assetT.creationDate!) staticAssetCreationTime is \(String(describing: asset.creationDate)) rest is  \(rest)")
                break
            }
        }
        return filteredAssets
    }
    
    private func getAlternateFrom(suffix: [PHAsset], compare asset: PHAsset, interval: Double) -> [PHAsset] {

        let staticAssetCreationTime = asset.creationDate?.timeIntervalSince1970
        var startingTime: TimeInterval = asset.creationDate!.timeIntervalSince1970

        let _ = suffix.map {
            print("AP suufix date asset \(String(describing: $0.creationDate))")
        }
        var filteredAssets: [PHAsset] = []

        for asset in suffix {
            if asset.creationDate!.timeIntervalSince1970 - startingTime < interval {
                filteredAssets.append(asset)
                print("ADDED date \(asset.creationDate!)")
            } else {
                print("NOT added with date \(asset.creationDate!)")

            }
            startingTime = asset.creationDate!.timeIntervalSince1970
            if startingTime - staticAssetCreationTime! > 40 {
                print("AP startingTime is \(startingTime) staticAssetCreationTime is \(staticAssetCreationTime!) rest is  \(startingTime - staticAssetCreationTime!)")
                break
            }
        }
        return filteredAssets
    }
    
    func getAlternatePhotosFrom(asset: PHAsset, comparing interval: Double) -> [PHAsset] {
        
        var collectionAssets: [PHAsset] = []
        
        /// get the collection of the asset to avoid fetching all photos or create a mmmm binary search in all assets

        let collections = PHAssetCollection.fetchAssetCollectionsContaining(asset, with: .moment, options: nil)
        
        print("AP Collections Count \(collections.count)")
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        for i in 0..<collections.count {
            let collection = collections[i]
            print("AP Collection \(String(describing: collection.localizedTitle))")
            let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: options)
            for i in 0..<collection.estimatedAssetCount {
                let asset = assetsFetchResult[i]
                collectionAssets.append(asset)
            }
        }

        let filteredPhotos = self.getSimilarTimeStampAssets(from: collectionAssets, compare: asset, interval: 10)
        return filteredPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
       // let cell: AlternatePhotoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .fast
        options.isSynchronous = true
        let asset = alternatePhotos[indexPath.row]
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options, resultHandler: { response, options in
            if let image = response {
               // cell.photoImageView.image = image
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
                imageView.image = image
                imageView.contentMode = .scaleAspectFill
                cell.backgroundView = imageView
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.alternatePhotos.count
    }
    

}













