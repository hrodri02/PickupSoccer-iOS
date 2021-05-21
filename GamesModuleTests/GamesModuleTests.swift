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
                print("{location:\n\t{latitude = \(game.location?.latitude)},\n\t{longitude = \(game.location?.longitude)}")
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

class MockDataStore: DataStore {
    let games: [GameMO]
    var fetchedGamesFromDB: Bool
    
    init() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let inside1 = LocationMO(context: managedObjectContext!) //CLLocationCoordinate2D(latitude: 1, longitude: 1)
        inside1.latitude = 1.0
        inside1.longitude = 1.0
        
        let inside2 = LocationMO(context: managedObjectContext!) // CLLocationCoordinate2D(latitude: -1, longitude: 1)
        inside2.latitude = -1.0
        inside2.longitude = 1.0
        
        let inside3 = LocationMO(context: managedObjectContext!) // CLLocationCoordinate2D(latitude: -1, longitude: -1)
        inside3.latitude = -1.0
        inside3.longitude = -1.0
        
        let inside4 = LocationMO(context: managedObjectContext!) //CLLocationCoordinate2D(latitude: 1, longitude: -1)
        inside4.latitude = 1.0
        inside4.longitude = -1.0
        
        let outside = LocationMO(context: managedObjectContext!) //CLLocationCoordinate2D(latitude: 6, longitude: 6)
        outside.latitude = 6.0
        outside.longitude = 6.0
        
        let game1 = GameMO(context: managedObjectContext!)
        game1.location = inside1
        
        let game2 = GameMO(context: managedObjectContext!)
        game2.location = inside2
        
        let game3 = GameMO(context: managedObjectContext!)
        game3.location = inside3
        
        let game4 = GameMO(context: managedObjectContext!)
        game4.location = inside4
        
        let game5 = GameMO(context: managedObjectContext!)
        game5.location = outside
        
        games = [game1, game2, game3, game4, game5]
        fetchedGamesFromDB = false
    }
    
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[GameMO], Error>) -> Void)
    {
        /*
        -90 <= latitude <= 90
        -180 <= longitude <= 180
        */
        if fetchedGamesFromDB {
            var gamesInRegion = [GameMO]()
            for mo in games {
                if let location = mo.location {
                    if location.latitude > center.latitude - latitudeDelta / 2 &&
                       location.latitude < center.latitude + latitudeDelta / 2 &&
                       location.longitude > center.longitude - longitudeDelta / 2 &&
                       location.longitude < center.longitude + longitudeDelta / 2
                    {
                        gamesInRegion.append(mo)
                    }
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
