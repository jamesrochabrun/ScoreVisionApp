//
//  MCSRandomMomentDateManagerViewModel.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 3/3/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation


enum KMCSRandomMomentDateManager {
    
    case day(Date)
    case month(Date)
    case year(Date)
    case season(Date)
    
    var periodText: String {
        switch self {
        case .day(let date): return MCSRandomMomentDateManagerViewModel(startDate: date).textDay
        case .month(let date): return MCSRandomMomentDateManagerViewModel(startDate: date).textMonth
        case .year(let date): return MCSRandomMomentDateManagerViewModel(startDate: date).textYear
        case .season(let date): return MCSRandomMomentDateManagerViewModel(startDate: date).textSeason
        }
    }
}

struct MCSRandomMomentDateManagerViewModel {
    
    private var startDate: Date!
    private let calendar = Calendar.current
    
    init(startDate: Date) {
        self.startDate = startDate
    }
    
    var textDay: String {
        let day = calendar.component(.weekday, from: startDate)
        return WeekDay(day).asText
    }
    
    var textMonth: String {
        let month = calendar.component(.month, from: startDate)
        return MonthOfYear(month).asText
    }
    
    var textYear: String {
        let year = calendar.component(.year, from: startDate)
        return "\(year)"
    }
    
    var textSeason: String {
        // TODO: find the best way to construct Seasons
        return ""
    }
}

/// Week Day for random moments.
private enum WeekDay: Int {
    
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case undefined
    
    init(_ weekDay: Int) {
        switch weekDay {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: self = .undefined
        }
    }
    
    var asText: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        default: return "undefined"
        }
    }
}

private enum MonthOfYear: Int {
    
    case january
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    case undefined
    
    init(_ month: Int) {
        switch month {
        case 1: self = .january
        case 2: self = .february
        case 3: self = .march
        case 4: self = .april
        case 5: self = .may
        case 6: self = .june
        case 7: self = .july
        case 8: self = .august
        case 9: self = .september
        case 10: self = .october
        case 11: self = .november
        case 12: self = .december
        default: self = .undefined
        }
    }
    
    var asText: String {
        switch self {
        case .january: return "January"
        case .february: return "February"
        case .march: return "March"
        case .april: return "April"
        case .may: return "May"
        case .june: return "June"
        case .july: return "July"
        case .august: return "August"
        case .september: return "September"
        case .october: return "October"
        case .november: return "November"
        case .december: return "December"
        default: return ""
        }
    }
}
















