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
    
    func presentPlayerInfoVC(_ viewController: GameVC, presenter: GamePresenter) {
        let playerInfoVC = PlayerInfoVC()
        playerInfoVC.presenter = presenter
        playerInfoVC.delegate = viewController
        playerInfoVC.modalPresentationStyle = .popover
        playerInfoVC.modalTransitionStyle = .crossDissolve
        
        presenter.playerInfoView = playerInfoVC
        
        let navController = UINavigationController(rootViewController: playerInfoVC)
        viewController.present(navController, animated: true, completion: nil)
    }
    
    func dismissPlayerInfoVC(_ navigationController: UINavigationController) {
        navigationController.dismiss(animated: true, completion: nil)
    }
    
    func dismiss(_ navigationController: UINavigationController) {
        navigationController.popToRootViewController(animated: true)
    }
}
