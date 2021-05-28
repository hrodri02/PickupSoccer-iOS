//
//  GameProtocols.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

// MARK: - communication between view and presenter
protocol GameViewToGamePresenter {
    func updateGameView()
}

protocol GamePresenterToGameView: AnyObject {
    func displayPlayers(_ players: [User])
    func displayErrorMessage(_ errorMessage: String)
}

// MARK: - communication between presenter and interactor
protocol GamePresenterToGameInteractor {
    func fetchPlayersForGame()
}

protocol GameInteractorToGamePresenter: AnyObject {
    func onFetchPlayersSuccess(_ players: [User])
    func onFetchPlayersFailed(_ errorMessage: String)
}

// MARK: - communication between presenter and router
protocol GamePresenterToGameRouter {
    func dismiss(_ navigationController: UINavigationController)
}
