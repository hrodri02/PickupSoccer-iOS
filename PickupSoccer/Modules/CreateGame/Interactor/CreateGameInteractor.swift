//
//  CreateGameInteractor.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/5/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CreateGameInteractor : NSObject, CreateGamePresenterToCreateGameInteractor {
    weak var presenter: CreateGameInteractorToCreateGamePresenter?
//    private var createGameDataManager: CreateGameDataManager?
    private var userLocationService: UserLocationServiceProtocol
    private var newGame: Game
    
    init(userLocationService: UserLocationServiceProtocol) {
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
    
    func saveNewGame() {
        // 1. get reference to app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // 2. get reference to managed object context
        let managedObjectConext = appDelegate.persistentContainer.viewContext
        // 3. create a game entity
        let gameEntity = NSEntityDescription.entity(forEntityName: "Game", in: managedObjectConext)!
        let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectConext)!
        let dateIntervalEntity = NSEntityDescription.entity(forEntityName: "DateInterval", in: managedObjectConext)!
        // 4. create managed objects
        let gameMO = NSManagedObject(entity: gameEntity, insertInto: managedObjectConext)
        let locationMO = NSManagedObject(entity: locationEntity, insertInto: managedObjectConext)
        let dateIntervalMO = NSManagedObject(entity: dateIntervalEntity, insertInto: managedObjectConext)
        // 5. set properties of game entity
        locationMO.setValue(newGame.location.latitude, forKey: "latitude")
        locationMO.setValue(newGame.location.longitude, forKey: "longitude")
        dateIntervalMO.setValue(newGame.dateInterval.start, forKey: "start")
        dateIntervalMO.setValue(newGame.dateInterval.end, forKey: "end")
        gameMO.setValue(locationMO, forKey: "location")
        gameMO.setValue(dateIntervalMO, forKey: "dateInterval")
        // 6. save managed object context
        do {
            try managedObjectConext.save()
            print("NEW GAME SAVED")
        }
        catch {
            print("Failed to save game in CoreData: \(error.localizedDescription)")
        }
    }
}
