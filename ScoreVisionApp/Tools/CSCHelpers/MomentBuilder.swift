//
//  MomentBuilder.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import PromiseKit
import Photos
import CoreLocation

extension KMCSCThemeBuilder.MomentType: ThemeProvider {
    
    var themePromise: Promise<CurationTheme> {
        switch self {
        default:
            return Promise { f, r in
                f(CurationTheme(title: "nothing you call the wrong promise",subTitle: "", logString: "use themesPromise", potentialAssets: [], uniqueID: ""))
            }
        }
    }
    
    var themesPromise: Promise<[CurationTheme]> {
        switch self {
        case .getThemes(let subType, let period, let justFavorites, let sortDescriptors, let localytics):
            return self.momentsTheme(subType: subType, period: period, justFavorites: justFavorites, sortDescriptors: sortDescriptors, localytics: localytics)
        case .getRandomThemes(let qty, let localytics):
            return self.randomMomentThemes(qty: qty, localytics: localytics)
            //        default:
            //            return Promise { f, r in
            //                f([])
            //            }
        }
    }
    
    internal func constructPeriodPredicate(from period: [Date]) -> NSPredicate {
        print("KMCSDateManager period = \(period) ")
        if let startDate = period.first, let endOfDate = period.last {
            return NSPredicate(format: "startDate >= %@ AND endDate < %@", startDate as NSDate, endOfDate as NSDate)
        } else {
            /// if dates are nil return current day, just to avoid potential crashes
            return NSPredicate(format: "startDate >= %@ AND endDate < %@", Date() as NSDate, Date() as NSDate)
        }
    }
    
    // MARK: - Want a X number of Random Moment?
    private func randomMomentThemes(qty: Int, localytics: KMCSCMFYLocaytics?) -> Promise<[CurationTheme]> {
        
        return Promise { fullfill, reject in
            
            DispatchQueue.global(qos: .background).async {
                
                /// 1 fetch for all the moments albums available
                let momentsAlbumsResults: PHFetchResult<PHAssetCollection> =  PHAssetCollection.fetchAssetCollections(with: .moment, subtype: .albumRegular, options: nil)
                var momentsThemes: [CurationTheme] = []
                momentsAlbumsResults.enumerateObjects { collection, index, stop in
                    
                    // TODO: aassetestimated count 'average' or how many the user tends to take for any moment
                    /// 2 check if moments has a title also it has more than one asset to work with
                    if let title = collection.localizedTitle,
                        !title.isEmpty,
                        collection.estimatedAssetCount > 0 {
                        
                        //Creating the Album theme title
                        //for this call just pass the collection.localIdentifier as period, later when we add a period parameter on this call will change that.
                        //  let albumTheme = MFYAlbumTheme(albumTitle: "Your Moments ", albumType: "", period: collection.localIdentifier)
                        
                        /// 3 fetch the assets and construct the CurationTheme
                        let assetResult = PHAsset.fetchAssets(in: collection, options: nil)
                        let assets = KMCSCThemeBuilder.filterSimilarTimeStapAssets(from: assetResult, compare: 5)

                        /// this will fix uniqueness
                        let uniqueID = title + " \(collection.localIdentifier)"
                        
                        /// this will help with localytics
                        let localyticsEventString = localytics?.eventString ?? ""
                        
                        // let momentTitle = self.constructMomentTitle(title)
                        
                        let collectionDay = KMCSRandomMomentDateManager.day(collection.startDate!).periodText
                        let collectionMonth = KMCSRandomMomentDateManager.month(collection.startDate!).periodText
                        let collectionYear = KMCSRandomMomentDateManager.year(collection.startDate!).periodText
                        
                        
                        
                        print("DATE \(collectionDay) - \(collectionMonth), \(collectionYear)")
                        print("DATE real \(collection.startDate!)")

                        
                        
                        let curationTheme = CurationTheme(title: "A Moment to Remember", subTitle: "", logString: localyticsEventString, potentialAssets: assets, uniqueID: uniqueID)
                        momentsThemes.append(curationTheme)
                    }
                }
                //shuffle array
                let randomMomentThemes = momentsThemes.shuffled.choose(qty)
                DispatchQueue.main.async {
                    randomMomentThemes.count > 0 ? fullfill(randomMomentThemes) : reject(KMCSCError.noRandomMoments)
                }
            }
        }
    }
    
    // MARK: - Want a s et of moments based on a time period? Your Moments
    /// Here the period startDate and EndDate are associated to the album not the assets.
    private func momentsTheme(subType: PHAssetCollectionSubtype,
                              period: KMCSDateManager,
                              justFavorites: Bool,
                              sortDescriptors: [SortProvider],
                              localytics: KMCSCMFYLocaytics?) -> Promise<[CurationTheme]> {
        
        return Promise { fullfill, reject in
            DispatchQueue.global(qos: .background).async {
                
                let options = PHFetchOptions.init()
                options.predicate = self.constructPeriodPredicate(from: period.period)
                
                /// 1 fetch for all the moments albums available
                let momentsAlbumsResults: PHFetchResult<PHAssetCollection> =  PHAssetCollection.fetchAssetCollections(with: .moment, subtype: subType, options: options)
                var momentsThemes: [CurationTheme] = []
                momentsAlbumsResults.enumerateObjects { collection, index, stop in
                    
                    //check average of users albums
                    if let title = collection.localizedTitle,
                        !title.isEmpty,
                        collection.estimatedAssetCount > 1 {
                        
                        let options = PHFetchOptions.init()
                        
                        var predicates: [NSPredicate] = []
                        let subTypePredicate = subType.predicate///no ScreenShots and !isHidden
                        predicates.append(subTypePredicate)
                        
                        if justFavorites {
                            let isFavoritePredicate = NSPredicate(format: "isFavorite == %d",  1 as CVarArg)
                            predicates.append(isFavoritePredicate)
                        }
                        
                        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                        options.predicate = compound
                        options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
                        
                        let assetResult = PHAsset.fetchAssets(in: collection, options: nil)
            
                        let assets = KMCSCThemeBuilder.filterSimilarTimeStapAssets(from: assetResult, compare: 5)
                        
                        /// this will fix uniqueness
                        let uniqueID = title + "\(collection.localIdentifier)"
                        
                        /// this will help with localytics
                        let localyticsEventString = localytics?.eventString ?? ""
                    
                        /// this will help with the location subtitle
                        let locationTitle = self.constructMomentTitle(title)
                        
                       // if we are going to say just this from albums use subType.themeTitle
                        // if we want moments support on ranges use period.periodThemeTitle
                        
                        let curationTheme = CurationTheme(title: period.periodThemeTitle, subTitle: locationTitle, logString: localyticsEventString, potentialAssets: assets, uniqueID: uniqueID)
                        momentsThemes.append(curationTheme)
                    }
                }
                DispatchQueue.main.async {
                    momentsThemes.count > 0 ? fullfill(momentsThemes) : reject(KMCSCError.noRandomMoments)
                }
            }
        }
    }
    
    // MARK: - Helper for title construction
    private func constructMomentTitle(_ text: String) -> String {
        let stringComponents = text.components(separatedBy: "-")
        if let prefix = stringComponents.first {
            return prefix
        } else {
            return text
        }
    }
}




