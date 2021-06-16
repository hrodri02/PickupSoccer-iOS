//
//  GameModuleTests.swift
//  GameModuleTests
//
//  Created by Heriberto Rodriguez on 6/15/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import XCTest
import CoreLocation
@testable import PickupSoccer

class GameModuleTests: XCTestCase {
    var interactor: GameInteractor!
    var user: MockUser!
    var presenter: MockPresenter!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        presenter = nil
        interactor = nil
        user = nil
        super.tearDown()
    }
    
    func testTimeConflictCompleteOverlap() {
        let oneHourInSecs: TimeInterval = 3600
        let now = Date()
        let dateIntervalForGameUserJoined = DateInterval(start: now, duration: oneHourInSecs)
        
        user = MockUser(uid: "0",
                        firstName: nil,
                        lastName: nil,
                        joinedGames: [MockGame(id: "0",
                                               address: nil,
                                               coordinate: CLLocationCoordinate2D(),
                                               timeInterval: dateIntervalForGameUserJoined,
                                               playersInfo: [])])
        
        let dateIntervalForNewGame = DateInterval(start: now, duration: oneHourInSecs)
        let newGame = MockGame(id: "1",
                            address: nil,
                            coordinate: CLLocationCoordinate2D(),
                            timeInterval: dateIntervalForNewGame,
                            playersInfo: [])
        interactor = GameInteractor(dataStore: MockDataStore(), game: newGame, user: user)
        presenter = MockPresenter()
        interactor.presenter = presenter
        
        interactor.newPositionSelected(.goalKeeper, isHomeTeam: true)
        let errorMessage = presenter.errorMessage
        XCTAssertNotNil(errorMessage)
    }
    
    func testTimeConflictPartialOverlap() {
        let now = Date()
        let oneHourInSecs: TimeInterval = 3600
        let thirtyMinsFromNowInSecs: TimeInterval = 60 * 30
        let timeInterval2 = DateInterval(start: Date(timeInterval: thirtyMinsFromNowInSecs, since: now),
                                         duration: oneHourInSecs)
        user = MockUser(uid: "0",
                        firstName: nil,
                        lastName: nil,
                        joinedGames: [MockGame(id: "0",
                                               address: nil,
                                               coordinate: CLLocationCoordinate2D(),
                                               timeInterval: timeInterval2,
                                               playersInfo: [])])
        
        let timeInterval1 = DateInterval(start: now, duration: oneHourInSecs)
        let newGame = MockGame(id: "1",
                            address: nil,
                            coordinate: CLLocationCoordinate2D(),
                            timeInterval: timeInterval1,
                            playersInfo: [])
        interactor = GameInteractor(dataStore: MockDataStore(), game: newGame, user: user)
        presenter = MockPresenter()
        interactor.presenter = presenter
        interactor.newPositionSelected(.goalKeeper, isHomeTeam: true)
        let errorMessage = presenter.errorMessage
        XCTAssertNotNil(errorMessage)
    }
    
    func testNoTimeConflictNewGameStartsAfterCurrentGameEnds() {
        let now = Date()
        let oneHourInSecs: TimeInterval = 3600
        let nowForOneHour = DateInterval(start: now, duration: oneHourInSecs)
        user = MockUser(uid: "0",
                        firstName: nil,
                        lastName: nil,
                        joinedGames: [MockGame(id: "0",
                                               address: nil,
                                               coordinate: CLLocationCoordinate2D(),
                                               timeInterval: nowForOneHour,
                                               playersInfo: [])])
        
        let oneHourFromNowForOneHour = DateInterval(start: Date(timeInterval: oneHourInSecs, since: now),
                                                  duration: oneHourInSecs)
        let newGame = MockGame(id: "1",
                            address: nil,
                            coordinate: CLLocationCoordinate2D(),
                            timeInterval: oneHourFromNowForOneHour,
                            playersInfo: [])
        interactor = GameInteractor(dataStore: MockDataStore(), game: newGame, user: user)
        presenter = MockPresenter()
        interactor.presenter = presenter
        interactor.newPositionSelected(.goalKeeper, isHomeTeam: true)
        
        XCTAssertEqual(presenter.homeTeam.count, 1)
    }
    
    func testNoTimeConflictNewGameEndsBeforeCurrentGameStarts() {
        let now = Date()
        let oneHourInSecs: TimeInterval = 3600
        let oneHourFromNowForOneHour = DateInterval(start: Date(timeInterval: oneHourInSecs, since: now),
                                         duration: oneHourInSecs)
        user = MockUser(uid: "0",
                        firstName: nil,
                        lastName: nil,
                        joinedGames: [MockGame(id: "0",
                                               address: nil,
                                               coordinate: CLLocationCoordinate2D(),
                                               timeInterval: oneHourFromNowForOneHour,
                                               playersInfo: [])])
        
        let nowForOneHour = DateInterval(start: now, duration: oneHourInSecs)
        let newGame = MockGame(id: "1",
                            address: nil,
                            coordinate: CLLocationCoordinate2D(),
                            timeInterval: nowForOneHour,
                            playersInfo: [])
        interactor = GameInteractor(dataStore: MockDataStore(), game: newGame, user: user)
        presenter = MockPresenter()
        interactor.presenter = presenter
        interactor.newPositionSelected(.goalKeeper, isHomeTeam: true)
        
        XCTAssertEqual(presenter.homeTeam.count, 1)
    }
    
    func testNoTimeConflictNoOverlap() {
        let now = Date()
        let oneHourInSecs: TimeInterval = 3600
        let twoHoursFromNowInSecs: TimeInterval = 60 * 60 * 2
        let twoHoursFromNowForOneHour = DateInterval(start: Date(timeInterval: twoHoursFromNowInSecs, since: now),
                                                     duration: oneHourInSecs)
        user = MockUser(uid: "0",
                        firstName: nil,
                        lastName: nil,
                        joinedGames: [MockGame(id: "0",
                                               address: nil,
                                               coordinate: CLLocationCoordinate2D(),
                                               timeInterval: twoHoursFromNowForOneHour,
                                               playersInfo: [])])
        
        let nowForOneHour = DateInterval(start: now, duration: oneHourInSecs)
        let newGame = MockGame(id: "1",
                            address: nil,
                            coordinate: CLLocationCoordinate2D(),
                            timeInterval: nowForOneHour,
                            playersInfo: [])
        interactor = GameInteractor(dataStore: MockDataStore(), game: newGame, user: user)
        presenter = MockPresenter()
        interactor.presenter = presenter
        interactor.newPositionSelected(.goalKeeper, isHomeTeam: true)
        
        XCTAssertEqual(presenter.homeTeam.count, 1)
    }
}

