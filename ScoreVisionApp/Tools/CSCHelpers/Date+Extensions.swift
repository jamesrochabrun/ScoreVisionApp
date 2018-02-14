//
//  Date+Extensions.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation

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
    
    var startOfMonth: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))
    }
    
    var endOfMonth: Date? {
        guard let startOfMonth = self.startOfMonth else { return nil }
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
    }
    
    var startOfYear: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: self)))
    }
    
    var endOfYear: Date? {
        guard let startOfMonth = self.startOfMonth else { return nil }
        return Calendar.current.date(byAdding: DateComponents(year: 1, month: -1, hour: -8, second: -1), to: startOfMonth)
    }
    
    func getCurrentYear() -> Int {
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        //Now asking the calendar what year are we in today’s date:
        let currentYearInt = (calendar?.component(NSCalendar.Unit.year, from: Date())) ?? 1
        return currentYearInt
    }
    
    func getCurrentMonth() -> Int {
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        //Now asking the calendar what month are we in today’s date:
        let currentMonthInt = (calendar?.component(NSCalendar.Unit.month, from: Date())) ?? 1
        return currentMonthInt
    }
}

extension Array {
    /// Returns an array containing this sequence shuffled
    var shuffled: Array {
        var elements = self
        return elements.shuffle()
    }
    /// Shuffles this sequence in place
    @discardableResult
    mutating func shuffle() -> Array {
        let count = self.count
        indices.lazy.dropLast().forEach {
            swapAt($0, Int(arc4random_uniform(UInt32(count - $0))) + $0)
        }
        return self
    }
    var chooseOne: Element { return self[Int(arc4random_uniform(UInt32(count)))] }
    // if the qty is greater than the array count it will return all elements
    func choose(_ n: Int) -> Array { return Array(shuffled.prefix(n)) }
}

