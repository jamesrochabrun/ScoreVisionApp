//
//  PredicateThemeProvider.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/1/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import UIKit
import Photos

//MARK: - protocol
protocol PredicateThemeProvider {
    var predicate: NSPredicate { get }
    var caseTitle: String { get }
}

// MARK: - enum with associated values, in this case each value is another enum Main enum for search
//enum PredicateTheme  {
//    case favorites(selection: FavoriteSelection)
//    case timeAgo(selection: TimePeriod)
//    case location(selection: LocationSelection)
//}
//
//// MARK: - extension for protocol conformance, returns a predicate
//extension PredicateTheme: PredicateThemeProvider {
//
//    var predicate: NSPredicate {
//        switch self {
//        case .favorites(let selection): return selection.predicate
//        case .timeAgo(let selection): return selection.predicate
//        case .location(let selection): return selection.predicate
//        }
//    }
//
//    var caseTitle: String {
//        switch self {
//        case .favorites(let s): return "Favorites from \(s.caseTitle)"
//        case .timeAgo(let s): return "Time ago from \(s.caseTitle)"
//        case .location(let s): return "Location from \(s.caseTitle)"
//        }
//    }
//}


// MARK: - small enums for each theme, they are enums because we might want...for example the favorite photos from last year

// MARK: - FAVORITES
//////////////////////////////////////////////////////////////////
//enum FavoriteSelection  {
//    case justFavorites
//    case favoritesFromOneYearAgo(date: Date)
//    case favoritesFromOneMonthAgo(date: Date)
//}
//
//extension FavoriteSelection: PredicateThemeProvider {
//    var predicate: NSPredicate {
//        switch self {
//        case .justFavorites: return NSPredicate(format: " == %d", 2 as CVarArg, 2 as CVarArg)
//        case .favoritesFromOneYearAgo(let date): return NSPredicate(format: "%d == %d", 3 as CVarArg, 2 as CVarArg)
//        case .favoritesFromOneMonthAgo(let date): return NSPredicate(format: "%d == %d", 4 as CVarArg, 2 as CVarArg)
//        }
//    }
//
//    var caseTitle: String {
//        switch self {
//        case .justFavorites: return "all"
//        case .favoritesFromOneYearAgo(_): return "one year ago"
//        case .favoritesFromOneMonthAgo(_): return "one month ago"
//        }
//    }
//}

// MARK: - Time past
//////////////////////////////////////////////////////////////////
enum TimePeriod {
    case ever
    case today
    case yesterday
    case oneWeekAgo
    case oneMonthAgo
    case oneYearAgo
}

/// FYI TimeAgoSelection this needs better development too much repetition here and also will use code of kodak to get years etc
extension TimePeriod: PredicateThemeProvider {
    
    private var dateHelper: Date {
        switch self {
        case .ever:
            return Date() - 24*60*60 //test
        case .today:
            return Date() - 24*60 ///dumm
        case .oneWeekAgo:
            return Date() - 24*60*60*7 ///dumm
        case .yesterday:
            return Date() - 24*60*60
        case .oneMonthAgo:
            return Date() - (24*60*60*30)
        case .oneYearAgo:
            return Date() - 26280000
        }
    }
    
    var predicate: NSPredicate {
        print("date helper = \(dateHelper)")
        return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND creationDate >= %@ AND creationDate < %@", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue, dateHelper as NSDate, Date() as CVarArg)
    }
    
    var caseTitle: String {
        switch self {
        case .ever: return "ever"
        case .today: return "today"
        case .yesterday: return "yesterday"
        case .oneWeekAgo: return "one Week Ago"
        case .oneMonthAgo: return "one month ago"
        case .oneYearAgo: return "one year ago"
        }
    }
}

// MARK: - Nearby
//////////////////////////////////////////////////////////////////
enum LocationSelection {
    case thisLocation(lat: CGFloat, long: CGFloat)
    case inLocation(lat: CGFloat, long: CGFloat)
}


extension LocationSelection: PredicateThemeProvider {
    
    var predicate: NSPredicate {
        switch self {
        case .thisLocation(let lat, let long):
            return NSPredicate()
        case .inLocation(let lat, let long):
            return NSPredicate()
        }
    }
    
    var caseTitle: String {
        switch self {
        case .thisLocation: return "this location"
        case .inLocation: return "in location"
        }
    }
    
}

// MARK: - Nearby
//////////////////////////////////////////////////////////////////




























