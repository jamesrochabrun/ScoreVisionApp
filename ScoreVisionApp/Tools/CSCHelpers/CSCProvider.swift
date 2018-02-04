//
//  CSCProvider.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/1/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit
import Photos
import PromiseKit
import CoreLocation

// MARK: - protocol
protocol ThemeProvider {
    var themePromise: Promise<Theme> { get }
}

// MARK: - Enum that returns Assets based on query
enum AssetProvider {
    case getThemeFromPeriod(periodPredicate: TimePeriod, sortDescriptors: [SortProvider])
    case getThemeFavorite(periodPredicate: TimePeriod, sortDescriptors: [SortProvider])
    case getThemeNearby(periodPredicate: TimePeriod, sortDescriptors: [SortProvider])
    case getSmartAlbum(subType: PHAssetCollectionSubtype, periodPredicate: TimePeriod, sortDescriptors: [SortProvider])
}

// MARK: Extension for ThemeProvider conformance
extension AssetProvider: ThemeProvider {

    var themePromise: Promise<Theme> {
        switch self {
        case .getThemeFromPeriod(let periodPredicate, let sortDescriptors):
            return self.getTheme(from: periodPredicate, sortDescriptors: sortDescriptors)
        case .getThemeFavorite(let periodPredicate, let sortDescriptors):
            return self.getFavorite(from: periodPredicate, sortDescriptors: sortDescriptors)
        case .getThemeNearby(let periodPredicate, let sortDescriptors):
            return self.getNearby(from: periodPredicate, sortDescriptors: sortDescriptors)
        case .getSmartAlbum(let phassetCollectionType, let periodPredicate, let sortDescriptors):
            return self.getAlbum(subType: phassetCollectionType, from: periodPredicate, sortDescriptors: sortDescriptors)
        }
    }
    
    
    
    /// 1 getThemeFromPeriod
    private func getTheme(from period: TimePeriod, sortDescriptors: [SortProvider]) -> Promise<Theme> {
        return Promise { fullfill, reject in
            //step 1 create the options
            let options = PHFetchOptions.init()
            options.predicate = period.predicate
            options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
            DispatchQueue.global(qos: .background).async {
                // step 2 perform the fetch request for the assets
                let assets = self.getAssetsFom(type:  PHAssetMediaType.image, with: options)
                DispatchQueue.main.async {
                    let theme = Theme(title: "Theme time period from \(period.caseTitle)", potentialAssets: assets, analyzedAssets: [])
                    assets.count > 0 ? fullfill(theme) : reject(CSCError.noImages)
                }
            }
        }
    }
    
    /// 2 getThemeFavorites
    private func getFavorite(from period: TimePeriod, sortDescriptors: [SortProvider]) -> Promise<Theme> {
        return Promise { fullfill, reject in
            //step 1 create the options
            let options = PHFetchOptions.init()
            let predicate1 = period.predicate
            let predicate2 = NSPredicate(format: "isFavorite == %d",  1 as CVarArg)
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
            options.predicate = compound
            options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
            DispatchQueue.global(qos: .background).async {
                // step 2 perform the fetch request for the assets
                let assets = self.getAssetsFom(type: PHAssetMediaType.image, with: options)
                DispatchQueue.main.async {
                    let theme = Theme(title: "Favorites from \(period.caseTitle)", potentialAssets: assets, analyzedAssets: [])
                    assets.count > 0 ? fullfill(theme) : reject(CSCError.noImages)
                }
            }
        }
    }
    
    private func getAssetsFom(type: PHAssetMediaType, with options: PHFetchOptions) -> [PHAsset] {
        var assets: [PHAsset] = []
        PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options).enumerateObjects { (asset,_,_) in
            assets.append(asset)
        }
        return assets
    }
    
    /// 3 get nearby them
    private func getNearby(from period: TimePeriod, sortDescriptors: [SortProvider]) -> Promise<Theme> {
        return Promise { fullfill, reject in
            //step 1 create the options
            let options = PHFetchOptions.init()
            options.predicate = period.predicate
            options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
            DispatchQueue.global(qos: .background).async {
                // step 2 perform the fetch request for the assets
                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                var nearbyIDs: [String] = []
                assets.enumerateObjects { asset, index, stop in
                    if let location = asset.location {
                        //testing
                        let dummLocation = CLLocation(latitude: 37.89301333, longitude: -122.12200283)
                        let meters = dummLocation.distance(from: location)
                        if meters >= 200 {
                            nearbyIDs.append(asset.localIdentifier)
                        }
                    }
                }
                DispatchQueue.main.async {
                    let theme = Theme(title: "Nearby from \(period.caseTitle)", potentialAssets: [], analyzedAssets: [])
                    nearbyIDs.count > 0 ? fullfill(theme) : reject(CSCError.noImages)
                }
            }
        }
    }
    
    // 4 get smart albums

    func getAlbum(subType: PHAssetCollectionSubtype, from period: TimePeriod, sortDescriptors: [SortProvider]) -> Promise<Theme> {
        
        return Promise { fullfill, reject in
            
            DispatchQueue.global(qos: .background).async {
                let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subType, options: nil)
                guard let assetCollection = smartAlbum.firstObject
                    else { fatalError("expected asset collection") }
                var assets: [PHAsset] = []
                let options = PHFetchOptions.init()
                options.predicate = period.predicate
                options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
                PHPhotoLibrary.shared().performChanges({
                    let assetResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                    assetResult.enumerateObjects { asset, index, stop in
                        assets.append(asset)
                    }
                }, completionHandler: {success, error in
                    DispatchQueue.main.async {
                        let theme = Theme(title: "Smart album in \(period.caseTitle)", potentialAssets: assets, analyzedAssets: [])
                        assets.count > 0 ? fullfill(theme) : reject(CSCError.noImages)
                    }
                })
            }
        }
    }
}







//
//func fetchCustomAlbumPhotos() -> Promise<[UIImage]>  {
//
//    return Promise { fullfill, reject in
//
//        let albumName = "Zomato"
//        var assetCollection = PHAssetCollection()
//        var albumFound = Bool()
//        var images: [UIImage] = []
//
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
//        let collection: PHFetchResult =  PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//
//        if let firstObject: AnyObject = collection.firstObject {
//            //found the album
//            assetCollection = firstObject as! PHAssetCollection
//            albumFound = true
//        } else {
//            albumFound = false
//
//        }
//        let photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil)
//        //  let imageManager = PHCachingImageManager()
//        let imageManager = PHImageManager.default()
//
//        photoAssets.enumerateObjects{(object: AnyObject!,
//            count: Int,
//            stop: UnsafeMutablePointer<ObjCBool>) in
//
//            if object is PHAsset {
//                let asset = object as! PHAsset
//                let imageSize = CGSize(width: asset.pixelWidth,
//                                       height: asset.pixelHeight)
//
//                let options = PHImageRequestOptions()
//                options.version = .current
//                options.resizeMode = .fast
//                options.isSynchronous = true
//                imageManager.requestImage(for: asset,
//                                          targetSize: imageSize,
//                                          contentMode: .aspectFill,
//                                          options: options,
//                                          resultHandler: {
//                                            (imageResult, info) -> Void in
//                                            guard let image = imageResult else {
//                                                reject(CSCError.invalidImage)
//                                                return
//                                            }
//                                            images.append(image)
//                })
//            }
//        }
//        fullfill(images)
//    }
//
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

        
        
        
        
        

