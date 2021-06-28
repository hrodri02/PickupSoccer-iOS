//
//  GamesModuleTests.swift
//  GamesModuleTests
//
//  Created by Heriberto Rodriguez on 5/14/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import XCTest
import CoreLocation
import CoreData
@testable import PickupSoccer

class GamesInteractorTests: XCTestCase {
    var gamesInteractor: GamesInteractor!
    var presenter: MockPresenter!
    var mockDataStore: MockDataStore!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        mockDataStore = MockDataStore()
        gamesInteractor = GamesInteractor(dataStore: mockDataStore)
        presenter = MockPresenter()
        gamesInteractor.presenter = presenter
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockDataStore = nil
        presenter = nil
        gamesInteractor = nil
        super.tearDown()
    }
    
    func testFectchGamesSuccess() {
        let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let latitudeDelta: CLLocationDegrees = 10
        let longtidueDelta: CLLocationDegrees = 10
        mockDataStore.fetchedGamesFromDB = true
        gamesInteractor.fetchGames(center: center,
                                   latitudeDelta: latitudeDelta,
                                   longitudeDelta: longtidueDelta)
        let numValidGames = 4
        XCTAssertEqual(presenter.games.count, numValidGames)
    }
    
    private func printGame(_ game: Game) {
        print("{location:\n\t{latitude = \(game.coordinate.latitude)},\n\t{longitude = \(game.coordinate.longitude)}")
    }
    
    func testFecthGamesFailed() {
        let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let latitudeDelta: CLLocationDegrees = 10
        let longtidueDelta: CLLocationDegrees = 10
        mockDataStore.fetchedGamesFromDB = false
        gamesInteractor.fetchGames(center: center,
                                           latitudeDelta: latitudeDelta,
                                           longitudeDelta: longtidueDelta)
        XCTAssertNotNil(presenter.errorMessage)
    }
}

class MockPresenter: GamesInteractorToGamesPresenter {
    var games = [Game]()
    var errorMessage: String?
    
    func onFetchGamesSuccess(_ games: [Game]) {
        self.games = games
    }
    
    func onFetchGamesFailed(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
}

class MockGame: Game {
    var creatorId: String?
    
    var id: String?
    var address: String?
    var playersInfo: Array<PlayerInfoProtocol>
    var gameAddress: String
    var coordinate: CLLocationCoordinate2D
    var timeInterval: DateInterval
    
    init(location: CLLocationCoordinate2D) {
        gameAddress = ""
        timeInterval = DateInterval()
        coordinate = location
        playersInfo = []
    }
}

class MockDataStore: DataStore {
    let games: [Game]
    var fetchedGamesFromDB: Bool
    
    init() {
        
        let inside1 = MockGame(location: CLLocationCoordinate2D(latitude: 1, longitude: 1))
        let inside2 = MockGame(location: CLLocationCoordinate2D(latitude: -1, longitude: 1))
        let inside3 = MockGame(location: CLLocationCoordinate2D(latitude: -1, longitude: -1))
        let inside4 = MockGame(location: CLLocationCoordinate2D(latitude: 1, longitude: -1))
        let outside = MockGame(location: CLLocationCoordinate2D(latitude: 6, longitude: 6))
        games = [inside1, inside2, inside3, inside4, outside]
        fetchedGamesFromDB = true
    }
    
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[Game], Error>) -> Void)
    {
        /*
        -90 <= latitude <= 90
        -180 <= longitude <= 180
        */
        if fetchedGamesFromDB {
            var gamesInRegion = [Game]()
            for game in games {
                let location = game.coordinate
                if location.latitude > center.latitude - latitudeDelta / 2 &&
                   location.latitude < center.latitude + latitudeDelta / 2 &&
                   location.longitude > center.longitude - longitudeDelta / 2 &&
                   location.longitude < center.longitude + longitudeDelta / 2
                {
                    gamesInRegion.append(game)
                }
            }
            completion(Result.success(gamesInRegion))
        }
        else {
            completion(Result.failure(DB_Error.failedToFecthGames))
        }
    }
    
    func saveGame(_ creatorId: String,
                  _ address: String,
                  _ location: CLLocationCoordinate2D,
                  _ dateInterval: DateInterval,
                  completion: @escaping (Error?) -> Void)
    {
        
    }
    
    
    
    func deleteGame(_ gameId: String, completion: (Error?) -> Void) {
        
    }
    
    func fetchAllUsers() {
        
    }
    
    func fetchUser(with uid: String, completion: (Result<User, Error>) -> Void) {
        
    }
    
    func saveUser(firstName: String, lastName: String, completion: (Result<User, Error>) -> Void) {
        
    }
    
    func deleteAllUsers() {
        
    }
    
    func deleteAllGames() {
        
    }
    
    func addUserToGame(uid: String, gameId: String, position: Position, isWithHomeTeam: Bool, completion: (Result<PlayerInfoProtocol, Error>) -> Void) {
        
    }
    
    func updateUserInfoForGame(uid: String, gameId: String, position: Position, isWithHomeTeam: Bool, completion: (Result<PlayerInfoProtocol, Error>) -> Void) {
        
    }
    
    func removeUserFromGame(uid: String, gameId: String, completion: (Result<PlayerInfoProtocol, Error>) -> Void) {
        
    }
}

enum DB_Error: LocalizedError {
    case failedToFecthGames
    
    var errorDescription: String? {
        switch self {
        case .failedToFecthGames:
            return NSLocalizedString("Failed to fetch games", comment: "")
        }
    }
}