struct MockUser: User {
    var uid: String?
    var firstName: String?
    var lastName: String?
    var joinedGames: Array<Game>
}

struct MockGame: Game {
    var id: String?
    var address: String?
    var coordinate: CLLocationCoordinate2D
    var timeInterval: DateInterval
    var playersInfo: Array<PlayerInfoProtocol>
}

class MockPresenter: GameInteractorToGamePresenter {
    var homeTeam = [String: Position]()
    var errorMessage: String?
    
    func onFetchPlayersSuccess(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        
    }
    
    func onUpdatedTeams(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        self.homeTeam = homeTeam
    }
    
    func onFetchPlayersFailed(_ errorMessage: String) {
        
    }
    
    func onTimeConflictDetected(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    func verifiedIfUserIsPartOfGame(_ isPartOfGame: Bool) {
        
    }
    
    func onFailedToAddUserToGame(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
}


struct MockPlayerInfo: PlayerInfoProtocol {
    var gameId: String
    var uid: String
    var isWithHomeTeam: Bool
    var positionEnum: Position
}

class MockDataStore: DataStore
{
    func fetchAllUsers() {
        
    }
    
    func fetchUser(with uid: String, completion: (Result<User, Error>) -> Void) {
        
    }
    
    func saveUser(firstName: String, lastName: String, completion: (Result<User, Error>) -> Void) {
        
    }
    
    func deleteAllUsers() {
        
    }
    
    func fetchGames(center: CLLocationCoordinate2D, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees, completion: @escaping (Result<[Game], Error>) -> Void) {
        
    }
    
    func saveGame(_ address: String, _ location: CLLocationCoordinate2D, _ dateInterval: DateInterval, completion: @escaping (Error?) -> Void) {
        
    }
    
    func deleteAllGames() {
        
    }
    
    func addUserToGame(uid: String, gameId: String, position: Position, isWithHomeTeam: Bool, completion: (Result<PlayerInfoProtocol, Error>) -> Void) {
        let playerInfo = MockPlayerInfo(gameId: gameId, uid: uid, isWithHomeTeam: isWithHomeTeam, positionEnum: position)
        completion(.success(playerInfo))
    }
    
    func updateUserInfoForGame(uid: String, gameId: String, position: Position, isWithHomeTeam: Bool, completion: (Result<PlayerInfoProtocol, Error>) -> Void) {
        
    }
    
    func removeUserFromGame(uid: String, gameId: String, completion: (Result<PlayerInfoProtocol, Error>) -> Void) {
        
    }
}
