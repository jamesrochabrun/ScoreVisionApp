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
    case getThemeFromPeriod(periodPredicate: TimePeriod, sortDescriptors: [SortProvider])
    case getThemeFavorite(periodPredicate: TimePeriod, sortDescriptors: [SortProvider])
}

// MARK: Extension for ThemeProvider conformance
extension AssetProvider: ThemeProvider {

    var themePromise: Promise<Theme> {
        switch self {
        case .getThemeFromPeriod(let periodPredicate, let sortDescriptors):
            return self.getTheme(from: periodPredicate, sortDescriptors: sortDescriptors)
        case .getThemeFavorite(let periodPredicate, let sortDescriptors):
            return self.getFavorite(from: periodPredicate, sortDescriptors: sortDescriptors)
        }
    }
    /// 1 getThemeFavorites
    private func getFavorite(from period: TimePeriod, sortDescriptors: [SortProvider]) -> Promise<Theme> {
        return Promise { fullfill, reject in
            //step 1 create the options
            let options = PHFetchOptions.init()
            options.predicate = period.predicate
            options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
            DispatchQueue.global(qos: .background).async {
                // step 2 perform the fetch request for the assets
                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                var favoriteIDs: [String] = []
                assets.enumerateObjects { asset, index, stop in
                    if asset.isFavorite {
                        favoriteIDs.append(asset.localIdentifier)
                    }
                }
                DispatchQueue.main.async {
                    let theme = Theme(title: "Favorites from \(period.caseTitle)", potentialAssets: favoriteIDs, analyzedAssets: [])
                    favoriteIDs.count > 0 ? fullfill(theme) : reject(CSCError.noImages)
                }
            }
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
                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                var assetIDs: [String] = []
                assets.enumerateObjects { asset, index, stop in
                        assetIDs.append(asset.localIdentifier)
                }
                DispatchQueue.main.async {
                    let theme = Theme(title: "Theme time period from \(period.caseTitle)", potentialAssets: assetIDs, analyzedAssets: [])
                    assetIDs.count > 0 ? fullfill(theme) : reject(CSCError.noImages)
                }
            }
        }
    }
    
        
        
        
        
        
        
  
