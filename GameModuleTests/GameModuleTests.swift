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
    var dataStore: MockDataStore!
    var interactor: GameInteractor!
    var user: MockUser!
    var game: MockGame!
    var presenter: MockPresenter!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        
        dataStore = MockDataStore()
        
        let now = Date()
        let oneHour: TimeInterval = 60.0 * 60.0
        let nowForOneHour = DateInterval(start: now, duration: oneHour)
        
        let playerInfo1 = MockPlayerInfo(gameId: "1",
                                         uid: "1",
                                         isWithHomeTeam: true,
                                         positionEnum: .goalKeeper)
        game = MockGame(creatorId: "1",
                               id: "1",
                               address: nil,
                               coordinate: CLLocationCoordinate2D(),
                               timeInterval: nowForOneHour,
                               playersInfo: [playerInfo1])
        
        user = MockUser(uid: "1",
                            firstName: "Heriberto",
                            lastName: "Rodriguez",
                            joinedGames: [game])
        interactor = GameInteractor(dataStore: dataStore,
                                    game: game,
                                    user: user)
        
        presenter = MockPresenter()
        interactor.presenter = presenter
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
        
        interactor.newPositionSelected(.goalKeeper, isWithHomeTeam: true)
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
        interactor.newPositionSelected(.goalKeeper, isWithHomeTeam: true)
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
        interactor.newPositionSelected(.goalKeeper, isWithHomeTeam: true)
        
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
        interactor.newPositionSelected(.goalKeeper, isWithHomeTeam: true)
        
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
        interactor.newPositionSelected(.goalKeeper, isWithHomeTeam: true)
        
        XCTAssertEqual(presenter.homeTeam.count, 1)
    }
    
    func testFetchPlayersForGame() {
        let now = Date()
        let oneHour: TimeInterval = 60.0 * 60.0
        let nowForOneHour = DateInterval(start: now, duration: oneHour)
        let player1 = MockPlayerInfo(gameId: "1",
                                     uid: "1",
                                     isWithHomeTeam: true,
                                     positionEnum: .goalKeeper)
        let player2 = MockPlayerInfo(gameId: "1",
                                     uid: "2",
                                     isWithHomeTeam: false,
                                     positionEnum: .goalKeeper)
        let newGame = MockGame(id: "1",
                               address: nil,
                               coordinate: CLLocationCoordinate2D(),
                               timeInterval: nowForOneHour,
                               playersInfo: [player1, player2])
        interactor = GameInteractor(dataStore: MockDataStore(),
                                    game: newGame,
                                    user: nil)
        presenter = MockPresenter()
        interactor.presenter = presenter
        interactor.fetchPlayersForGame()
        
        // player 1 is part of home team
        XCTAssertNotNil(presenter.homeTeam["1"])
        // player 2 is part of away team
        XCTAssertNotNil(presenter.awayTeam["2"])
    }
    
    func testCheckIfUserCreatedGameOrHasJoinedGame() {
        interactor.fetchPlayersForGame()
        // checkIfUserCreatedGameOrHasJoinedGame() needs to be called after method above because
        // it initializes the data structures it uses
        interactor.checkIfUserCreatedGameOrHasJoinedGame()
        
        XCTAssertTrue(presenter.isUserPartOfGame)
        XCTAssertTrue(presenter.isUserCreatorOfGame)
    }
    
    func testFetchFreePositions() {
        interactor.fetchPlayersForGame()
        interactor.fetchFreePositions()
        
        let positions: [Position] = [.goalKeeper, .leftFullBack, .leftCenterBack,
                                     .rightCenterBack, .rightFullBack, .leftSideMidfielder,
                                     .leftCenterMidfield, .rightCenterMidField, .rightSideMidfielder,
                                     .leftCenterForward, .rightCenterForward]
        
        // verify that only goal keep position is taken in home team
        for position in positions {
            if position == .goalKeeper {
                XCTAssertFalse(presenter.freePositionsHomeTeam.contains(position))
            }
            else {
                XCTAssertTrue(presenter.freePositionsHomeTeam.contains(position))
            }
        }
        
        // verify that all positions in away team are free
        for position in positions {
            XCTAssertTrue(presenter.freePositionsAwayTeam.contains(position))
        }
        
        // verify that user is in home team
        XCTAssertTrue(presenter.isUserInHomeTeam)
    }
    
    func testNewPositionSelectedAndUserSwitchingFromHomeTeamToAwayTeam() {
        interactor.fetchPlayersForGame()
        interactor.newPositionSelected(.leftCenterForward, isWithHomeTeam: false)
        
        guard let uid = user.uid else {
            fatalError("Failed to get user id")
        }
        
        // verify that user not in home team
        XCTAssertNil(presenter.homeTeam[uid])
        // verify that user is in away team
        XCTAssertNotNil(presenter.awayTeam[uid])
        // verify that user's position in away team is left center forward
        XCTAssertEqual(presenter.awayTeam[uid], .leftCenterForward)
    }
    
    func testNewPositionSelectedAndUserSwitchingPositionsInHomeTeam() {
        interactor.fetchPlayersForGame()
        interactor.newPositionSelected(.leftCenterForward, isWithHomeTeam: true)
        
        guard let uid = user.uid else {
            fatalError("Failed to get user id")
        }
        
        // verify that user not in home team
        XCTAssertNotNil(presenter.homeTeam[uid])
        // verify that user's position in home team is left center forward
        XCTAssertEqual(presenter.homeTeam[uid], .leftCenterForward)
    }
    
    func testNewPositionSelectedAndUserSwitchingFromAwayTeamToHomeTeam() {
        let now = Date()
        let oneHour: TimeInterval = 60.0 * 60.0
        let nowForOneHour = DateInterval(start: now, duration: oneHour)
        
        let playerInfo1 = MockPlayerInfo(gameId: "1",
                                         uid: "1",
                                         isWithHomeTeam: false,
                                         positionEnum: .goalKeeper)
        let newGame = MockGame(creatorId: "1",
                               id: "1",
                               address: nil,
                               coordinate: CLLocationCoordinate2D(),
                               timeInterval: nowForOneHour,
                               playersInfo: [playerInfo1])
        
        user = MockUser(uid: "1",
                        firstName: "Heriberto",
                        lastName: "Rodriguez",
                        joinedGames: [newGame])
        interactor = GameInteractor(dataStore: MockDataStore(),
                                    game: newGame,
                                    user: user)
        
        presenter = MockPresenter()
        interactor.presenter = presenter
        
        interactor.fetchPlayersForGame()
        interactor.newPositionSelected(.leftCenterForward, isWithHomeTeam: true)
        
        guard let uid = user.uid else {
            fatalError("Failed to get user id")
        }
        
        // verify that user not in away team
        XCTAssertNil(presenter.awayTeam[uid])
        // verify that user is in home team
        XCTAssertNotNil(presenter.homeTeam[uid])
        // verify that user's position in home team is left center forward
        XCTAssertEqual(presenter.homeTeam[uid], .leftCenterForward)
    }
    
    func testNewPositionSelectedAndUserSwitchingPositionsInAwayTeam() {
        let now = Date()
        let oneHour: TimeInterval = 60.0 * 60.0
        let nowForOneHour = DateInterval(start: now, duration: oneHour)
        
        let playerInfo1 = MockPlayerInfo(gameId: "1",
                                         uid: "1",
                                         isWithHomeTeam: false,
                                         positionEnum: .goalKeeper)
        let newGame = MockGame(creatorId: "1",
                               id: "1",
                               address: nil,
                               coordinate: CLLocationCoordinate2D(),
                               timeInterval: nowForOneHour,
                               playersInfo: [playerInfo1])
        
        user = MockUser(uid: "1",
                        firstName: "Heriberto",
                        lastName: "Rodriguez",
                        joinedGames: [newGame])
        interactor = GameInteractor(dataStore: MockDataStore(),
                                    game: newGame,
                                    user: user)
        
        presenter = MockPresenter()
        interactor.presenter = presenter
        
        interactor.fetchPlayersForGame()
        interactor.newPositionSelected(.leftCenterForward, isWithHomeTeam: false)
        
        guard let uid = user.uid else {
            fatalError("Faild to get user id")
        }
        
        // verify that user is in away team
        XCTAssertNotNil(presenter.awayTeam[uid])
        // verify that user's position in away team is left center forward
        XCTAssertEqual(presenter.awayTeam[uid], .leftCenterForward)
    }
    
    func testFailedToUpdateUserPosition() {
        interactor.fetchPlayersForGame()
        dataStore.failedToUpdateUserPosition = true
        interactor.newPositionSelected(.leftCenterForward, isWithHomeTeam: true)
        // verify that presenter received an error message from data store
        XCTAssertNotNil(presenter.errorMessage)
        // verify that error message received equals message expected
        if let messageReceived = presenter.errorMessage,
            let messageExpected = DataStoreError.failedToUpdateUserPosition.errorDescription
        {
            XCTAssertEqual(messageReceived, messageExpected)
        }
    }
    
    func testAddingUserToGameSuccess() {
        let now = Date()
        let oneHour: TimeInterval = 60.0 * 60.0
        let nowForOneHour = DateInterval(start: now, duration: oneHour)
        
        let newGame = MockGame(creatorId: "1",
                               id: "1",
                               address: nil,
                               coordinate: CLLocationCoordinate2D(),
                               timeInterval: nowForOneHour,
                               playersInfo: [])
        
        user = MockUser(uid: "1",
                        firstName: "Heriberto",
                        lastName: "Rodriguez",
                        joinedGames: [])
        interactor = GameInteractor(dataStore: dataStore,
                                    game: newGame,
                                    user: user)
        presenter = MockPresenter()
        interactor.presenter = presenter
        interactor.newPositionSelected(.goalKeeper, isWithHomeTeam: true)
        
        guard let uid = user.uid else {
            fatalError("Failed to get user id")
        }
        
        // verify that user's position is correct
        XCTAssertEqual(presenter.homeTeam[uid], .goalKeeper)
    }
    
    func testAddingUserToGameFailed() {
        let now = Date()
        let oneHour: TimeInterval = 60.0 * 60.0
        let nowForOneHour = DateInterval(start: now, duration: oneHour)
        
        let newGame = MockGame(creatorId: "1",
                               id: "1",
                               address: nil,
                               coordinate: CLLocationCoordinate2D(),
                               timeInterval: nowForOneHour,
                               playersInfo: [])
        
        user = MockUser(uid: "1",
                        firstName: "Heriberto",
                        lastName: "Rodriguez",
                        joinedGames: [])
        interactor = GameInteractor(dataStore: dataStore,
                                    game: newGame,
                                    user: user)
        presenter = MockPresenter()
        interactor.presenter = presenter
        dataStore.failedToAddUserToGame = true
        interactor.newPositionSelected(.goalKeeper, isWithHomeTeam: true)
        
        // verify that expected error message is received
        if let messageRecieved = presenter.errorMessage,
            let messagedExpected = DataStoreError.failedToAddUserToGame.errorDescription
        {
            XCTAssertEqual(messageRecieved, messagedExpected)
        }
    }
    
    func testRemovingUserSuccess() {
        interactor.fetchPlayersForGame()
        
        guard let uid = user.uid else {
            fatalError("Failed to get user id")
        }
        XCTAssertNotNil(presenter.homeTeam[uid])
        
        
        interactor.removeUserFromGame()
        XCTAssertNil(presenter.homeTeam[uid])
    }
    
    func testRemovingUserFailed() {
        interactor.fetchPlayersForGame()
        
        guard let uid = user.uid else {
            fatalError("Failed to get user id")
        }
        XCTAssertNotNil(presenter.homeTeam[uid])
        
        dataStore.failedToRemoveUserFromGame = true
        interactor.removeUserFromGame()
        
        if let messageReceived = presenter.errorMessage,
            let messageExpected = DataStoreError.failedToRemoveUserFromGame.errorDescription {
            XCTAssertEqual(messageReceived, messageExpected)
        }
    }
    
    func testDeletingGameSuccess() {
        interactor.deleteGame { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testDeletingGameFailed() {
        dataStore.failedToDeleteGame = true
        interactor.deleteGame { (error) in
            if let dataStoreError = error as? DataStoreError {
                XCTAssertEqual(dataStoreError, .failedToDeleteGame)
            }
        }
    }
}

struct MockPlayerInfo: PlayerInfoProtocol {
    var gameId: String
    var uid: String
    var isWithHomeTeam: Bool
    var positionEnum: Position
}

struct MockUser: User {
    var uid: String?
    var firstName: String?
    var lastName: String?
    var joinedGames: Array<Game>
}

struct MockGame: Game {
    var creatorId: String?
    var id: String?
    var address: String?
    var coordinate: CLLocationCoordinate2D
    var timeInterval: DateInterval
    var playersInfo: Array<PlayerInfoProtocol>
}

class MockPresenter: GameInteractorToGamePresenter {
    var freePositionsHomeTeam = [Position]()
    var freePositionsAwayTeam = [Position]()
    var homeTeam = [String: Position]()
    var awayTeam = [String: Position]()
    var errorMessage: String?
    var isUserCreatorOfGame = false
    var isUserPartOfGame = false
    var isUserInHomeTeam = false
    
    func onFetchPlayersSuccess(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }
    
    func onUpdatedTeams(_ homeTeam: [String : Position], _ awayTeam: [String : Position]) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }
    
    func onFetchPlayersFailed(_ errorMessage: String) {
        
    }
    
    func onTimeConflictDetected(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    func verifiedIfUserCreatedGameOrHasJoinedGame(_ didUserCreateGame: Bool, _ didUserJoinGame: Bool) {
        isUserCreatorOfGame = didUserCreateGame
        isUserPartOfGame = didUserJoinGame
    }
    
    func onFetchFreePositionsSuccess(homeTeam: [Position], awayTeam: [Position], isWithHomeTeam: Bool) {
        freePositionsHomeTeam = homeTeam
        freePositionsAwayTeam = awayTeam
        isUserInHomeTeam = isWithHomeTeam
        
    }
    
    func onFailedToAddUserToGame(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    func onFailedToUpdatePlayerPosition(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
    
    func onFailedToRemoveUserFromGame(_ errorMessage: String) {
        self.errorMessage = errorMessage
    }
}

class MockDataStore: DataStore
{
    var failedToDeleteGame = false
    var failedToRemoveUserFromGame = false
    var failedToAddUserToGame = false
    var failedToUpdateUserPosition = false
    
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
    
    func saveGame(_ creatorId: String, _ address: String, _ location: CLLocationCoordinate2D, _ dateInterval: DateInterval, completion: @escaping (Error?) -> Void) {
        
    }
    
    func deleteGame(_ gameId: String, completion: (Error?) -> Void) {
        if failedToDeleteGame {
            completion(DataStoreError.failedToDeleteGame)
        }
        else {
            completion(nil)
        }
    }
    
    func deleteAllGames() {
        
    }
    
    func addUserToGame(uid: String, gameId: String, position: Position, isWithHomeTeam: Bool, completion: (Result<PlayerInfoProtocol, Error>) -> Void)
    {
        if failedToAddUserToGame {
            
        }
        else {
            let playerInfo = MockPlayerInfo(gameId: gameId, uid: uid, isWithHomeTeam: isWithHomeTeam, positionEnum: position)
            completion(.success(playerInfo))
        }
    }
    
    func updateUserInfoForGame(uid: String, gameId: String, position: Position, isWithHomeTeam: Bool, completion: (Result<PlayerInfoProtocol, Error>) -> Void) {
        if failedToUpdateUserPosition {
            completion(.failure(DataStoreError.failedToUpdateUserPosition))
        }
        else {
            completion(.success(MockPlayerInfo(gameId: gameId,
                                               uid: uid,
                                               isWithHomeTeam: isWithHomeTeam,
                                               positionEnum: position)))
        }
    }
    
    func removeUserFromGame(uid: String,
                            gameId: String,
                            completion: (Result<PlayerInfoProtocol, Error>) -> Void)
    {
        if failedToRemoveUserFromGame {
            completion(.failure(DataStoreError.failedToRemoveUserFromGame))
        }
        else {
            completion(.success(MockPlayerInfo(gameId: gameId,
                                               uid: uid,
                                               isWithHomeTeam: true,
                                               positionEnum: .goalKeeper)))
        }
    }
}
