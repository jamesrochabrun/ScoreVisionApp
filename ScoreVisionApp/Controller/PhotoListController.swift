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
        self.alternatePhotos = asset.getAlternatePhotos()
        
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
    
    func getSimilarTimeStampAssets(in assetFetchResult: PHFetchResult<PHAsset>, comparing asset: PHAsset, interval: Double ) -> [PHAsset] {
        
        var suffix: [PHAsset] = []
        var prefix: [PHAsset] = []
        var assets: [PHAsset] = []
        
        let index = assetFetchResult.index(of: asset)
        
        for i in 0..<assetFetchResult.count {
            let asset = assetFetchResult[i]
            assets.append(asset)
        }
        
        prefix = Array(assets.prefix(upTo: index))
        suffix = Array(assets.suffix(from: index))
        
        let alternateSuffix = self.getAlternatesIn(suffix: suffix, compare: asset, interval: interval)
        let alternatePrefix = self.getAlternatesIn(prefix: prefix, compare: asset, interval: interval)
        
        ///Alternate results?
        return self.mergeFunction(alternateSuffix, alternatePrefix)
    }
    
//    var arr1 = [1, 2, 3]
//    var arr2 = [4, 5, 6, 7]
//
//    let initialCount = arr1.count
//
//    for i in 0..<arr2.count {
//    if i < initialCount {
//    arr1.insert(arr2[i], at: (2*i) + 1)
//    } else {
//    arr1.append(arr2[i])
//    }
//    }
    
    func mergeFunction<T>(_ one: [T], _ two: [T]) -> [T] {
        let commonLength = min(one.count, two.count)
        return zip(one, two).flatMap { [$0, $1] }
            + one.suffix(from: commonLength)
            + two.suffix(from: commonLength)
    }
    
    private func getAlternatesIn(prefix: [PHAsset], compare asset: PHAsset, interval: Double) -> [PHAsset] {
        
        let staticAssetCreationTime = asset.creationDate?.timeIntervalSince1970
        var startingTime: TimeInterval = asset.creationDate!.timeIntervalSince1970
        print("startingTime date - original from asset \(asset.creationDate!)")
        
        let _ = prefix.reversed().map {
            print("prefix date asset \(String(describing: $0.creationDate))")
        }
        
        var filteredAssets: [PHAsset] = []
        
        for localAsset in prefix.reversed() {
            if startingTime - localAsset.creationDate!.timeIntervalSince1970 < interval {
                filteredAssets.append(localAsset)
                print("added From prefix - \(localAsset.creationDate!)")
            } else {
                print("not added From prefix - \(localAsset.creationDate!)")
            }
            startingTime = localAsset.creationDate!.timeIntervalSince1970
            let minPeriodInterval = staticAssetCreationTime! - startingTime
            if minPeriodInterval > 40 { //40 seconds window?
                print("startingTime is \(localAsset.creationDate!) staticAssetCreationTime is \(String(describing: asset.creationDate)) rest is  \(minPeriodInterval)")
                break
            }
        }
        return filteredAssets
    }
    
    private func getAlternatesIn(suffix: [PHAsset], compare asset: PHAsset, interval: Double) -> [PHAsset] {

        let staticAssetCreationTime = asset.creationDate?.timeIntervalSince1970
        var startingTime: TimeInterval = asset.creationDate!.timeIntervalSince1970
        print("startingTime date - original from asset \(asset.creationDate!)")

        let _ = suffix.map {
            print("sufix date asset \(String(describing: $0.creationDate))")
        }
        var filteredAssets: [PHAsset] = []
        for asset in suffix {
            if asset.creationDate!.timeIntervalSince1970 - startingTime < interval {
                filteredAssets.append(asset)
                print("added From sufix -\(asset.creationDate!)")
            } else {
                print("not added From sufix - \(asset.creationDate!)")
            }
            startingTime = asset.creationDate!.timeIntervalSince1970
            let minPeriodInterval = startingTime - staticAssetCreationTime!
            if  minPeriodInterval > 40 { // 40 seconds window?
                print("startingTime is \(startingTime) staticAssetCreationTime is \(staticAssetCreationTime!) rest is  \(startingTime - staticAssetCreationTime!)")
                break
            }
        }
        return filteredAssets
    }
    

    func getAlternatePhotosFor(asset: PHAsset) -> [PHAsset] {
        
        /// get the collection of the asset to avoid fetching all photos
        let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsContaining(asset, with: .moment, options: nil)
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        guard let collection =  collectionFetchResult.firstObject else { return [] }
        print("Collection Localized title \(String(describing: collection.localizedTitle))")
        
        let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: options)

        let filteredPhotos = self.getSimilarTimeStampAssets(in: assetsFetchResult, comparing: asset, interval: 10)
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













