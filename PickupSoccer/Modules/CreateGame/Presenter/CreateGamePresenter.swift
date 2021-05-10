//
//  CreateGamePresenter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/5/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import CoreLocation

class CreateGamePresenter: CreateGameViewToCreateGamePresenter {
    weak var gameTimeView: CreateGamePresenterToGameTimeView?
    weak var gameLocationView: CreateGamePresenterToGameLocationView?
    var createGameInteractor: CreateGamePresenterToCreateGameInteractor?
    var router: CreateGamePresenterToCreateGameRouter?
    
    deinit {
        print("CreateGamePresenter \(#function)")
    }
    
    func cancelCreateGame(_ navigationController: UINavigationController) {
        router?.dismissCreateGameModule(navigationController)
    }
}

extension CreateGamePresenter: GameTimeViewToCreateGamePresenter {
    func updateGameTimeView() {
        if let calendarVC = router?.buildCalendarModule(baseDate: Date()) {
            gameTimeView?.onBuiltCalendarModule(viewController: calendarVC)
        }
    }
    
    func checkIfGameTimeValid(_ selectedDate: Date, startHour: Int, startMin: Int, durHours: Int, durMins: Int) {
        createGameInteractor?.validateGameTime(selectedDate, startHour, startMin, durHours, durMins)
    }
    
    func setDateIntervalOfNewGame(_ interval: DateInterval) {
        createGameInteractor?.setDateIntervalOfNewGame(interval)
    }
        
    func showLocationVC(with navigationController: UINavigationController) {
        let gameLocationVC = router?.pushGameLocationVC(with: navigationController)
        gameLocationView = gameLocationVC
        gameLocationVC?.presenter = self
    }
}

extension CreateGamePresenter: GameLocationViewToCreateGamePresenter {
    func updateGameLocationView() {
        createGameInteractor?.generateUsersLocation(completionHandler: { [weak self] (result) in
            switch result {
            case .success(let coordinate):
                DispatchQueue.main.async {
                    self?.gameLocationView?.zoomIntoUserLocation(coordinate)
                }
                break
            case .failure(let error):
                // TODO: - pass error message to game location view
                print(error)
                break
            }
        })
    }
    
    func setLocationOfNewGame(_ location: CLLocationCoordinate2D) {
        createGameInteractor?.setLocationOfNewGame(location)
    }
    
    func convertCoordinateToAddress(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let _ = error {
                self.gameLocationView?.onFailedToConvertCoordinateToAddress(errorMessage: "Could not convert coordinate to address. Please check network connection.")
            }
            else {
                if let address = placemarks?.first?.name {
                    self.gameLocationView?.convertedCoordinateToAddress(address)
                    self.createGameInteractor?.setAddressOfNewGame(address)
                }
            }
        }
    }
    
    func getGameDetails() {
        createGameInteractor?.returnStartDateAndEndDateOfGame()
    }
    
    func confirmLocationButtonTapped(_ navigationController: UINavigationController) {
        createGameInteractor?.saveNewGame()
        router?.dismissCreateGameModule(navigationController)
    }
}

extension CreateGamePresenter: CreateGameInteractorToCreateGamePresenter {
    func validatedGameTime(isValid: Bool) {
        gameTimeView?.onValidatedGameTime(isValid: isValid)
    }
    
    func convertDateIntervalToStartDateAndDuration(_ dateInterval: DateInterval) {
        let durationIntervalInHours = dateInterval.duration / 3600
        let mins = Int((durationIntervalInHours - floor(durationIntervalInHours)) * 60)
        let duration = "\(Int(durationIntervalInHours)) h \(mins) m"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        gameLocationView?.setStartDateAndDuration(startDate: dateFormatter.string(from: dateInterval.start), duration: duration)
    }
    
    func failedToSaveNewGame(errorMessage: String) {
        gameLocationView?.onFailedToSaveNewGame(errorMessage: errorMessage)
    }
}
