//
//  GameModule.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GameModule {
    static func build() -> UIViewController {
        let gameVC = GameVC()
        let interactor = GameInteractor()
        let presenter = GamePresenter()
        let router = GameRouter()
        
        gameVC.presenter = presenter
        
        presenter.view = gameVC
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        
        return gameVC
    }
}
