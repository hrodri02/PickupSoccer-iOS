//
//  GamesModuleTests.swift
//  GamesModuleTests
//
//  Created by Heriberto Rodriguez on 5/14/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import XCTest
import CoreLocation
@testable import PickupSoccer

class GamesInteractorTests: XCTestCase {
    var gamesInteractor: GamesInteractor!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        gamesInteractor = GamesInteractor(dataStore: MockDataStore())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        gamesInteractor = nil
        super.tearDown()
    }
    
    func testFectchGamesSuccess() {
        let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let latitudeDelta: CLLocationDegrees = 10
        let longtidueDelta: CLLocationDegrees = 10
        gamesInteractor.dataStore.fetchGames(center: center,
                                             latitudeDelta: latitudeDelta,
                                             longitudeDelta: longtidueDelta)
        { (result) in
            switch result {
            case .success(let coordinateToGame):
                for (_, game) in coordinateToGame {
                    print(game)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func testFecthGamesFailed() {
        let center = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let latitudeDelta: CLLocationDegrees = 10
        let longtidueDelta: CLLocationDegrees = 10
        gamesInteractor.dataStore.fetchGames(center: center,
                                             latitudeDelta: latitudeDelta,
                                             longitudeDelta: longtidueDelta)
        { (result) in
            switch result {
            case .success(let coordinateToGame):
                for (_, game) in coordinateToGame {
                    print(game)
                }
            case .failure(let error):
                XCTAssertEqual(error as? DB_Error, DB_Error.failedToFecthGames)
            }
        }
    }
}

class MockDataStore: DataStore {
    let games: [Game]
    var fetchedGamesFromDB: Bool
    init() {
        let inside1 = CLLocationCoordinate2D(latitude: 1, longitude: 1)
        let inside2 = CLLocationCoordinate2D(latitude: -1, longitude: 1)
        let inside3 = CLLocationCoordinate2D(latitude: -1, longitude: -1)
        let inside4 = CLLocationCoordinate2D(latitude: 1, longitude: -1)
        let outside = CLLocationCoordinate2D(latitude: 6, longitude: 6)
        games = [Game(inside1, DateInterval(start: Date(), duration: 3600)),
                 Game(inside2, DateInterval(start: Date(), duration: 3600)),
                 Game(inside3, DateInterval(start: Date(), duration: 3600)),
                 Game(inside4, DateInterval(start: Date(), duration: 3600)),
                 Game(outside, DateInterval(start: Date(), duration: 3600)),]
        fetchedGamesFromDB = true
    }
    
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[CLLocationCoordinate2D : Game], Error>) -> Void)
    {
        /*
        -90 <= latitude <= 90
        -180 <= longitude <= 180
        */
        if fetchedGamesFromDB {
            var coordinateToGame = [CLLocationCoordinate2D : Game]()
            for game in games {
                if game.location.latitude > center.latitude - latitudeDelta / 2.0 &&
                   game.location.latitude < center.latitude + latitudeDelta / 2.0 &&
                   game.location.longitude < center.longitude + longitudeDelta / 2.0 &&
                   game.location.longitude > center.longitude - longitudeDelta / 2.0
                {
                    coordinateToGame[game.location] = game
                }
            }
            completion(.success(coordinateToGame))
        }
        else {
            completion(.failure(DB_Error.failedToFecthGames))
        }
    }
    
    func save(_ game: Game, completion: @escaping (Error?) -> Void) {
        
    }
}

enum DB_Error: Error {
    case failedToFecthGames
}
