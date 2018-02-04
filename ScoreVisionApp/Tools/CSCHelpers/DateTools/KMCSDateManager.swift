//
//  KMCSDateManager.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/3/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit
class KMCSDateManager: NSObject {
    
    // Use this class to set up each type of date
    
    override init() {
        super.init()
    }
    
    func retrieveDate(period: KMCSCTimePeriod) -> [Date] {
        
        switch period {
            
        case .yesterday:
            return self.getYesterday()
            
        case .thisDayXYearsAgo(let x):
            return self.getThisDayXYearsAgo(x: x)
            
        case .thisWeekXYearsAgo(let x):
            return self.getThisWeekXYearsAgo(x: x)
            
        case .thisMonthXYearsAgo(let x):
            return self.getThisMonthXYearsAgo(x: x)

        default:
            return []
        }
    }
    
    private func getLargeDateRange() -> [Date] {
        let beginTime = Date.distantPast
        let endTime = Date()
        
        return [beginTime, endTime]
    }
    
    private func getThisDayXYearsAgo(x: Int) -> [Date] {
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        let beginTime : Date = {
            var components = DateComponents()
            components.year = -x
            return Calendar.current.date(byAdding: components, to: currentDate)!
        }()
        
        let endTime : Date = {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            components.year = -1
            return Calendar.current.date(byAdding: components, to: currentDate)!
        }()
        return [beginTime,endTime]
    }
    
    private func getThisWeekXYearsAgo(x: Int) -> [Date] {
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        let beginTime : Date = {
            var components = DateComponents()
            components.year = -x
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
    
    // Configure this to make it the previous month (regardless of day in month)
    
    private func getThisMonthXYearsAgo(x: Int) -> [Date] {
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        let beginTime : Date = {
            var components = DateComponents()
            components.year = -x
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
    
    private func getYesterday() -> [Date] {
        var components = DateComponents()
        components.day = -1
        guard let startDate = Calendar.current.date(byAdding: components, to: Date().startOfDay) else {
            return []
        }
        guard let endOfToday = Date().endOfDay, let endDate = Calendar.current.date(byAdding: components, to: endOfToday) else {
            return []
        }
        return [startDate, endDate]
    }
    
    func dateComparison(period: KMCSCTimePeriod, date: Date) -> Bool {
        let dates = self.retrieveDate(period: period)
        return (dates[0]...dates[1]).contains(date)
    }
}

enum MFYImageTheme : String {
    case thisDayLastYear = "thisDayLastYear"
    case thisWeekLastYear = "thisWeekLastYear" // alternate case of this day last year
    case thisMonthLastYear = "thisMonthLastYear" // alternate case of this day last year
    case favorites = "favorites"
    case selfies = "selfies"
    case manualUpsell = "manualUpsell"
    static let cases = [thisDayLastYear, favorites, selfies]
}


















