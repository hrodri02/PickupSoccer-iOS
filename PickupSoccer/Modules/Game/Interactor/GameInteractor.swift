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
    
    func checkIfUserCreatedGameOrHasJoinedGame() {
        guard let uid = user?.uid else {
            fatalError("Failed to get user id")
        }
        
        let isUserCreatorOfGame = uid == game.creatorId
        let isUserInGame = isUserPartOfGame(uid)
        presenter?.verifiedIfUserCreatedGameOrHasJoinedGame(isUserCreatorOfGame, isUserInGame)
    }
    
    private func isUserPartOfGame(_ uid: String) -> Bool {
        let isUserInHomeTeam = homeTeam[uid] != nil
        let isUserInAwayTeam = awayTeam[uid] != nil
        
        return isUserInHomeTeam || isUserInAwayTeam
    }
    
    func fetchFreePositions() {
        let allPositions: [Position] = [.goalKeeper, .leftFullBack, .leftCenterBack,
                                        .rightCenterBack, .rightFullBack, .leftSideMidfielder,
                                        .leftCenterMidfield, .rightCenterMidField, .rightSideMidfielder,
                                        .leftCenterForward, .rightCenterForward]
        
        let positionsOccupiedInHomeTeam  = Set<Position>(homeTeam.values)
        let positionsOccupiedInAwayTeam  = Set<Position>(awayTeam.values)
        var freePositionsInHomeTeam = [Position]()
        var freePositionsInAwayTeam = [Position]()
        for position in allPositions {
            if !positionsOccupiedInHomeTeam.contains(position) {
                freePositionsInHomeTeam.append(position)
            }
            
            if !positionsOccupiedInAwayTeam.contains(position) {
                freePositionsInAwayTeam.append(position)
            }
        }
        
        guard let uid = user?.uid else {
            fatalError("Failed to get user id")
        }
        
        let isWithHomeTeam = homeTeam[uid] != nil
        presenter?.onFetchFreePositionsSuccess(homeTeam: freePositionsInHomeTeam,
                                               awayTeam: freePositionsInAwayTeam,
                                               isWithHomeTeam: isWithHomeTeam)
    }
    
    func newPositionSelected(_ position: Position, isWithHomeTeam: Bool) {
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        if isUserPartOfGame(uid) {
            updateUserPosition(newPosition: position, isNewPositionInHomeTeam: isWithHomeTeam)
        }
        else if let game = isTimeConflict() {
            let gameDate = GameInteractor.dateFormatter.string(from: game.timeInterval.start)
            let gameDuration = getPresentableGameDuration(game: game)
            let errorMessage = "Conflict with game: address = \(game.address ?? ""), start date = \(gameDate), duration = \(gameDuration)"
            presenter?.onTimeConflictDetected(errorMessage)
        }
        else {
            addUserToGame(position: position, isWithHomeTeam: isWithHomeTeam)
        }
    }
    
    private func updateUserPosition(newPosition: Position, isNewPositionInHomeTeam: Bool) {
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        if let position = homeTeam[uid] {
            if !isNewPositionInHomeTeam {
                homeTeam[uid] = nil
            }
            
            positionsOccupiedInHomeTeam.remove(position)
            updateUserPositionInDataStore(position: newPosition, isWithHomeTeam: isNewPositionInHomeTeam)
        }
        else if let position = awayTeam[uid] {
            if isNewPositionInHomeTeam {
                awayTeam[uid] = nil
            }
            
            positionsOccupiedInAwayTeam.remove(position)
            updateUserPositionInDataStore(position: newPosition, isWithHomeTeam: isNewPositionInHomeTeam)
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
                self.presenter?.onFailedToUpdatePlayerPosition(error.localizedDescription)
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
    
    private func getPresentableGameDuration(game: Game) -> String {
        let durationInSecs = Int(game.timeInterval.duration)
        let durationInMins = durationInSecs / 60
        let hours = Int(durationInMins) / 60
        let mins = Int(durationInMins) % 60
        return "\(hours) h \(mins) m"
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
    
    func removeUserFromGame() {
        guard let uid = user?.uid else {
            fatalError("Failed to get uid")
        }
        
        guard let gameId = game.id else {
            fatalError("Failed to get gameId")
        }
        
        dataStore.removeUserFromGame(uid: uid, gameId: gameId) { (result) in
            switch result {
            case .success(_):
                self.removeUserFromCurrentTeam(uid: uid)
                self.presenter?.onUpdatedTeams(self.homeTeam,
                                               self.awayTeam)
            case .failure(let error):
                self.presenter?.onFailedToRemoveUserFromGame(error.localizedDescription)
            }
        }
    }
    
    private func removeUserFromCurrentTeam(uid: String) {
        if let position = homeTeam[uid] {
            homeTeam[uid] = nil
            positionsOccupiedInHomeTeam.remove(position)
        }
        else if let position = awayTeam[uid] {
            awayTeam[uid] = nil
            positionsOccupiedInAwayTeam.remove(position)
        }
    }
    
    func deleteGame(completion: (Error?) -> Void) {
        guard let gameId = game.id else {
            fatalError("Failed to get game id")
        }
        
        dataStore.deleteGame(gameId, completion: completion)
    }
}
