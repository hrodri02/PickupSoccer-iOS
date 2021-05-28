//
//  GameInteractor.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

class GameInteractor {
    weak var presenter: GameInteractorToGamePresenter?
    
    deinit {
        print("GameInteractor deinit")
    }
}

extension GameInteractor: GamePresenterToGameInteractor {
    func fetchPlayersForGame() {
        let players = [User(firstName: "Heriberto", lastName: "Rodriguez", isWithHomeTeam: true, position: .leftCenterMidfield),
                       User(firstName: "Brayan", lastName: "Rodriguez", isWithHomeTeam: false, position: .leftFullBack),
                       User(firstName: "Reyna", lastName: "Ramirez", isWithHomeTeam: true, position: .leftFullBack)]
        presenter?.onFetchPlayersSuccess(players)
    }
}
