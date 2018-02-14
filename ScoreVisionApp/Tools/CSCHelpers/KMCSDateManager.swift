//
//  KMCSDateManager.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/3/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//


import UIKit
import Photos

enum KMCSDateManager {
    
    /// MARK: We can add any period here like seasons periods x years ago also
    ///passing 0 as an argument for the yearsAgo returns current day, year, month
    /// Big Range Periods
    case ever
    case thisDay(yearsAgo: Int)
    case thisWeek(yearsAgo: Int)
    case thisMonth(yearsAgo: Int)
    case fullRangeOfYear(yearsAgo: Int)
    
    /// Small Range Periods
    case lastWeekend
    
    /// Holidays
    case valentines(yearsAgo: Int)
    case christmasHolidays(yearsAgo: Int)
    
    /// Enum helper for format periodThemeTitle
    private enum Time {
        case day
        case week
        case month
        case year
    }
    
    /// Enum helper for change numeric # of years in to sring representation
    enum Years: Int {
        
        case one
        case two
        case three
        case four
        case five
        case six
        case seven
        case eight
        case nine
        case ten
        case wayDownInThePast
    }
}
extension KMCSDateManager.Years {
    
    init(_ yearsAgo: Int) {
        switch yearsAgo {
        case 1: self = .one
        case 2: self = .two
        case 3: self = .three
        case 4: self = .four
        case 5: self = .five
        case 6: self = .six
        case 7: self = .seven
        case 8: self = .eight
        case 9: self = .nine
        case 10: self = .ten
        default: self = .wayDownInThePast
        }
    }
    
    var asText: String {
        switch self {
        case .one: return "One"
        case .two: return "Two"
        case .three: return "Three"
        case .four: return "Four"
        case .five: return "Five"
        case .six: return "Six"
        case .seven: return "Seven"
        case .eight: return "Eight"
        case .nine: return "Nine"
        case .ten: return "Ten"
        case .wayDownInThePast: return ""
        }
    }
}
// MARK: - Computed properties
extension KMCSDateManager {
    
    var period: [Date] {
        switch self {
        case .ever: return self.getLargeDateRange()
        case .thisDay(let yearsAgo): return self.getThisDay(yearsAgo: yearsAgo)
        case .thisWeek(let yearsAgo): return self.getThisWeek(yearsAgo: yearsAgo)
        case .thisMonth(let yearsAgo): return self.getThisMonth(yearsAgo: yearsAgo)
        case .fullRangeOfYear(let yearsAgo): return self.getRangeForFullYear(yearsAgo: yearsAgo)
        case .valentines(let yearsAgo): return self.getValentines(yearsAgo: yearsAgo)
        case .christmasHolidays(let yearsAgo) : return self.getChristmasHolidays(yearsAgo: yearsAgo)
        case .lastWeekend: return self.getLastWeekend()
        }
    }
    
    var predicate: NSPredicate {
        
        print("KMCSDateManager period = \(period) ")
        if let startDate = period.first, let endOfDate = period.last {
            return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND creationDate >= %@ AND creationDate < %@ AND isHidden != %d", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue, startDate as NSDate, endOfDate as NSDate,  1 as CVarArg)
        } else {
            /// if dates are for one or other reason not created just avoid adding them on the query
            return NSPredicate(format: "!((mediaSubtype & %d) == %d) AND isHidden != %d", PHAssetMediaSubtype.photoScreenshot.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue,  1 as CVarArg)
        }
    }
    
    var periodThemeTitle: String {
        switch self {
        case .ever: return ""
        case .thisDay(let yearsAgo): return self.periodFormatter(for: .day, yearsAgo: yearsAgo)
        case .thisWeek(let yearsAgo): return self.periodFormatter(for: .week, yearsAgo: yearsAgo)
        case .thisMonth(let yearsAgo): return self.periodFormatter(for: .month, yearsAgo: yearsAgo)
        case .fullRangeOfYear(let yearsAgo): return self.periodFormatter(for: .year, yearsAgo: yearsAgo)
        case .valentines(let yearsAgo): return "Valentines \((Date().getCurrentYear() - yearsAgo))"
        case .christmasHolidays(let yearsAgo): return "Christmas \((Date().getCurrentYear() - yearsAgo))"
        case .lastWeekend: return "Your Best Photo Last Weekend"
        }
    }
}
extension KMCSDateManager {
    
    // MARK: - Helper methods
    private func periodFormatter(for time: Time, yearsAgo: Int) -> String {
        switch time {
        case .day:
            return yearsAgo == 0 ? "Today" : (yearsAgo == 1 ? "This Day, Last Year" : "\(KMCSDateManager.Years(yearsAgo).asText) Years Ago Today")
        case .week:
            return yearsAgo == 0 ? "This Week" : (yearsAgo == 1 ? "This Week, Last Year" : "This Week, \(KMCSDateManager.Years(yearsAgo).asText) Years Ago")
        case .month:
            return yearsAgo == 0 ? "This Month" : (yearsAgo == 1 ? "This Month, Last Year" : "This Month, \(KMCSDateManager.Years(yearsAgo).asText) Years Ago")
        case .year:
            return yearsAgo == 0 ? "" : (yearsAgo == 1 ? "Last Year" : "\(KMCSDateManager.Years(yearsAgo).asText) Years Ago")
        }
    }
    ///use this to get a range from two dates, helper for holidays or special days
    private func getRangeForDates(startDate: Date, endDate: Date, yearsAgo: Int) -> [Date] {
        var components = DateComponents()
        components.year = -yearsAgo
        guard let sD = Calendar.current.date(byAdding: components, to: startDate) else {
            return []
        }
        guard let eD = Calendar.current.date(byAdding: components, to: endDate) else {
            return []
        }
        return [sD, eD]
    }
    
