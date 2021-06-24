//
//  GamePresenter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GamePresenter {
    weak var gameView: GamePresenterToGameView?
    weak var playerInfoView: GamePresenterToPlayerInfoVC?
    var interactor: GamePresenterToGameInteractor?
    var router: GamePresenterToGameRouter?
    
    deinit {
        print("GamePresenter deinit")
    }
}

extension GamePresenter: GameViewToGamePresenter {
    func updateGameView() {
        interactor?.fetchPlayersForGame()
    }
    
    func menuButtonTapped() {
        interactor?.checkIfUserCreatedGameOrHasJoinedGame()
    }
    
    func joinGameButtonTapped(_ viewController: GameVC) {
        router?.presentPlayerInfoVC(viewController, presenter: self)
    }
    
    func changePositionButtonTapped(_ viewController: GameVC) {
        router?.presentPlayerInfoVC(viewController, presenter: self)
    }
    
    func didSelectNewPosition(_ position: Position, isWithHomeTeam: Bool) {
        interactor?.newPositionSelected(position, isWithHomeTeam: isWithHomeTeam)
    }
    
    func exitGameButtonTapped() {
        gameView?.displayConfirmationAlert()
    }
    
    func confirmButtonTapped() {
        interactor?.removeUserFromGame()
    }
    
    func deleteGameButtonTapped(_ navigationController: UINavigationController) {
        interactor?.deleteGame(completion: { (error) in
            if let err = error {
                self.gameView?.displayErrorMessage(err.localizedDescription)
            }
            else {
                self.router?.dismiss(navigationController)
            }
        })
    }
}

extension GamePresenter: PlayerInfoVCToGamePresenter {
    func updatePlayerInfoVC() {
        interactor?.fetchFreePositions()
    }
    
    func doneButtonTapped(_ navigationController: UINavigationController) {
        router?.dismissPlayerInfoVC(navigationController)
    }
}

extension GamePresenter: GameInteractorToGamePresenter {
    func onFetchPlayersSuccess(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        gameView?.displayPlayers(homeTeam, awayTeam)
    }
    
    func onUpdatedTeams(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        gameView?.displayPlayers(homeTeam, awayTeam)
    }
    
    func onFetchPlayersFailed(_ errorMessage: String) {
        gameView?.displayErrorMessage(errorMessage)
    }
    
    func verifiedIfUserCreatedGameOrHasJoinedGame(_ didUserCreateGame: Bool, _ didUserJoinGame: Bool) {
        gameView?.displayMenuAlert(didUserCreateGame, didUserJoinGame)
    }
    
    func onTimeConflictDetected(_ errorMessage: String) {
        gameView?.displayErrorMessage(errorMessage)
    }
    
    func onFailedToAddUserToGame(_ errorMessage: String) {
        gameView?.displayErrorMessage(errorMessage)
    }
    
    func onFetchFreePositionsSuccess(homeTeam: [Position], awayTeam: [Position], isWithHomeTeam: Bool) {
        playerInfoView?.displayFreePositions(homeTeam, awayTeam, isWithHomeTeam: isWithHomeTeam)
    }
}
