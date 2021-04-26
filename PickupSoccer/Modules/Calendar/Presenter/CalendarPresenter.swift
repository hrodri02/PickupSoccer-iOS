//
//  CalendarPresenter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/15/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

class CalendarPresenter: NSObject, CalendarViewToCalendarPresenter
{
    weak var view: CalendarPresenterToCalendarView?
    var interactor: CalendarPresenterToCalendarInteractor?
    var router: CalendarPresenterToCalendarRouter?
    
    deinit {
        print("CalendarPresenter \(#function)")
    }
    
    func updateCalendarView() {
        interactor?.generateDaysInMonth()
    }
    
    func userTappedADate(_ date: Date) {
        interactor?.generateDaysInMonthForSelectedDate(date)
    }
    
    func updateBaseDate(_ date: Date) {
        interactor?.generateDaysInMonthForNewBaseDate(date: date)
    }
}

extension CalendarPresenter: CalendarInteractorToCalendarPresenter {
    func generatedCalendarData(daysOfMonth: [Day], numWeeksInMonth: Int) {
        view?.showCalendar(with: daysOfMonth, numWeeksInMonth)
    }
    
    func didUpdateSelectedDate(_ date: Date) {
        view?.onUpdatedSelectedDate(date)
    }
}
