//
//  CreateGameInteractor.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/5/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import CoreLocation

class CreateGameInteractor : NSObject, CreateGamePresenterToCreateGameInteractor {
    weak var presenter: CreateGameInteractorToCreateGamePresenter?
    private var userLocationService: UserLocationServiceProtocol
    private let dataStore: DataStore
    private var newGame: Game
    
    init(userLocationService: UserLocationServiceProtocol, dataStore: DataStore) {
        self.dataStore = dataStore
        self.userLocationService = userLocationService
        self.newGame = Game()
        super.init()
    }
    
    deinit {
        print("CreateGameInteractor \(#function)")
    }
    
    public func validateGameTime(_ selectedDate: Date, _ startHour: Int, _ startMin: Int, _ durHours: Int, _ durMins: Int) {
        if isStartTimeValid(selectedDate, startHour: startHour, startMin: startMin) && isDurationValid(durHours: durHours, durMins: durMins) {
            presenter?.validatedGameTime(isValid: true)
        }
        else {
            presenter?.validatedGameTime(isValid: false)
        }
        
    }
    
    private func isStartTimeValid(_ selectedDate: Date, startHour: Int, startMin: Int) -> Bool {
        let calendar = Calendar.current
    
        if calendar.isDateInToday(selectedDate) {
            let today = Date()
            let todayHour = calendar.component(.hour, from: today)
            let todayMin = calendar.component(.minute, from: today)
            if startHour < todayHour {
                return false
            }
            else if startHour == todayHour && startMin < todayMin {
                return false
            }
        }
        
        return true
    }
    
    private func isDurationValid(durHours: Int, durMins: Int) -> Bool {
        return durHours > 0 || durMins > 0
    }
    
    func setDateIntervalOfNewGame(_ interval: DateInterval) {
        newGame.setDateInterval(interval)
    }
    
    func generateUsersLocation(completionHandler: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        userLocationService.generateUsersLocation { (result) in
            completionHandler(result)
        }
    }
    
    func setLocationOfNewGame(_ location: CLLocationCoordinate2D) {
        newGame.setLocation(location)
    }
    
    func returnStartDateAndEndDateOfGame() {
        presenter?.convertDateIntervalToStartDateAndDuration(newGame.dateInterval)
    }
    
    func setAddressOfNewGame(_ address: String) {
        newGame.setAddress(address)
    }
    
    func saveNewGame() {
        dataStore.save(newGame) { (error) in
            if let err = error {
                self.presenter?.failedToSaveNewGame(errorMessage: err.localizedDescription)
            }
        }
    }
}
