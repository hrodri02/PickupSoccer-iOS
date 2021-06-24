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
    
    func didSelectNewPosition(_ position: Position, isHomeTeam: Bool) {
        interactor?.newPositionSelected(position, isHomeTeam: isHomeTeam)
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
    
    func exitGameButtonTapped() {
        interactor?.checkIfUserIsPartOfGame()
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
    
    func onFetchPlayersFailed(_ errorMessage: String) {
        gameView?.displayErrorMessage(errorMessage)
    }
    
    func onUpdatedTeams(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        gameView?.displayPlayers(homeTeam, awayTeam)
    }
    
    func onTimeConflictDetected(_ errorMessage: String) {
        gameView?.displayErrorMessage(errorMessage)
    }
    
    func onFailedToAddUserToGame(_ errorMessage: String) {
        gameView?.displayErrorMessage(errorMessage)
    }
    
    func verifiedIfUserIsPartOfGame(_ isPartOfGame: Bool) {
        if isPartOfGame {
            gameView?.displayConfirmationAlert()
        }
        else {
            gameView?.displayErrorMessage("You are not part of the Game")
        }
    }
    
    func verifiedIfUserCreatedGameOrHasJoinedGame(_ didUserCreateGame: Bool, _ didUserJoinGame: Bool) {
        gameView?.displayMenuAlert(didUserCreateGame, didUserJoinGame)
    }
    
    func onFetchFreePositionsSuccess(homeTeam: [Position], awayTeam: [Position], isWithHomeTeam: Bool) {
        playerInfoView?.displayFreePositions(homeTeam, awayTeam, isWithHomeTeam: isWithHomeTeam)
    }
}
