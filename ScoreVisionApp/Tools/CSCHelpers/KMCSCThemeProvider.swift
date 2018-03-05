//
//  KMCSCThemeProvider.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.

import PromiseKit
import Photos
import CoreLocation
import UIKit


// MARK: - protocol, used on nested enums
protocol ThemeProvider {
    var themePromise: Promise<CurationTheme> { get }
    var themesPromise: Promise<[CurationTheme]> { get }
    func constructPeriodPredicate(from period: [Date]) -> NSPredicate
}

// MARK: - Main Theme Builder it has 3 main cases based on PHAssetCollectionType Constants
/// https://developer.apple.com/documentation/photos/phassetcollectiontype

enum KMCSCThemeBuilder {
    
    // album: an Album in the Photos App
    /// fetch assetes like custom albums, currently unused
    enum AlbumType {}
    // smartAlbum: A smart album whose contents update dynamically.
    /// fetch assets from smart albums like, selfies, favorites, live photos,
    enum SmartAlbumType {
        /// fetch asstes from smart albums like, selfies, favorites, live photos,
        case getTheme(subType: PHAssetCollectionSubtype, period: KMCSDateManager, justFavorites: Bool, sortDescriptors: [SortProvider], localytics: KMCSCMFYLocaytics?)
        
    }
    // moment: A moment in the Photos app.
    /// for now just fetch random album from moments albums
    enum MomentType {
        // moment: A moment in the Photos app.
        /// for now just fetch random album from moments albums
        case getRandomThemes(qty: Int, localytics: KMCSCMFYLocaytics?)
        case getThemes(subType: PHAssetCollectionSubtype, period: KMCSDateManager, justFavorites: Bool, sortDescriptors: [SortProvider], localytics: KMCSCMFYLocaytics?)
    }
    
    /// filter assets with similar time intervals
    static func filterSimilarTimeStapAssets(from assetResult: PHFetchResult<PHAsset>, compare interval: Double ) -> [PHAsset] {
        
        var previousTime: TimeInterval = 0
        var filteredAssets: [PHAsset] = []
        assetResult.enumerateObjects { asset, index, stop in
            if asset.creationDate!.timeIntervalSince1970 - previousTime > interval {
                filteredAssets.append(asset)
              //  print("ADDED date \(asset.creationDate!)")
            } else {
               // print("NOT added with date \(asset.creationDate!)")
            }
            previousTime = asset.creationDate!.timeIntervalSince1970
        }
        return filteredAssets
    }
}


// MARK: PHAssetCollectionSubtype Extension for ThemeProvider conformance
/// Available Subtypes
extension PHAssetCollectionSubtype {
    
    /// For now just the most used albums in our curation request
    var themeTitle: String {
        switch self {
        case .albumRegular: return ""
        case .smartAlbumSelfPortraits: return "Your Best Selfies"
        case .smartAlbumLivePhotos: return "Your Live Photos"
        case .smartAlbumDepthEffect: return "Your Best Portraits"
        case .smartAlbumRecentlyAdded: return "Recently added"
        case .smartAlbumFavorites: return "Your Favorite Pictures"
        case .smartAlbumPanoramas: return "Your Panoramas"
        case .smartAlbumUserLibrary: return ""
        default:
            return ""
        }
    }
    
    //PHAsset available keys for predicates
    /*
     SELF, localIdentifier, creationDate, modificationDate, mediaType, mediaSubtypes, duration, pixelWidth, pixelHeight, isFavorite (or isFavorite), isHidden (or isHidden), burstIdentifier
     */
    var predicate: NSPredicate {
        return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND isHidden != %d", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue,  1 as CVarArg)
    }
}




