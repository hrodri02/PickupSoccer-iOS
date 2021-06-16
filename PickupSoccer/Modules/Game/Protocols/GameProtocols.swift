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
    func didSelectNewPosition(_ position: Position, isHomeTeam: Bool)
    func exitGameButtonTapped()
    func confirmButtonTapped()
}

protocol GamePresenterToGameView: AnyObject {
    func displayPlayers(_ homeTeam: [String : Position], _ awayTeam: [String : Position])
    func displayErrorMessage(_ errorMessage: String)
    func displayConfirmationAlert()
}

// MARK: - communication between presenter and interactor
protocol GamePresenterToGameInteractor {
    func fetchPlayersForGame()
    func newPositionSelected(_ position: Position, isHomeTeam: Bool)
    func checkIfUserIsPartOfGame()
    func removeUserFromGame()
}

protocol GameInteractorToGamePresenter: AnyObject {
    func onFetchPlayersSuccess(_ homeTeam: [String : Position], _ awayTeam: [String : Position])
    func onUpdatedTeams(_ homeTeam: [String : Position], _ awayTeam: [String : Position])
    func onFetchPlayersFailed(_ errorMessage: String)
    func onTimeConflictDetected(_ errorMessage: String)
    func onFailedToAddUserToGame(_ errorMessage: String)
    func verifiedIfUserIsPartOfGame(_ isPartOfGame: Bool)
}

// MARK: - communication between presenter and router
protocol GamePresenterToGameRouter {
    func dismiss(_ navigationController: UINavigationController)
}
