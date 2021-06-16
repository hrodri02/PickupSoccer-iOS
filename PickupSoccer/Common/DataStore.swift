//
//  DataStore.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/24/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation

protocol DataStore {
    // MARK: - methods for saving, updating, deleting, and fetching a user
    func fetchAllUsers()
    func fetchUser(with uid: String, completion: (Result<User, Error>) -> Void)
    func saveUser(firstName: String,
                  lastName: String,
                  completion: (Result<User, Error>) -> Void)
    func deleteAllUsers()
    // MARK: - methods for saving, updating, deleting, and fetching a game
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[Game], Error>) -> Void)
    func saveGame(_ address: String,
                  _ location: CLLocationCoordinate2D,
                  _ dateInterval: DateInterval,
                  completion: @escaping (Error?) -> Void)
    func deleteAllGames()
    // MARK: - methods for saving, updating, deleting, and fetching player information
    func addUserToGame(uid: String,
                       gameId: String,
                       position: Position,
                       isWithHomeTeam: Bool,
                       completion: (Result<PlayerInfoProtocol, Error>) -> Void)
    func updateUserInfoForGame(uid: String,
                               gameId: String,
                               position: Position,
                               isWithHomeTeam: Bool,
                               completion: (Result<PlayerInfoProtocol, Error>) -> Void)
    func removeUserFromGame(uid: String,
                            gameId: String,
                            completion: (Result<PlayerInfoProtocol, Error>) -> Void)
}
