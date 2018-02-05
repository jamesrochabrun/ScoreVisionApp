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
protocol KMCSCPredicateThemeProvider {
    var predicate: NSPredicate { get }
   // var caseTitle: String { get }
}


enum KMCSCTimePeriod {
    
    case ever
    case yesterday
    
    case thisDayXYearsAgo(x: Int)
    case thisWeekXYearsAgo(x: Int)
    case thisMonthXYearsAgo(x: Int)
}
/// FYI TimeAgoSelection this needs better development too much repetition here and also will use code of kodak to get years etc
extension KMCSCTimePeriod: KMCSCPredicateThemeProvider {
    
    private var dateConstructor: [Date] {
        let dateManager = KMCSDateManager()
        switch self {
        case .ever:
            return []
        case .yesterday:
            return dateManager.retrieveDate(period: .yesterday)
        case .thisDayXYearsAgo(let x):
            return dateManager.retrieveDate(period: .thisDayXYearsAgo(x: x))
        case .thisWeekXYearsAgo(let x):
            return dateManager.retrieveDate(period: .thisWeekXYearsAgo(x: x))
        case .thisMonthXYearsAgo(let x):
            return dateManager.retrieveDate(period: .thisMonthXYearsAgo(x: x))
        }
    }
    
    var predicate: NSPredicate {
        print("KMCSCThemeProvider helper = \(dateConstructor)")
        if let startDate = dateConstructor.first, let endOfDate = dateConstructor.last {
            return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND creationDate >= %@ AND creationDate < %@", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue, startDate as NSDate, endOfDate as NSDate)
        } else {
            return NSPredicate(format: "!((mediaSubtype & %d) == %d)", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue)
        }
    }
    
//    var caseTitle: String {
//        switch self {
//        case .ever: return "ever"
//        case .today: return "today"
//        case .yesterday: return "yesterday"
//        case .thisWeekLastYear: return "one Week Ago"
//        case .thisMonthLastYear: return "one month ago"
//        case .thisDayLastYear: return "one year ago"
//        case .xYearsAgo(let x): return "\(x) years ago"
//        case .sundaysXYearsAgo(let x): return "\(x) sunday ago"
//        }
//    }
}







// MARK: - Nearby
//////////////////////////////////////////////////////////////////
enum LocationSelection {
    case thisLocation(lat: CGFloat, long: CGFloat)
    case inLocation(lat: CGFloat, long: CGFloat)
}


extension LocationSelection: KMCSCPredicateThemeProvider {
    
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

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }
    //
    //    var thisDayLastYear: Date? {
    //        var components = DateComponents()
    //        components.year = -1
    //        return Calendar.current.date(byAdding: components, to: startOfDay)
    //    }
}























