//
//  CreateGameProtocols.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/5/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: - Communication between views and presenter
protocol CreateGameViewToCreateGamePresenter {
    func cancelCreateGame(_ navigationController: UINavigationController)
}

protocol GameTimeViewToCreateGamePresenter: CreateGameViewToCreateGamePresenter {
    func updateGameTimeView()
    func checkIfGameTimeValid(_ selectedDate: Date, startHour: Int, startMin: Int, durHours: Int, durMins: Int)
    func setDateIntervalOfNewGame(_ interval: DateInterval)
    func showLocationVC(with navigationController: UINavigationController)
}

protocol GameLocationViewToCreateGamePresenter: CreateGameViewToCreateGamePresenter {
    func updateGameLocationView()
    func convertCoordinateToAddress(_ coordinate: CLLocationCoordinate2D)
    func getGameDetails()
    func setLocationOfNewGame(_ location: CLLocationCoordinate2D)
    func confirmLocationButtonTapped(_ navigationController: UINavigationController)
}

protocol CreateGamePresenterToGameTimeView: AnyObject {
    func onBuiltCalendarModule(viewController: UIViewController)
    func onValidatedGameTime(isValid: Bool)
}

protocol CreateGamePresenterToGameLocationView: AnyObject {
    func zoomIntoUserLocation(_ location: CLLocationCoordinate2D)
    func convertedCoordinateToAddress(_ address: String)
    func onFailedToConvertCoordinateToAddress(errorMessage: String)
    func setStartDateAndDuration(startDate: String, duration: String)
}

// MARK: - Communication between interactors and presenter
protocol CreateGamePresenterToCreateGameInteractor {
    func validateGameTime(_ selectedDate: Date, _ startHour: Int, _ startMin: Int, _ durHours: Int, _ durMins: Int)
    func setDateIntervalOfNewGame(_ interval: DateInterval)
    func generateUsersLocation(completionHandler: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
    func setLocationOfNewGame(_ location: CLLocationCoordinate2D)
    func setAddressOfNewGame(_ address: String)
    func returnStartDateAndEndDateOfGame()
    func saveNewGame()
}

protocol CreateGameInteractorToCreateGamePresenter: AnyObject {
    func validatedGameTime(isValid: Bool)
    func convertDateIntervalToStartDateAndDuration(_ dateInterval: DateInterval)
}

// MARK: - Communication between presenter and router
protocol CreateGamePresenterToCreateGameRouter {
    func buildCalendarModule(baseDate: Date) -> UIViewController
    func pushGameLocationVC(with navigationController: UINavigationController) -> GameLocationVC
    func dismissCreateGameModule(_ navigationController: UINavigationController)
}
