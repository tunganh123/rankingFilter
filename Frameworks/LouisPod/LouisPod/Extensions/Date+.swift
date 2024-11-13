//
//  Date.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 7/17/20.
//  Copyright © 2020 nguyen.viet.luy. All rights reserved.
//

import Foundation

let calendar = Calendar(identifier: .gregorian)

extension DateFormatter {
    public static let defaultCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
    public static let defaultLocale = Locale(identifier: "en_US_POSIX")
    
    public enum Format: String {
        case iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case notification = "E MMM dd yyyy HH:mm:ss 'GMT'Z"
        case dateAndTime = "dd MMM yyyy HH:mm:ss"
        case date = "yyyy-MM-dd"
        case dayAndMonth = "M/d"
        case hourAndMinutes = "HH:mm"
        case hourAndMinutes2 = "hh:mm"
        case aHour = "a"
        case hourMinSec = "HH:mm:ss"
        case yearMonthDay = "yyyy/MM/dd"
        case yearMonthDay2 = "yyyy_MM_dd"
        case yearMonthDow = "yyyy-MM EEE"
        case monthDayYear = "MMM dd, yyyy"
        case monthAndYear = "MMMM yyyy"
        case yearMonthDayHourMinute = "yyyy/MM/dd HH:mm"
        case yearMonthDayHourMinute2 = "yyyy-MM-dd HH:mm:ss"
        case dateAndWeekDay = "yyyy/MM/dd(E)"
        case monthDay = "MM/dd"
        case monthDay2 = "MMMM dd"
        case monthDayDow = "MM/dd EEE"
        case dayMonthYear = "dd/MM/yyyy"
        case dayMonthYear2 = "dd MMM yyyy"
        case dayMonthYear3 = "dd MMM, yyyy"
        case dayMonthDOW = "dd/M EEE"
        case dayMonthDOW2 = "dd/M EEEE"
        case dayMonthInt = "dd/M"
        case monthDayDOW = "MMMM dd, EEEE"
        case monthString = "MMMM"
        case monthStringCompact = "MMM"
        case monthInt = "MM"
        case dowMonthDay = "EEE, MMM.dd"
        case dayOfWeekAndMonthShort = "EEEE MMM"
        case dayOfWeek = "EEEE"
        case dayOfWeekShort = "EEE"
        case onlyDay = "dd"
        case onlyHour = "HH"
        case onlyMinute = "mm"
        case monthAndYear2 = "yyyy-MM"
        case onlyYear = "yyyy"
    
        var instance: DateFormatter {
            switch self {
            default:
                return DateFormatter().then {
                    $0.dateFormat = self.rawValue
                    $0.calendar = DateFormatter.defaultCalendar
                    $0.timeZone = TimeZone.init(abbreviation: "UTC")
                    $0.locale = DateFormatter.defaultLocale
                }
            }
        }
    }
}

extension Date {
    public func convertDateToUTCString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        return dateFormatter.string(from: self)
    }
    
    public func dayFromNowToNewYear() -> Int{
        var components = DateComponents()
        components.year = Calendar.current.component(.year, from: Date()) + 1
        components.month = 1
        components.day = 1
        let calendar = Calendar.current
        
        if let lastDayOfYear = calendar.date(from: components) {
            let currentDate = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: currentDate, to: lastDayOfYear)
            if let daysRemaining = components.day {
                return daysRemaining
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    public func percentToday() -> Int{
        let currentDate = self
        let calendar = Calendar.current

        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        let currentSecond = calendar.component(.second, from: currentDate)
        let totalSecondsInDay = 24 * 60 * 60

        let percentageOfDay = Double((currentHour * 60 * 60 + currentMinute * 60 + currentSecond) * 100) / Double(totalSecondsInDay)
        return Int(percentageOfDay)
    }
    public var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    public func nextYear() -> String{
        var nextYear = 0
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        if currentMonth > 10 {
            nextYear = calendar.component(.year, from: currentDate) + 1
        } else {
            nextYear = calendar.component(.year, from: currentDate)
        }
        let nextYearDate = calendar.date(from: DateComponents(year: nextYear))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let nextYearString = dateFormatter.string(from: nextYearDate!)
        return nextYearString
    }
    
    public func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    public var currentYear: Int {
        let calendar = DateFormatter.defaultCalendar
        let component = calendar.dateComponents([.year], from: self)
        return component.year ?? 0
    }
    
    public var currentMonth: Int {
        let calendar = DateFormatter.defaultCalendar
        let component = calendar.dateComponents([.month], from: self)
        return component.month ?? 0
    }
    
    public var currentMonthString: String {
        return self.toString(DateFormatter.Format.monthString.rawValue)
    }
    
    public func createDateFrom(hour: Int, minute: Int, second: Int) -> Date {
        var components = DateComponents()
        components.year = self.currentYear
        components.month = self.currentMonth
        components.hour = hour
        components.minute = minute
        components.second = second
        let newDate = DateFormatter.defaultCalendar.date(from: components)
        return newDate ?? self
    }
    
    public static func createDateFrom(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        let newDate = DateFormatter.defaultCalendar.date(from: components) ?? Date()
        return newDate
    }
    
    public func getDayOnly() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
}

extension Date {
    public func addingHours(_ hours: Int) -> Date? {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self)
    }
    
    public func addingMins(_ mins: Int) -> Date? {
        return Calendar.current.date(byAdding: .minute, value: mins, to: self)
    }
    
    public func toString(_ format: String) -> String {
        let formatter = DateFormatter().then {
            $0.dateFormat = format
            $0.calendar = Calendar(identifier: .gregorian)
            $0.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        }
        return formatter.string(from: self)
    }
    
    public func toGMT(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    public func getComponent(_ component: Calendar.Component) -> Int {
        let calendar = Calendar.current
        return calendar.component(component, from: self)
    }
    
    public func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
}


extension Date {
    public var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? Date()
    }
    
    public var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth) ?? Date()
    }
    
    public func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)
        return range?.count ?? 0
    }
    
    public var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    public var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? Date()
    }
    
    public func fullDistance(to date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }
    public func roundDownToNearestHour() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        return calendar.date(from: components)
    }
    public func roundUpToNearestHour() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        return calendar.date(from: components)?.addingHours(1)
    }
}
extension Date{
    public func firstAndLastDayOfWeek() -> [String] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        var startOfMonth = calendar.date(from: components)!
        
        var firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let lastDayOfMonth = calendar.date(byAdding: DateComponents(day: range.count), to: startOfMonth)!
        let numberDays = calendar.dateComponents([.day], from: startOfMonth, to: lastDayOfMonth).day ?? 0
        let space = firstWeekday - 1
        var days: [String] = []
        for i in 1...(numberDays+space){
            let j = i - space
            if j <= 0{
                days.append("")
            }
            else{
                days.append("\(j)")
            }
        }
        return days
    }
}
