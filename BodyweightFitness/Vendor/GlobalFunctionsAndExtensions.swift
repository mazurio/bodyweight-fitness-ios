//
//  GlobalFunctionsAndExtensions.swift
//  Pods
//
//  Created by JayT on 2016-06-26.
//
//

import UIKit

func delayRunOnMainThread(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func delayRunOnGlobalThread(delay:Double, qos: qos_class_t,closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ), dispatch_get_global_queue(qos, 0), closure)
}

/// NSDates can be compared with the == and != operators
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}
/// NSDates can be compared with the > and < operators
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }
extension NSDate {
    class func startOfMonthForDate(date: NSDate, usingCalendar calendar:NSCalendar) -> NSDate? {
        let dayOneComponents = calendar.components([.Era, .Year, .Month], fromDate: date)
        return calendar.dateFromComponents(dayOneComponents)
    }
    
    class func endOfMonthForDate(date: NSDate, usingCalendar calendar:NSCalendar) -> NSDate? {
        let lastDayComponents = calendar.components([NSCalendarUnit.Era, NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: date)
        lastDayComponents.month = lastDayComponents.month + 1
        lastDayComponents.day = 0
        return calendar.dateFromComponents(lastDayComponents)
    }
}
