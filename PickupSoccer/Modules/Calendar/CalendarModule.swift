//
//  CalendarModule.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/16/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class CalendarModule
{
    static func build(baseDate: Date, delegate: CalendarVCDelegate? = nil) -> UIViewController {
        let presenter = CalendarPresenter()
        
        let router = CalendarRouter()
        presenter.router = router
        
        let calendarVC = CalendarVC()
        presenter.view = calendarVC
        calendarVC.presenter = presenter
        calendarVC.delegate = delegate
        
        let calendarInteractor = CalendarInteractor(baseDate: baseDate)
        presenter.interactor = calendarInteractor
        calendarInteractor.presenter = presenter
        
        return calendarVC
    }
}
