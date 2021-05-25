//
//  GameInteractor.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

class GameInteractor {
    var presenter: GameInteractorToGamePresenter?
    
    deinit {
        print("GameInteractor deinit")
    }
}

extension GameInteractor: GamePresenterToGameInteractor {
    func fetchPlayersForGame() {
        let players = [User(firstName: "Heriberto", lastName: "Rodriguez", position: .centerMidfield)]
        presenter?.onFetchPlayersSuccess(players)
    }
}
