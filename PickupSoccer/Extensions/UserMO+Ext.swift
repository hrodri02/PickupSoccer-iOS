//
//  UserMO+Ext.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/10/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

extension UserMO: User {
    var joinedGames: Array<Game> {
        get {
            var games = Array<Game>()
            if let playerInfoMOs = self.games {
                for playerInfoMO in playerInfoMOs {
                    if let playerInfoMO = playerInfoMO as? PlayerInfoMO, let gameMO = playerInfoMO.game {
                        games.append(gameMO)
                    }
                }
            }
            return games
        }
    }
}
