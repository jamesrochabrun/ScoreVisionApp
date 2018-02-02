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
}

// MARK: - enum with associated values, in this case each value is another enum
enum PredicateTheme  {
    case favorites(selection: FavoriteSelection)
    case timeAgo(selection: TimeAgoSelection)
}

// MARK: - extension for protocol conformance, returns a predicate
extension PredicateTheme: PredicateThemeProvider {
    var predicate: NSPredicate {
        switch self {
        case .favorites(let selection):
            return selection.predicate
        case .timeAgo(let selection):
            return selection.predicate
        }
    }
}

// MARK: - small enums for each theme, they are enums because we might want...for example the favorite photos from last year

// MARK: - FAVORITES
//////////////////////////////////////////////////////////////////
enum FavoriteSelection  {
    case justFavorites
    case favoritesFromOneYearAgo(date: Date)
    case favoritesFromOneMonthAgo(date: Date)
}

extension FavoriteSelection: PredicateThemeProvider {
    var predicate: NSPredicate {
        switch self {
        case .justFavorites:
            return NSPredicate(format: "%d == %d", 2 as CVarArg, 2 as CVarArg)
        case .favoritesFromOneYearAgo(let date):
            return NSPredicate(format: "%d == %d", 3 as CVarArg, 2 as CVarArg)
        case .favoritesFromOneMonthAgo(let date):
            return NSPredicate(format: "%d == %d", 4 as CVarArg, 2 as CVarArg)
        }
    }
}

// MARK: - Time past
//////////////////////////////////////////////////////////////////
enum TimeAgoSelection  {
    case today
    case yesterday
    case oneMonthAgo
    case oneYearAgo
}

extension TimeAgoSelection {
    
    var dateHelper: Date {
        switch self {
        case .today:
            return Date()
        case .yesterday:
            return Date() - 24*60*60
        case .oneMonthAgo:
            return Date() - (24*60*60*30)
        case .oneYearAgo:
            return Date() - (24*60*60*365)
        }
    }
    
    var predicate: NSPredicate {
        switch self {
        case .today:
         return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND creationDate < %@ AND creationDate > %@", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue, Date() as CVarArg, dateHelper as NSDate)
        case .yesterday:
            return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND creationDate < %@ AND creationDate > %@", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue, Date() as CVarArg, dateHelper as NSDate)
        case .oneMonthAgo:
            return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND creationDate < %@ AND creationDate > %@", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue, Date() as CVarArg, dateHelper as NSDate)
        case .oneYearAgo:
            return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND creationDate < %@ AND creationDate > %@", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue, Date() as CVarArg, dateHelper as NSDate)
        }
    }
}





























