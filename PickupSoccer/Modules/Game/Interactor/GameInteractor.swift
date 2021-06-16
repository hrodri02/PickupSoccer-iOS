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
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    init(dataStore: DataStore, game: Game, user: User?) {
        self.dataStore = dataStore
        self.game = game
        self.user = user
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
    
    func newPositionSelected(_ position: Position, isHomeTeam: Bool) {
        if isUserPartOfGame() {
            if isPositionFree(position, isPositionForHomeTeam: isHomeTeam) {
                updateUserPosition(newPosition: position, isNewPositionInHomeTeam: isHomeTeam)
            }
        }
        else {
            if let game = isTimeConflict() {
                let gameDate = GameInteractor.dateFormatter.string(from: game.timeInterval.start)
                let gameDuration = getPresentableGameDuration(game: game)
                let errorMessage = "Conflict with game: address = \(game.address ?? ""), start date = \(gameDate), duration = \(gameDuration)"
                presenter?.onTimeConflictDetected(errorMessage)
            }
            else if isPositionFree(position, isPositionForHomeTeam: isHomeTeam) {
                addUserToGame(position: position, isWithHomeTeam: isHomeTeam)
            }
        }
    }
    
    private func getPresentableGameDuration(game: Game) -> String {
        let durationInSecs = Int(game.timeInterval.duration)
        let durationInMins = durationInSecs / 60
        let hours = Int(durationInMins) / 60
        let mins = Int(durationInMins) % 60
        return "\(hours) h \(mins) m"
    }
    
    private func isPositionFree(_ position: Position, isPositionForHomeTeam: Bool) -> Bool {
        if isPositionForHomeTeam {
            return !positionsOccupiedInHomeTeam.contains(position)
        }

        return !positionsOccupiedInAwayTeam.contains(position)
    }
    
    private func updateUserPosition(newPosition: Position, isNewPositionInHomeTeam: Bool) {
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        if let position = homeTeam[uid] {
            if !isNewPositionInHomeTeam {
                removeUserFromCurrentTeam(position: position, isWithHomeTeam: true)
            }
            
            updateUserPositionInDataStore(position: newPosition, isWithHomeTeam: isNewPositionInHomeTeam)
        }
        else if let position = awayTeam[uid] {
            if isNewPositionInHomeTeam {
                removeUserFromCurrentTeam(position: position, isWithHomeTeam: false)
            }
            
            updateUserPositionInDataStore(position: newPosition, isWithHomeTeam: isNewPositionInHomeTeam)
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
    
    private func updateUserPositionInDataStore(position: Position, isWithHomeTeam: Bool) {
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
                self.presenter?.onUpdatedTeams(homeTeam, awayTeam)
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
                self.presenter?.onUpdatedTeams(self.homeTeam, self.awayTeam)
            case .failure(let error):
                self.presenter?.onFailedToAddUserToGame(error.localizedDescription)
            }
        }
    }
    
    /*
        T(n) = O(nlogn), where n = length of joined games array
        S(n) = O(n)
     */
    private func isTimeConflict() -> Game? {
        let newGameStartDate = game.timeInterval.start
        let newGameEndDate = game.timeInterval.end
        
        guard let joinedGames = user?.joinedGames else {
            fatalError("Failed to get games user joined")
        }
            
        let games = joinedGames.sorted { (game1, game2) -> Bool in
            return game1.timeInterval.start < game2.timeInterval.start
        }
        
        let calendar = Calendar.current
        for game in games {
            let currGameStartDate = game.timeInterval.start
            let dayComparisonRes = calendar.compare(newGameStartDate, to: currGameStartDate, toGranularity: .day)
            if dayComparisonRes == .orderedSame {
                let startDate = max(currGameStartDate, newGameStartDate)
                let currGameEndDate = game.timeInterval.end
                let endDate = min(currGameEndDate, newGameEndDate)
                let minuteComparisonRes = calendar.compare(startDate, to: endDate, toGranularity: .minute)
                if minuteComparisonRes == .orderedAscending {
                    return game
                }
            }
            else if dayComparisonRes == .orderedAscending {
                break
            }
        }
        
        return nil
    }
    
    func checkIfUserIsPartOfGame() {
        presenter?.verifiedIfUserIsPartOfGame(isUserPartOfGame())
    }
    
    private func isUserPartOfGame() -> Bool {
        guard let uid = UserManager.shared.getUser()?.uid else {
            fatalError("Failed to get uid")
        }
        
        let isUserInHomeTeam = homeTeam[uid] != nil
        let isUserInAwayTeam = awayTeam[uid] != nil
        
        return isUserInHomeTeam || isUserInAwayTeam
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
