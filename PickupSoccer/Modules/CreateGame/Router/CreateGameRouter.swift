//
//  CreateGameRouter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/5/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class CreateGameRouter : CreateGamePresenterToCreateGameRouter {
    weak var view: CalendarVCDelegate?
    
    deinit {
        print("CreateGameRouter \(#function)")
    }
    
    func buildCalendarModule(baseDate: Date) -> UIViewController {
        let calendarVC = CalendarModule.build(baseDate: Date(), delegate: view)
        return calendarVC
    }
    
    func pushGameLocationVC(with navigationController: UINavigationController) -> GameLocationVC
    {
        let gameLocationVC = GameLocationVC()
        navigationController.pushViewController(gameLocationVC, animated: true)
        return gameLocationVC
    }
    
    func dismissCreateGameModule(_ navigationController: UINavigationController) {
        navigationController.popToRootViewController(animated: true)
    }
}
