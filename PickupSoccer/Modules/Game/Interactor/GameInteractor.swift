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
    
    private let dataStore: DataStore
    private let game: Game
    private var positionsOccupiedInHomeTeam = Set<Position>()
    private var positionsOccupiedInAwayTeam = Set<Position>()
    private var homeTeam = [String : Position]()
    private var awayTeam = [String : Position]()
    private var user: User?
    
    init(dataStore: DataStore, game: Game) {
        self.dataStore = dataStore
        self.game = game
        self.user = UserManager.shared.getUser()
    }
    
    deinit {
        print("GameInteractor deinit")
    }
}

extension GameInteractor: GamePresenterToGameInteractor {
    func fetchPlayersForGame() {
        for playerInfo in game.playersInfo {
            let uid = playerInfo.uid
            if playerInfo.isWithHomeTeam {
                homeTeam[uid] = playerInfo.positionEnum
                positionsOccupiedInHomeTeam.insert(playerInfo.positionEnum)
            }
            else {
                awayTeam[uid] = playerInfo.positionEnum
                positionsOccupiedInAwayTeam.insert(playerInfo.positionEnum)
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
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        if let position = homeTeam[uid] {
            if !isNewPositionInHomeTeam {
                removeUserFromCurrentTeam(position: position, isWithHomeTeam: true)
            }
            
            updateUserPosition(position: newPosition, isWithHomeTeam: isNewPositionInHomeTeam)
        }
        else if let position = awayTeam[uid] {
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
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        if isWithHomeTeam {
            positionsOccupiedInHomeTeam.remove(position)
            homeTeam[uid] = nil
        }
        else {
            positionsOccupiedInAwayTeam.remove(position)
            awayTeam[uid] = nil
        }
    }
    
    private func updateUserPosition(position: Position, isWithHomeTeam: Bool) {
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        guard let gameId = game.id else {
            fatalError("Failed to get gameId")
        }
        
        dataStore.updateUserInfoForGame(uid: uid,
                                        gameId: gameId,
                                        position: position,
                                        isWithHomeTeam: isWithHomeTeam)
        { (result) in
            switch (result) {
            case .success(let playerInfo):
                if playerInfo.isWithHomeTeam {
                    self.homeTeam[uid] = playerInfo.positionEnum
                    self.positionsOccupiedInHomeTeam.insert(playerInfo.positionEnum)
                }
                else {
                    self.awayTeam[uid] = playerInfo.positionEnum
                    self.positionsOccupiedInAwayTeam.insert(playerInfo.positionEnum)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func addUserToGame(position: Position, isWithHomeTeam: Bool) {
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        guard let gameId = game.id else {
            fatalError("Failed to get gameId")
        }
        
        dataStore.addUserToGame(uid: uid,
                                gameId: gameId,
                                position: position,
                                isWithHomeTeam: isWithHomeTeam)
        { (result) in
            switch (result) {
            case .success(let playerInfo):
                if playerInfo.isWithHomeTeam {
                    self.homeTeam[uid] = playerInfo.positionEnum
                    self.positionsOccupiedInHomeTeam.insert(playerInfo.positionEnum)
                }
                else {
                    self.awayTeam[uid] = playerInfo.positionEnum
                    self.positionsOccupiedInAwayTeam.insert(playerInfo.positionEnum)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func checkIfUserIsPartOfGame() {
        guard let uid = UserManager.shared.getUser()?.uid else {
            fatalError("Failed to get uid")
        }
        
        let isUserInHomeTeam = homeTeam[uid] != nil
        let isUserInAwayTeam = awayTeam[uid] != nil
        
        presenter?.verifiedIfUserIsPartOfGame(isUserInHomeTeam || isUserInAwayTeam)
    }
    
    func removeUserFromGame() {
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        guard let gameId = game.id else {
            fatalError("Failed to get gameId")
        }
        
        dataStore.removeUserFromGame(uid: uid, gameId: gameId) { (result) in
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
