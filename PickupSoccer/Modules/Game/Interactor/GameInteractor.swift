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
    var positionsOccupiedInHomeTeam = Set<Position>()
    var positionsOccupiedInAwayTeam = Set<Position>()
    var homeTeam = Set<User>()
    var awayTeam = Set<User>()
    // TODO: - this is for testing only
    var user: User!
    deinit {
        print("GameInteractor deinit")
    }
}

extension GameInteractor: GamePresenterToGameInteractor {
    func fetchPlayersForGame() {
        let players = [User(uid: 1,
                            firstName: "Heriberto",
                            lastName: "Rodriguez",
                            isWithHomeTeam: true,
                            position: .leftCenterMidfield),
                       User(uid: 2,
                            firstName: "Brayan",
                            lastName: "Rodriguez",
                            isWithHomeTeam: false,
                            position: .leftFullBack),
                       User(uid: 3,
                            firstName: "Reyna",
                            lastName: "Ramirez",
                            isWithHomeTeam: true,
                            position: .leftFullBack)]
        user = players[0]
        
        for player in players {
            if player.isWithHomeTeam {
                positionsOccupiedInHomeTeam.insert(player.position)
                homeTeam.insert(player)
            }
            else {
                positionsOccupiedInAwayTeam.insert(player.position)
                awayTeam.insert(player)
            }
        }
        
        presenter?.onFetchPlayersSuccess(homeTeam, awayTeam)
    }
    
    func updateUserPosition(_ position: Position, isHomeTeam: Bool) {
        if isPositionFree(position, isPositionForHomeTeam: isHomeTeam) {
            removeUserFromCurrentTeam()
            updateUser(newPosition: position, isNewPositionInHomeTeam: isHomeTeam)
            addUpdatedUserToTeam(isNewTeamHomeTeam: isHomeTeam)
            markNewPositionAsOccupied(position, isNewPositionInHomeTeam: isHomeTeam)
            presenter?.onUpdatedTeams(homeTeam, awayTeam)
        }
    }
    
    private func isPositionFree(_ position: Position, isPositionForHomeTeam: Bool) -> Bool {
        if isPositionForHomeTeam {
            return !positionsOccupiedInHomeTeam.contains(position)
        }
        
        return !positionsOccupiedInAwayTeam.contains(position)
    }
    
    private func removeUserFromCurrentTeam() {
        if user.isWithHomeTeam {
            positionsOccupiedInHomeTeam.remove(user.position)
            homeTeam.remove(user)
        }
        else {
            positionsOccupiedInAwayTeam.remove(user.position)
            awayTeam.remove(user)
        }
    }
    
    private func updateUser(newPosition: Position, isNewPositionInHomeTeam: Bool) {
        user.isWithHomeTeam = isNewPositionInHomeTeam
        user.position = newPosition
    }
    
    private func addUpdatedUserToTeam(isNewTeamHomeTeam: Bool) {
        if isNewTeamHomeTeam {
            homeTeam.insert(user)
        }
        else {
            awayTeam.insert(user)
        }
    }
    
    private func markNewPositionAsOccupied(_ position: Position, isNewPositionInHomeTeam: Bool) {
        if isNewPositionInHomeTeam {
            positionsOccupiedInHomeTeam.insert(position)
        }
        else {
            positionsOccupiedInAwayTeam.insert(position)
        }
    }
    
    func checkIfUserIsPartOfGame() {
        presenter?.verifiedIfUserIsPartOfGame(user.position != .none)
    }
    
    func removeUserFromGame() {
        if user.isWithHomeTeam {
            homeTeam.remove(user)
            positionsOccupiedInHomeTeam.remove(user.position)
        }
        else {
            awayTeam.remove(user)
            positionsOccupiedInAwayTeam.remove(user.position)
        }
        
        user.position = .none
        presenter?.onUpdatedTeams(homeTeam, awayTeam)
    }
}
