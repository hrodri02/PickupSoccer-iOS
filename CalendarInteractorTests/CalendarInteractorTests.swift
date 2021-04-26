//
//  CalendarInteractorTests.swift
//  CalendarInteractorTests
//
//  Created by Heriberto Rodriguez on 3/17/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import XCTest
@testable import PickupSoccer

class CalendarInteractorTests: XCTestCase {
    var calendarInteractor: CalendarInteractor!
    var mockCalendarPresenter: MockCalendarPresenter!
    let calendar = Calendar(identifier: .gregorian)
    lazy var baseDate: Date = {
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 3
        dateComponents.day = 1
        let baseDate = self.calendar.date(from: dateComponents)!
        return baseDate
    }()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        calendarInteractor = CalendarInteractor(baseDate: baseDate)
        mockCalendarPresenter = MockCalendarPresenter()
        calendarInteractor.presenter = mockCalendarPresenter
        calendarInteractor.generateDaysInMonthForNewBaseDate(date: baseDate)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        calendarInteractor = nil
        mockCalendarPresenter = nil
        super.tearDown()
    }
    
    func testNumOfWeeksInMarch2021() {
        XCTAssertEqual(mockCalendarPresenter.numOfWeeksInMonth, 5, "Number of weeks calculated by interactor is wrong.")
    }
    
    func testDaysOfMarch2021() {
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 2
        dateComponents.day = 28
        let calendar = Calendar(identifier: .gregorian)
        var currDate = calendar.date(from: dateComponents)!
        
        for day in mockCalendarPresenter.daysOfMonth {
            let dayOfMonth = calendar.component(.day, from: currDate)
            let dayAsString = "\(dayOfMonth)"
            let isSelected = calendar.compare(day.date, to: baseDate, toGranularity: .day) == .orderedSame
            let isWithinDisplayedMonth = calendar.isDate(day.date, equalTo: baseDate, toGranularity: .month)
            let currDay = Day(date: currDate,
                              number: dayAsString,
                              isSelected: isSelected,
                              isWithinDisplayedMonth: isWithinDisplayedMonth)
            
            XCTAssertEqual(day, currDay)
            currDate = calendar.date(byAdding: .day, value: 1, to: currDate)!
        }
    }
    
    private func printDay(_ day: Day) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        print("{")
        print("\tdate: \(dateFormatter.string(from: day.date))")
        print("\tnumber: \(day.number)")
        print("\tisSelected: \(day.isSelected)")
        print("\tisWithinDisplayedMonth: \(day.isWithinDisplayedMonth)")
        print("}")
    }
}

class MockCalendarPresenter: CalendarInteractorToCalendarPresenter {
    var numOfWeeksInMonth: Int
    var daysOfMonth: [Day]
    
    init() {
        numOfWeeksInMonth = 0
        daysOfMonth = []
    }
    
    func didUpdateSelectedDate(_ date: Date) {
        
    }
    
    func generatedCalendarData(daysOfMonth: [Day], numWeeksInMonth: Int) {
        self.daysOfMonth = daysOfMonth
        self.numOfWeeksInMonth = numWeeksInMonth
    }
}
