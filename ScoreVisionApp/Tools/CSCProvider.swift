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

// MARK: - struct that holds data from query results
struct Theme {
    let title: String
    let potentialAssets: [String]
    let analyzedAssets: [String]
}

// MARK: - protocol
protocol ThemeProvider {
    var theme: Theme { get }
}

// MARK: - Enum that constructs the Theme takes input and returns output
enum AssetProvider: ThemeProvider {
    
//    case thisDayLastYear(predicate: PredicateFormat)
//    case thisDayYearsAgo(years: CGFloat)
//    case holidaysYearsAgo(years: CGFloat)
    case getAssetsWith(predicate: PredicateTheme, sortDescriptors: [SortProvider]) // for now and then for favorites in a year
} 

extension AssetProvider {
    
    var theme: Theme {
        switch self {
        case .getAssetsWith(let predicateTheme, let sortDescriptors):
            
            let options = PHFetchOptions.init()
            options.predicate = predicateTheme.predicate
            options.sortDescriptors = sortDescriptors.map { $0.sortDescriptor }
            
            return Theme(title: "", potentialAssets: [], analyzedAssets: [])
        }
    }
}

//////////////////////////////////////////////////////////
//urlquery item provider
protocol PredicateThemeProvider {
    var predicate: NSPredicate { get }
}

enum PredicateTheme: PredicateThemeProvider {
//    case thisDayLastYear(startDate: Date, endDate: Date)
    case favorites(selection: FavoriteSelection)
}

extension PredicateTheme {
    var predicate: NSPredicate {
        switch self {
        case .favorites(let selection):
            return selection.predicate
        }
    }
}

/// just favorites
enum FavoriteSelection  {
    case justFavorites
    case favoritesFromOneYearAgo(date: Date)
    case favoritesFromOneMonthAfgo(date: Date)
}

// this just holds the selection for favorites
extension FavoriteSelection: PredicateThemeProvider {
    var predicate: NSPredicate {
        switch self {
        case .justFavorites:
            return NSPredicate(format: "%d == %d", 2 as CVarArg, 2 as CVarArg)
        case .favoritesFromOneYearAgo(let date):
            return NSPredicate(format: "%d == %d", 3 as CVarArg, 2 as CVarArg)
        case .favoritesFromOneMonthAfgo(let date):
            return NSPredicate(format: "%d == %d", 4 as CVarArg, 2 as CVarArg)
        }
    }
}

/// this is just for sortdescriptors
protocol SortDescriptorProvider {
    var sortDescriptor: NSSortDescriptor { get }
}

enum SortProvider: SortDescriptorProvider {
    case creationDate
}

extension SortProvider {
    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .creationDate:
            return NSSortDescriptor(key: "creationDate", ascending: true)
        }
    }
}



















































