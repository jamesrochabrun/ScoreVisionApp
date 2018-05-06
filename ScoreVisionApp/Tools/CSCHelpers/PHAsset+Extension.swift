//
//  PHAsset+Extension.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 5/5/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import Photos

extension PHAsset  {
    
    // MARK: This returns an array of alternate assets from a PHAsset
    func getAlternatePhotos() -> [PHAsset] {
        
        /// get the collection of the asset to avoid fetching all photos in the library
        let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsContaining(self, with: .moment, options: nil)
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        guard let collection =  collectionFetchResult.firstObject else { return [] }
        print("Collection Localized title \(String(describing: collection.localizedTitle))")
        let assetsFetchResult = PHAsset.fetchAssets(in: collection, options: options)
        let filteredPhotos = getSimilarTimeStampAssets(in: assetsFetchResult, comparing: self, interval: 10)
        return filteredPhotos
    }
    
    /// MARK: -  Helper Methods
    private func getSimilarTimeStampAssets(in assetFetchResult: PHFetchResult<PHAsset>, comparing asset: PHAsset, interval: Double ) -> [PHAsset] {
        
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
        
        let alternateSuffix = getAlternatesIn(suffix: suffix, compare: asset, interval: interval)
        let alternatePrefix = getAlternatesIn(prefix: prefix, compare: asset, interval: interval)
        
        ///Alternate results?
        return self.mergeFunction(alternateSuffix, alternatePrefix)
    }
    
    /// This needs to live in other place, like an array extension
    private func mergeFunction<T>(_ one: [T], _ two: [T]) -> [T] {
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






