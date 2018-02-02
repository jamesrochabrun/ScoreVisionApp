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

// MARK: - protocol
protocol ThemeProvider {
    var themePromise: Promise<Theme> { get }
}

// MARK: - Enum that returns Assets based on query
enum AssetProvider {
    case getThemeFrom(predicate: PredicateTheme, sortDescriptors: [SortProvider])
}

// MARK: Extension for ThemeProvider conformance
extension AssetProvider: ThemeProvider {
    
    var themePromise: Promise<Theme> {
        switch self {
        case .getThemeFrom(let predicateTheme, let sortDescriptors):
            return Promise { fullfill, reject in
                //step 1 create the options
                let options = PHFetchOptions.init()
                options.predicate = predicateTheme.predicate
                options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
                
                DispatchQueue.global(qos: .background).async {
                    // step 2 perform the fetch request
                    let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                    DispatchQueue.main.async {
                        // step 3 return the struct
                        assets.count > 0 ? fullfill(self.createAndReturnTheme(with: assets, titleTheme: "")) : reject(CSCError.noImages)
                    }
                }
            }
        }
    }
    
    //testing
    var imagePromise: Promise<[UIImage]> {
        switch self {
        case .getThemeFrom(let predicateTheme, let sortDescriptors):
            return Promise { fullfill, reject in
                
                //step 1 create the options
                let options = PHFetchOptions.init()
                options.predicate = predicateTheme.predicate
                options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
                
                DispatchQueue.global(qos: .background).async {
                    // step 2 perform the fetch request
                    let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                    self.createAndReturnImages(with: assets).then { images in
                        DispatchQueue.main.async {
                            // step 3 return the struct
                        images.count > 0 ? fullfill(images) : reject(CSCError.noImages)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func createAndReturnTheme(with assets: PHFetchResult<PHAsset>, titleTheme: String) -> Theme {
        var potentialAssetIdentifiers: [String] = []
        assets.enumerateObjects { asset, index, stop in
            potentialAssetIdentifiers.append(asset.localIdentifier)
        }
        return Theme(title: titleTheme, potentialAssets: potentialAssetIdentifiers, analyzedAssets: [])
    }
    
    private func createAndReturnImages(with assets: PHFetchResult<PHAsset>) -> Promise<[UIImage]> {
        
        return Promise { fullfill, reject in
            var images: [UIImage] = []
            assets.enumerateObjects { asset, index, stop in
                let options = PHImageRequestOptions()
                options.version = .current
                options.resizeMode = .fast
                options.isSynchronous = false
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: options, resultHandler: { response, options in
                    guard let image = response else {
                        print("Big error here")
                        reject(CSCError.noImages)
                        return
                    }
                    images.append(image)
                })
            }
            fullfill(images)
        }
    }
    

}






















