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
                    //step 3 do whatever we need here
                    // start anaylisis?
                    DispatchQueue.main.async {
                        // step 4 return The struct ?
                        assets.count > 0 ? fullfill(self.createAndReturnTheme(with: assets, titleTheme: "")) : reject(CSCError.noImages)
                    }
                }
            }
        }
    }
    
    private func createAndReturnTheme(with assets: PHFetchResult<PHAsset>, titleTheme: String) -> Theme {
        var potentialAssetIdentifiers: [String] = []
        assets.enumerateObjects { asset, index, stop in
                potentialAssetIdentifiers.append(asset.localIdentifier)
                print("asset \(asset.localIdentifier)")
        }
        return Theme(title: titleTheme, potentialAssets: potentialAssetIdentifiers, analyzedAssets: [])
    }
}






















