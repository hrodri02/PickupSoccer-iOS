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
    func didSelectNewPosition(_ position: Position, isWithHomeTeam: Bool)
    func menuButtonTapped()
    func changePositionButtonTapped(_ viewController: GameVC)
    func joinGameButtonTapped(_ viewController: GameVC)
    func exitGameButtonTapped()
    func deleteGameButtonTapped(_ navigationController: UINavigationController)
    func confirmButtonTapped()
}

protocol PlayerInfoVCToGamePresenter {
    func updatePlayerInfoVC()
    func doneButtonTapped(_ navigationController: UINavigationController)
}

protocol GamePresenterToGameView: AnyObject {
    func displayPlayers(_ homeTeam: [String : Position], _ awayTeam: [String : Position])
    func displayErrorMessage(_ errorMessage: String)
    func displayConfirmationAlert()
    func displayMenuAlert(_ didUserCreateGame: Bool, _ didUserJoinGame: Bool)
}

protocol GamePresenterToPlayerInfoVC: AnyObject {
    func displayFreePositions(_ homeTeam: [Position], _ awayTeam: [Position], isWithHomeTeam: Bool)
}

// MARK: - communication between presenter and interactor
protocol GamePresenterToGameInteractor {
    func fetchPlayersForGame()
    func checkIfUserCreatedGameOrHasJoinedGame()
    func fetchFreePositions()
    func newPositionSelected(_ position: Position, isWithHomeTeam: Bool)
    func removeUserFromGame()
    func deleteGame(completion: (Error?) -> Void)
}

protocol GameInteractorToGamePresenter: AnyObject {
    func onFetchPlayersSuccess(_ homeTeam: [String : Position], _ awayTeam: [String : Position])
    func onUpdatedTeams(_ homeTeam: [String : Position], _ awayTeam: [String : Position])
    func onFetchPlayersFailed(_ errorMessage: String)
    func onTimeConflictDetected(_ errorMessage: String)
    func onFailedToAddUserToGame(_ errorMessage: String)
    func verifiedIfUserCreatedGameOrHasJoinedGame(_ didUserCreateGame: Bool, _ didUserJoinGame: Bool)
    
    func onFetchFreePositionsSuccess(homeTeam: [Position],
                                     awayTeam: [Position],
                                     isWithHomeTeam: Bool)
}

// MARK: - communication between presenter and router
protocol GamePresenterToGameRouter {
    func presentPlayerInfoVC(_ viewController: GameVC, presenter: GamePresenter)
    func dismissPlayerInfoVC(_ navigationController: UINavigationController)
    func dismiss(_ navigationController: UINavigationController)
}
