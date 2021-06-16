//
//  CreateGameInteractorTests.swift
//  CreateGameInteractorTests
//
//  Created by Heriberto Rodriguez on 3/18/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import XCTest
import CoreLocation
@testable import PickupSoccer

class CreateGameInteractorTests: XCTestCase {
    var createGameInteractor: CreateGameInteractor!
    var mockPresenter: MockPresenter!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        createGameInteractor = CreateGameInteractor(userLocationService: MockUserLocationService(),
                                                    dataStore: MockDataStore())
        mockPresenter = MockPresenter()
        createGameInteractor.presenter = mockPresenter
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        createGameInteractor = nil
        mockPresenter = nil
        super.tearDown()
    }
    
    func testValidGameStartTimeAndDuration() {
        createGameInteractor.validateGameTime(Date(), 14, 20, 2, 0)
        XCTAssertTrue(mockPresenter.isGameTimeValid)
    }
    
    func testValidGameStartTimeAndInvalidDuration() {
        createGameInteractor.validateGameTime(Date(), 14, 20, 0, 0)
        XCTAssertFalse(mockPresenter.isGameTimeValid)
    }
    
    func testInValidGameStartTimeAndValidDuration() {
        createGameInteractor.validateGameTime(Date(), 4, 20, 2, 0)
        XCTAssertFalse(mockPresenter.isGameTimeValid)
    }
    
    func testInvalidGameStartTimeAndInvalidDuration() {
        createGameInteractor.validateGameTime(Date(), 3, 0, 0, 0)
        XCTAssertFalse(mockPresenter.isGameTimeValid)
    }
    
    func testUserLocation() {
        createGameInteractor.generateUsersLocation { (result) in
            switch result {
            case .success(let coordinate):
                print(coordinate)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}

class MockUserLocationService: UserLocationServiceProtocol {
    enum UserLocationError: LocalizedError {
        case userDeniedSharingLocation
    }
    
    func generateUsersLocation(completionHandler: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
//        completionHandler(Result.success(CLLocationCoordinate2D(latitude: 0.5, longitude: 0.6)))
        completionHandler(Result.failure(UserLocationError.userDeniedSharingLocation))
    }
}

class MockPresenter: CreateGameInteractorToCreateGamePresenter {
    var isGameTimeValid = false
    func validatedGameTime(isValid: Bool) {
        self.isGameTimeValid = isValid
    }
    
    func convertDateIntervalToStartDateAndDuration(_ dateInterval: DateInterval) {
        
    }
    
    func failedToSaveNewGame(errorMessage: String) {
        
    }
}

class MockDataStore: DataStore {
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
    
    func fetchGames(center: CLLocationCoordinate2D, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees, completion: @escaping (Result<[Game], Error>) -> Void) {
        
    }
    
    func saveGame(_ address: String, _ location: CLLocationCoordinate2D, _ dateInterval: DateInterval, completion: @escaping (Error?) -> Void) {
    
    }
}
