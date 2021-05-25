//
//  GameRouter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GameRouter: GamePresenterToGameRouter {
    deinit {
        print("GameRouter deinit")
    }
    
    func dismiss(_ navigationController: UINavigationController) {
        navigationController.popToRootViewController(animated: true)
    }
}
