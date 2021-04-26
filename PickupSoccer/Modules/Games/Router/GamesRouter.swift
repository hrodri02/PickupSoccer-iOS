//
//  GamesRouter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GamesRouter: GamesPresenterToGamesRouter {
    deinit {
        print("Games Router \(#function)")
    }
    
    func pushCreateGameVC(_ navigationController: UINavigationController) {
        let createGameVC = CreateGameModule.build()
        navigationController.pushViewController(createGameVC, animated: true)
    }
    
    func dismissGamesModule(_ navigationController: UINavigationController) {
        navigationController.viewControllers = []
    }
}
