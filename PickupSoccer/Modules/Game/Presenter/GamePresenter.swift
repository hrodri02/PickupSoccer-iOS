//
//  GamePresenter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GamePresenter {
    weak var view: GamePresenterToGameView?
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
        interactor?.checkIfUserCreatedGame()
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
                self.view?.displayErrorMessage(err.localizedDescription)
            }
            else {
                self.router?.dismiss(navigationController)
            }
        })
    }
}

extension GamePresenter: GameInteractorToGamePresenter {
    func onFetchPlayersSuccess(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        view?.displayPlayers(homeTeam, awayTeam)
    }
    
    func onFetchPlayersFailed(_ errorMessage: String) {
        view?.displayErrorMessage(errorMessage)
    }
    
    func onUpdatedTeams(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        view?.displayPlayers(homeTeam, awayTeam)
    }
    
    func onTimeConflictDetected(_ errorMessage: String) {
        view?.displayErrorMessage(errorMessage)
    }
    
    func onFailedToAddUserToGame(_ errorMessage: String) {
        view?.displayErrorMessage(errorMessage)
    }
    
    func verifiedIfUserIsPartOfGame(_ isPartOfGame: Bool) {
        if isPartOfGame {
            view?.displayConfirmationAlert()
        }
        else {
            view?.displayErrorMessage("You are not part of the Game")
        }
    }
    
    func verifiedIfUserCreatedGame(_ didUserCreateGame: Bool) {
        view?.displayMenuAlert(didUserCreateGame)
    }
}
