//
//  DateUtil.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 03/03/22.
//

import Foundation


class DateUtil{
     func getCurrentDate(format:String = "dd-MMM-yyyy")->String {
         let date = Date()

         // Create Date Formatter
         let dateFormatter = DateFormatter()

         // Set Date Format
         dateFormatter.dateFormat = format

         // Convert Date to String
         return dateFormatter.string(from: date)
    }
    
    
    func getDateStringfromDate(date : Date,format:String = "dd-MMM-yyyy")->String {
        
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = format

        // Convert Date to String
        return dateFormatter.string(from: date)
   }
    
    func getDateFromDateString(dateString : String,format:String = "dd-MMM-yyyy") -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from:dateString)!
        return date
    }
    
    func addDay(date : Date) -> Date{
        var dayComponent    = DateComponents()
        dayComponent.day    = 1 // For removing one day (yesterday): -1
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: date)
        return nextDate!
    }
    
    func addDays(date : Date, days : Int) -> Date{
        var dayComponent    = DateComponents()
        dayComponent.day    = days // For removing one day (yesterday): -1
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: date)
        return nextDate!
    }
    
    func subtractDay(date : Date) -> Date{
        var dayComponent    = DateComponents()
        dayComponent.day    = -1 // For removing one day (yesterday): -1
        let theCalendar     = Calendar.current
        let prevDate        = theCalendar.date(byAdding: dayComponent, to: date)
        return prevDate!
    }
}
