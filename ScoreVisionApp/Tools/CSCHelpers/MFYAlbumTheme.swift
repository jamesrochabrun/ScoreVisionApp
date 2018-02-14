//
//  MFYAlbumTheme.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation


import Foundation
/// Intention:
/// the theme should not be so thightly coupled to the period
/// constructing a MFYAlbumTheme by using the album title if exists, the type of album and the period predicate will help us create functions easier to test and to extend the searches.
struct MFYAlbumTheme {
    
    /// this is for albums that returns a dynamic title appended in the collection
    let albumThemeTitle: String?
    /// this is for smartAlbums queries like .smartAlbumFavorites should have a vaule here of "Your Favorites"
    /// if .smartAlbumUserLibrary was passed to the search function this value will be "" empty
    let albumThemeType: String
    /// this is for the period.periodThemeTitle of KMCSDateManager
    let periodThemeTitle: String
    
    /// this is used for the UI only
    var mFYAlbumThemeTitle: String {
        var title = ""
        if !periodThemeTitle.isEmpty &&  !albumThemeType.isEmpty {
            title = albumThemeType + " From " + periodThemeTitle // This May return somehting like "Your Favorites from This Day Last Year
        } else if !albumThemeType.isEmpty {
            title = albumThemeType // if period argument was passed as .ever in the KMCSCThemeBuilder call just set the album title
        } else if !periodThemeTitle.isEmpty {
            title = periodThemeTitle // if in KMCSCThemeBuilder the PHAssetCollectionSubtype parameter was .smartAlbumUserLibrary the albumtype strung will be empty so just set the period here this will create something like "This Day Last Year"
        }
        return title
    }
    
    /// this is used for avoiding duplicates
    var mFYAlbumUniqueID: String {
        return "/"//mFYAlbumThemeTitle.removingWhitespaces()
    }
}
/// Localytics
enum KMCSCMFYLocaytics {
    case lastWeekend
    case lookBackToday
    case lookBackMonthLastYear
    case selfies
    case favorites
    case portraits
    case lookBackWeekLastYear
    case moments
    case manualUpsell
}
extension KMCSCMFYLocaytics {
    var eventString: String {
        switch self {
        case .lastWeekend: return "Last Weekend"
        case .lookBackToday: return "Lookback Today"
        case .lookBackMonthLastYear: return "Lookback Month Last Year"
        case .lookBackWeekLastYear: return "Lookback Week Last Year"
        case .selfies: return "Selfies"
        case .favorites: return "Favorites"
        case .portraits: return "Portraits"
        case .moments: return "Moments"
        case .manualUpsell: return "Manual Upsell"
        }
    }
}
