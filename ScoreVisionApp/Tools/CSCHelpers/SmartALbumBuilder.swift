//
//  SmartALbumBuilder.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import PromiseKit
import Photos
import CoreLocation

extension KMCSCThemeBuilder.SmartAlbumType: ThemeProvider {
    
    // MARK: - ThemeProvider Conformance
    var themePromise: Promise<CurationTheme> {
        switch self {
        case .getTheme(let phassetCollectionSubType, let periodPredicate, let justFavorites, let sortDescriptors, let localytics):
            return self.getAlbum(subType: phassetCollectionSubType, justFavorites: justFavorites, from: periodPredicate, sortDescriptors: sortDescriptors, localytics: localytics)
            //        default:
            //            return Promise { f, r in
            //                f(CurationTheme(title: "nothing", logString: "nothing", potentialAssets: []))
            //            }
        }
    }
    /// Use this variable for [theme]
    var themesPromise: Promise<[CurationTheme]> {
        switch self {
        default:
            return Promise { f, r in
                f([])
            }
        }
    }
    
    internal func constructPeriodPredicate(from period: [Date]) -> NSPredicate {
        print("KMCSDateManager period = \(period) ")
        if let startDate = period.first, let endOfDate = period.last {
            return NSPredicate(format: "creationDate >= %@ AND creationDate < %@", startDate as NSDate, endOfDate as NSDate)
        } else {
            /// if dates are nil return current day, just to avoid potential crashes
            return NSPredicate(format: "creationDate >= %@ AND creationDate < %@", Date() as NSDate, Date() as NSDate)
        }
    }
    
    // MARK: - Want an specific album? use one of this PHAssetCollectionSubtype to get specific album
    /// It also can filter from just ones marked as favorites from a certain period
    
    /// .smartAlbumSelfPortraits = Selfies album
    /// .smartAlbumFavorites = Favorites album
    /// .smartAlbumLivePhotos = Live Photos album
    /// .smartAlbumDeptheffect = Portrait album
    /// .smartAlbumRecentlyAdded = Recently Added album
    /// .smartAlbumUserLibrary = All Smart albums available (all photos)
    /// .smartAlbumPanorama = Photos from Panorama album
    /// .smartAlbumLivePhotos = Live Photos
    
    // Keys to explore:
    
    /// .smartAlbumAllHidden = returns album with hidden images?
    /// .smartAlbumUserLibrary = opposed to assets from iCloud Shared Albums ?
    /// .albumCloudShared = An iCloud Shared Photo Stream.
    /// .albumMyPhotoStream = The user’s personal iCloud Photo Stream.
    /// .smartAlbumLongExposures
    
    private func getAlbum(subType: PHAssetCollectionSubtype, justFavorites: Bool, from period: KMCSDateManager, sortDescriptors: [SortProvider], localytics: KMCSCMFYLocaytics?) -> Promise<CurationTheme> {
        
        return Promise { fullfill, reject in
            
            DispatchQueue.global(qos: .background).async {
                let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subType, options: nil)
                guard let assetCollection = smartAlbum.firstObject else {
                    reject(KMCSCError.noAlbumForSubtype(type: subType.themeTitle))
                    return
                }
                let options = PHFetchOptions.init()
                var predicates: [NSPredicate] = []
                let periodPredicate = self.constructPeriodPredicate(from: period.period)
                let subTypePredicate = subType.predicate
                predicates.append(periodPredicate)
                predicates.append(subTypePredicate)
                
                if justFavorites {
                    let isFavoritePredicate = NSPredicate(format: "isFavorite == %d",  1 as CVarArg)
                    predicates.append(isFavoritePredicate)
                }
                
                let compound = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                options.predicate = compound
                options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
                let assetResult = PHAsset.fetchAssets(in: assetCollection, options: options)
                let assets = KMCSCThemeBuilder.filterSimilarTimeStapAssets(from: assetResult, compare: 5)
  
                /// Construct the AlbumTheme
                let mFYAlbumTheme = MFYAlbumTheme(albumThemeTitle: nil, albumThemeType: subType.themeTitle, periodThemeTitle: period.periodThemeTitle)
                
                /// here we may want that the CurationTheme has a property of type MFYAlbumTheme instead of passing the strings
                /// this is for Localytics
                let localyticsEventString = localytics?.eventString ?? ""
                
                let curationTheme = CurationTheme(title: mFYAlbumTheme.mFYAlbumThemeTitle,subTitle: "",logString: localyticsEventString, potentialAssets: assets, uniqueID: mFYAlbumTheme.mFYAlbumUniqueID)
                
                DispatchQueue.main.async {
                    if curationTheme.potentialAssets.count > 0 {
                        fullfill(curationTheme)
                    } else {
                        reject(KMCSCError.noPotentialAssets)
                        print("KMCRecursive \(KMCSCError.noPotentialAssetsFor(theme: curationTheme.title))")
                    }
                }
            }
        }
    }
}


enum DateRoundingType {
    case round
    case ceil
    case floor
}

extension Date {
    func rounded(minutes: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        return rounded(seconds: minutes * 60, rounding: rounding)
    }
    func rounded(seconds: TimeInterval, rounding: DateRoundingType = .round) -> Date {
        var roundedInterval: TimeInterval = 0
        switch rounding  {
        case .round:
            roundedInterval = (timeIntervalSinceReferenceDate / seconds).rounded() * seconds
        case .ceil:
            roundedInterval = ceil(timeIntervalSinceReferenceDate / seconds) * seconds
        case .floor:
            roundedInterval = floor(timeIntervalSinceReferenceDate / seconds) * seconds
        }
        return Date(timeIntervalSinceReferenceDate: roundedInterval)
    }
}

/* Use this in the future or remove it if we identify a better way to get images based on distance
 private func getNearby(from period: MFYImageTheme, sortDescriptors: [SortProvider]) -> Promise<CurationTheme> {
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
 let curationTheme = CurationTheme(title: "", logString: "", potentialAssets: [])
 nearbyIDs.count > 0 ? fullfill(curationTheme) : reject(KMCSCError.noPotentialAssetsFor(theme: curationTheme.title))
 }
 }
 }
 }
 */
