//
//  GameInteractor.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

class GameInteractor {
    private let dataStore: DataStore
    private let game: Game
    weak var presenter: GameInteractorToGamePresenter?
    private var positionsOccupiedInHomeTeam = Set<Position>()
    private var positionsOccupiedInAwayTeam = Set<Position>()
    private var homeTeam = [User : Position]()
    private var awayTeam = [User : Position]()
    
    init(dataStore: DataStore, game: Game) {
        self.dataStore = dataStore
        self.game = game
    }
    
    deinit {
        print("GameInteractor deinit")
    }
}

extension GameInteractor: GamePresenterToGameInteractor {
    func fetchPlayersForGame() {
        for playerInfo in game.playersInfo {
            if let userMO = playerInfo.player {
                let user = User(userMO: userMO)
                if playerInfo.isWithHomeTeam {
                    homeTeam[user] = playerInfo.positionEnum
                    positionsOccupiedInHomeTeam.insert(playerInfo.positionEnum)
                }
                else {
                    awayTeam[user] = playerInfo.positionEnum
                    positionsOccupiedInAwayTeam.insert(playerInfo.positionEnum)
                }
            }
        }
        
        presenter?.onFetchPlayersSuccess(homeTeam, awayTeam)
    }
    
    func updateUserPosition(_ position: Position, isHomeTeam: Bool) {
        if isPositionFree(position, isPositionForHomeTeam: isHomeTeam) {
            updateUserInfo(newPosition: position, isNewPositionInHomeTeam: isHomeTeam)
            presenter?.onUpdatedTeams(homeTeam, awayTeam)
        }
    }
    
    private func isPositionFree(_ position: Position, isPositionForHomeTeam: Bool) -> Bool {
        if isPositionForHomeTeam {
            return !positionsOccupiedInHomeTeam.contains(position)
        }

        return !positionsOccupiedInAwayTeam.contains(position)
    }
    
    private func updateUserInfo(newPosition: Position, isNewPositionInHomeTeam: Bool) {
        guard let user = UserManager.shared.getUser() else {
            fatalError("Failed to get user")
        }
        
        if let position = homeTeam[user] {
            if !isNewPositionInHomeTeam {
                removeUserFromCurrentTeam(position: position, isWithHomeTeam: true)
            }
            
            updateUserPosition(position: newPosition, isWithHomeTeam: isNewPositionInHomeTeam)
        }
        else if let position = awayTeam[user] {
            if isNewPositionInHomeTeam {
                removeUserFromCurrentTeam(position: position, isWithHomeTeam: false)
            }
            
            updateUserPosition(position: newPosition, isWithHomeTeam: isNewPositionInHomeTeam)
        }
        else {
            addUserToGame(position: newPosition, isWithHomeTeam: isNewPositionInHomeTeam)
        }
    }
    
    private func removeUserFromCurrentTeam(position: Position, isWithHomeTeam: Bool) {
        guard let user = UserManager.shared.getUser() else {
            fatalError("Failed to get user")
        }
        
        if isWithHomeTeam {
            positionsOccupiedInHomeTeam.remove(position)
            homeTeam[user] = nil
        }
        else {
            positionsOccupiedInAwayTeam.remove(position)
            awayTeam[user] = nil
        }
    }
    
    private func updateUserPosition(position: Position, isWithHomeTeam: Bool) {
        guard let user = UserManager.shared.getUser() else {
            fatalError("Failed to get user")
        }
        
        guard let gameId = game.id else {
            fatalError("Failed to get gameId")
        }
        
        dataStore.updateUserInfoForGame(uid: user.uid,
                                        gameId: gameId,
                                        position: position,
                                        isWithHomeTeam: isWithHomeTeam)
        { (result) in
            switch (result) {
            case .success(let playerInfo):
                if playerInfo.isWithHomeTeam {
                    self.homeTeam[user] = playerInfo.positionEnum
                    self.positionsOccupiedInHomeTeam.insert(playerInfo.positionEnum)
                }
                else {
                    self.awayTeam[user] = playerInfo.positionEnum
                    self.positionsOccupiedInAwayTeam.insert(playerInfo.positionEnum)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func addUserToGame(position: Position, isWithHomeTeam: Bool) {
        guard let user = UserManager.shared.getUser() else {
            fatalError("Failed to get user")
        }
        
        guard let gameId = game.id else {
            fatalError("Failed to get gameId")
        }
        
        dataStore.addUserToGame(uid: user.uid,
                                gameId: gameId,
                                position: position,
                                isWithHomeTeam: isWithHomeTeam)
        { (result) in
            switch (result) {
            case .success(let playerInfo):
                if playerInfo.isWithHomeTeam {
                    self.homeTeam[user] = playerInfo.positionEnum
                    self.positionsOccupiedInHomeTeam.insert(playerInfo.positionEnum)
                }
                else {
                    self.awayTeam[user] = playerInfo.positionEnum
                    self.positionsOccupiedInAwayTeam.insert(playerInfo.positionEnum)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func checkIfUserIsPartOfGame() {
        guard let user = UserManager.shared.getUser() else {
            fatalError("Failed to get user")
        }
        
        let isUserInHomeTeam = homeTeam[user] != nil
        let isUserInAwayTeam = awayTeam[user] != nil
        
        presenter?.verifiedIfUserIsPartOfGame(isUserInHomeTeam || isUserInAwayTeam)
    }
    
    func removeUserFromGame() {
        guard let user = UserManager.shared.getUser() else {
            fatalError("Failed to get user")
        }
        
        guard let gameId = game.id else {
            fatalError("Failed to get gameId")
        }
        
        dataStore.removeUserFromGame(uid: user.uid, gameId: gameId) { (result) in
            switch result {
            case .success(let playerInfo):
                self.removeUserFromCurrentTeam(position: playerInfo.positionEnum,
                                               isWithHomeTeam: playerInfo.isWithHomeTeam)
                self.presenter?.onUpdatedTeams(self.homeTeam,
                                               self.awayTeam)
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
}
