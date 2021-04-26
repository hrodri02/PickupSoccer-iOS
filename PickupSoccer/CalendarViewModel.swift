//
//  CalendarViewModel.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/19/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

class CalendarViewModel
{
    var days: [Day] = []
    var baseDate: Date {
        didSet {
            generateDaysInMonth()
        }
    }
    var selectedDate: Date {
        didSet {
            baseDate = selectedDate
            generateDaysInMonth()
        }
    }
    var numOfWeeksInMonth: Int {
        calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
    }
    
    private let calendar = Calendar(identifier: .gregorian)
     
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter
    }()
    
    init() {
        baseDate = Date()
        selectedDate = Date()
        generateDaysInMonth()
    }
    
    public func isSelectedDateValid(_ date: Date) -> Bool {
        return !(isNewDateInThePast(date) || isNewDatePreviouslySelectedDate(date))
    }
    
    private func isNewDateInThePast(_ date: Date) -> Bool {
        let today = Date()
        
        if calendar.compare(date, to: today, toGranularity: .day) == .orderedAscending {
            return true
        }
        
        return false
    }
    
    private func isNewDatePreviouslySelectedDate(_ date: Date) -> Bool {
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            return true
        }
        return false
    }
}

extension CalendarViewModel {
    public func generateDaysInMonth() {
        guard let metadata = try? monthMetadata(for: baseDate) else {
            fatalError("An error occurred when generating the metadata for \(baseDate)")
        }

        let numberOfDaysInMonth = metadata.numberOfDays
        let offsetInInitialRow = metadata.firstDayWeekday
        let firstDayOfMonth = metadata.firstDay

        self.days = (1..<(numberOfDaysInMonth + offsetInInitialRow)).map { day in
            let isWithinDisplayedMonth = day >= offsetInInitialRow
            let dayOffset = isWithinDisplayedMonth ? day - offsetInInitialRow : -(offsetInInitialRow - day)
            return generateDay(offsetBy: dayOffset,
                               for: firstDayOfMonth,
                               isWithinDisplayedMonth: isWithinDisplayedMonth)
        }
        
        days += generateStartOfNextMonth(using: firstDayOfMonth)
//        return days
//            showCalendar(with: days)
    }
        
    private func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
        guard let numberOfDaysInMonth = calendar.range(of: .day,
                                                       in: .month,
                                                       for: baseDate)?.count,
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: baseDate))
        else {
            throw CalendarDataError.metadataGeneration
        }

        let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)

        return MonthMetadata(numberOfDays: numberOfDaysInMonth,
                             firstDay: firstDayOfMonth,
                             firstDayWeekday: firstDayWeekday)
    }
    
    private func generateDay(offsetBy dayOffset: Int, for baseDate: Date, isWithinDisplayedMonth: Bool) -> Day {
           let date = calendar.date(byAdding: .day,
                                    value: dayOffset,
                                    to: baseDate) ?? baseDate

           return Day(date: date,
                       number: dateFormatter.string(from: date),
                       isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                       isWithinDisplayedMonth: isWithinDisplayedMonth)
       }
       
    private func generateStartOfNextMonth(using firstDayOfDisplayedMonth: Date) -> [Day] {
        guard let lastDayInMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                                    to: firstDayOfDisplayedMonth)
        else {
           return []
        }

        let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
        guard additionalDays > 0 else {
           return []
        }

        let days: [Day] = (1...additionalDays).map {
           generateDay(offsetBy: $0,
                       for: lastDayInMonth,
                       isWithinDisplayedMonth: false)
        }

        return days
    }
    
    enum CalendarDataError: Error {
        case metadataGeneration
    }
}

