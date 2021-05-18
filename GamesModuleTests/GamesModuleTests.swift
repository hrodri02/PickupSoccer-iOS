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
        let longtidueDelta: CLLocationDegrees = 15
        gamesInteractor.dataStore.fetchGames(center: center,
                                             latitudeDelta: latitudeDelta,
                                             longitudeDelta: longtidueDelta)
        { (result) in
            switch result {
            case .success(let coordinateToGame):
                print(coordinateToGame)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

class MockDataStore: DataStore {
    /*
     -90 <= latitude <= 90
     -180 <= longitude <= 180
     */
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees,
                    completion: @escaping (Result<[CLLocationCoordinate2D : Game], Error>) -> Void)
    {
        
    }
    
    func save(_ game: Game, completion: @escaping (Error?) -> Void) {
        
    }
    
    
}
