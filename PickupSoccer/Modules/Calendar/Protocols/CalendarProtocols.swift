//
//  CalendarProtocols.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/15/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

// MARK: - communication between views and presenter
protocol CalendarViewToCalendarPresenter {
    func updateCalendarView()
    func userTappedADate(_ date: Date)
    func updateBaseDate(_ date: Date)
}

protocol CalendarPresenterToCalendarView: AnyObject {
    func showCalendar(with daysOfMonth: [Day], _ numWeeksInMonth: Int)
    func onUpdatedSelectedDate(_ date: Date)
}

// MARK: - presenter has delegate to pass data to different presenter in different module
protocol CalendarPresenterDelegate: AnyObject {
    func onUpdatedSelectedDate(_ date: Date)
}

// MARK: - communication between interactor and presenter
protocol CalendarPresenterToCalendarInteractor {
    func generateDaysInMonth()
    func generateDaysInMonthForNewBaseDate(date: Date)
    func generateDaysInMonthForSelectedDate(_ date: Date)
}

protocol CalendarInteractorToCalendarPresenter : AnyObject {
    func generatedCalendarData(daysOfMonth: [Day], numWeeksInMonth: Int)
    func didUpdateSelectedDate(_ date: Date)
}

// MARK: - communication between presenter and router
protocol CalendarPresenterToCalendarRouter {
    
}