    // MARK: - Period functions
    private func getLargeDateRange() -> [Date] {
        let beginTime = Date.distantPast
        let endTime = Date()
        return [beginTime, endTime]
    }
    
    private func getThisDay(yearsAgo: Int) -> [Date] {
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        let beginTime : Date = {
            var components = DateComponents()
            components.year = -yearsAgo
            return Calendar.current.date(byAdding: components, to: currentDate)!
        }()
        
        let endTime : Date = {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            components.year = -yearsAgo
            return Calendar.current.date(byAdding: components, to: currentDate)!
        }()
        
        return [beginTime,endTime]
    }
    
    private func getThisWeek(yearsAgo: Int) -> [Date] {
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        let beginTime : Date = {
            var components = DateComponents()
            components.year = -yearsAgo
            currentDate = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
            return Calendar.current.date(byAdding: components, to: currentDate)!
        }()
        
        let endTime : Date = {
            var components = DateComponents()
            components.day = 7
            components.second = -1
            return Calendar.current.date(byAdding: components, to: beginTime)!
        }()
        
        return [beginTime,endTime]
    }
    
    
    private func getThisMonth(yearsAgo: Int) -> [Date] {
        var currentDate = Calendar.current.startOfDay(for: Date())
        let beginTime : Date = {
            var components = DateComponents()
            components.year = -yearsAgo
            currentDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentDate))!
            return Calendar.current.date(byAdding: components, to: currentDate)!
        }()
        let endTime : Date = {
            var components = DateComponents()
            components.month = 1
            components.day = -1
            components.second = -1
            return Calendar.current.date(byAdding: components, to: beginTime)!
        }()
        return [beginTime,endTime]
    }
    
    private func getRangeForFullYear(yearsAgo: Int) -> [Date] {
        
        var components = DateComponents()
        components.year = -yearsAgo
        guard let startDate = Calendar.current.date(byAdding: components, to: Date().startOfYear!) else {
            return []
        }
        guard let endOfYear = Date().endOfYear,
            let endDate = Calendar.current.date(byAdding: components, to: endOfYear) else {
                return []
        }
        return [startDate, endDate]
    }
    
    private func getLastWeekend() -> [Date] {
        
        let today = Date()
        if #available(iOS 10.0, *) {
            if let weekendInterval = Calendar.current.nextWeekend(startingAfter: today, direction: .backward) {
                var components = DateComponents()
                components.day = -1
                guard let startDate = Calendar.current.date(byAdding: components, to: weekendInterval.start) else {
                    return []
                }
                return [startDate, weekendInterval.end]
            } else { return [] }
        } else {
            // Fallback on earlier versions
            return []
        }
    }
    
    private func getValentines(yearsAgo: Int) -> [Date] {
        
        let userCalendar = Calendar.current
        var startDateComponents = DateComponents()
        startDateComponents.year = Date().getCurrentYear()
        startDateComponents.month = 2
        startDateComponents.day = 14
        startDateComponents.hour = 00
        startDateComponents.timeZone = TimeZone(abbreviation: "PST")
        guard let startDate = userCalendar.date(from: startDateComponents) else { return [] }
        
        var endDateComponents = DateComponents()
        endDateComponents.year = Date().getCurrentYear()
        endDateComponents.month = 2
        endDateComponents.day = 15
        endDateComponents.hour = 00
        endDateComponents.timeZone = TimeZone(abbreviation: "PST")
        guard let endDate = userCalendar.date(from: endDateComponents) else { return [] }
        
        return self.getRangeForDates(startDate: startDate, endDate: endDate, yearsAgo: yearsAgo)
    }
    
    private func getChristmasHolidays(yearsAgo: Int) -> [Date]  {
        
        let userCalendar = Calendar.current
        var startDateComponents = DateComponents()
        startDateComponents.year = Date().getCurrentYear()
        startDateComponents.month = 12
        startDateComponents.day = 14
        startDateComponents.hour = 00
        startDateComponents.timeZone = TimeZone(abbreviation: "PST")
        guard let startDate = userCalendar.date(from: startDateComponents) else { return [] }
        
        var endDateComponents = DateComponents()
        endDateComponents.year = Date().getCurrentYear()
        endDateComponents.month = 12
        endDateComponents.day = 31
        endDateComponents.hour = 00
        endDateComponents.timeZone = TimeZone(abbreviation: "PST")
        guard let endDate = userCalendar.date(from: endDateComponents) else { return [] }
        
        return self.getRangeForDates(startDate: startDate, endDate: endDate, yearsAgo: yearsAgo)
    }
}
//testing?
//    func dateComparison(theme: MFYImageTheme, date: Date) -> Bool {
//        let dates = self.retrieveDate(theme: theme)
//        return (dates[0]...dates[1]).contains(date)
//    }
