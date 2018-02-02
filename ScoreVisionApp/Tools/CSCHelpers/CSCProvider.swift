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
    var promise: Promise<Int> { get }
}

// MARK: - Enum that returns Assets based on query
enum AssetProvider {
    case getAssetsWith(predicate: PredicateTheme, sortDescriptors: [SortProvider])
} 

// MARK: Extension for ThemeProvider conformance
extension AssetProvider: ThemeProvider {
    var promise: Promise<Int> {
        switch self {
        case .getAssetsWith(let predicateTheme, let sortDescriptors):
            return Promise { fullfill, reject in
                let options = PHFetchOptions.init()
                options.predicate = predicateTheme.predicate
                options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
                DispatchQueue.global(qos: .background).async {
                    let images = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                    DispatchQueue.main.async {
                        images.count > 0 ? fullfill(images.count) : reject(CSCError.noImages)
                    }
                }
            }
        }
    }
}






















