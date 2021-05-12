//
//  GamesProtocols.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import MapKit

protocol GamesViewToGamesPresenter: AnyObject {
    func closeButtonTapped(_ navigationController: UINavigationController)
    func updateGamesView(center: CLLocationCoordinate2D,
                         latitudeDelta: CLLocationDegrees,
                         longitudeDelta: CLLocationDegrees)
    func addGameButtonTapped(_ navigationController: UINavigationController)
}

protocol GamesPresenterToGamesView: AnyObject {
    func displayGames(_ coordinateToGame: [CLLocationCoordinate2D : Game])
    func displayErrorMessage(_ errorMessage: String)
}

protocol GamesPresenterToGamesInteractor {
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees)
}

protocol GamesInteractorToGamesPresenter: AnyObject {
    func onFetchGamesSuccess(_ games: [CLLocationCoordinate2D : Game])
    func onFetchGamesFailed(_ errorMessage: String)
}

protocol GamesPresenterToGamesRouter {
    func pushCreateGameVC(_ navigationController: UINavigationController)
    func dismissGamesModule(_ navigationController: UINavigationController)
}
