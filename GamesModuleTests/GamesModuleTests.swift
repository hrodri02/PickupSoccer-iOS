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
            case .success(let games):
            for game in games {
                print("{location:\n\t{latitude = \(game.coordinate.latitude)},\n\t{longitude = \(game.coordinate.longitude)}")
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
            case .success(let games):
                for game in games {
                    print(game)
                }
            case .failure(let error):
                XCTAssertEqual(error as? DB_Error, DB_Error.failedToFecthGames)
            }
        }
    }
}

class MockGame: Game {
    var gameAddress: String
    var coordinate: CLLocationCoordinate2D
    var timeInterval: DateInterval
    
    init(location: CLLocationCoordinate2D) {
        gameAddress = ""
        timeInterval = DateInterval()
        coordinate = location
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
            completion(.failure(DB_Error.failedToFecthGames))
        }
    }
    
    func saveGame(_ address: String,
                  _ location: CLLocationCoordinate2D,
                  _ dateInterval: DateInterval,
                  completion: @escaping (Error?) -> Void)
    {
        
    }
}

enum DB_Error: Error {
    case failedToFecthGames
}
