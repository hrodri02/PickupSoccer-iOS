//
//  GamePresenter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

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
}

extension GamePresenter: GameInteractorToGamePresenter {
    func onFetchPlayersSuccess(_ players: [User]) {
        view?.displayPlayers(players)
    }
    
    func onFetchPlayersFailed(_ errorMessage: String) {
        view?.displayErrorMessage(errorMessage)
    }
}
