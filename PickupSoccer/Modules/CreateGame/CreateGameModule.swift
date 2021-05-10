//
//  CreateGameModule.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/16/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class CreateGameModule
{
    static func build() -> UIViewController {
        let presenter = CreateGamePresenter()
        
        let gameTimeVC = GameTimeVC()
        gameTimeVC.presenter = presenter
        presenter.gameTimeView = gameTimeVC
        
        let router = CreateGameRouter()
        router.view = gameTimeVC
        presenter.router = router
        
        let createGameInteractor = CreateGameInteractor(userLocationService: App.shared.userLocationService,
                                                        dataStore: App.shared.coreDataStore)
        presenter.createGameInteractor = createGameInteractor
        createGameInteractor.presenter = presenter
        
        return gameTimeVC
    }
}
