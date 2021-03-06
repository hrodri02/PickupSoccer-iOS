//
//  GamesPresenter.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit
import CoreLocation

class GamesPresenter: GamesViewToGamesPresenter
{
    weak var view: GamesPresenterToGamesView?
    var interactor: GamesPresenterToGamesInteractor!
    var router: GamesPresenterToGamesRouter!
    
    deinit {
        print("Games Presenter \(#function)")
    }
    
    func updateGamesView(center: CLLocationCoordinate2D,
                         latitudeDelta: CLLocationDegrees,
                         longitudeDelta: CLLocationDegrees)
    {
        interactor.fetchGames(center: center,
                              latitudeDelta: latitudeDelta,
                              longitudeDelta: longitudeDelta)
    }
    
    func closeButtonTapped(_ navigationController: UINavigationController) {
        router.dismissGamesModule(navigationController)
    }
    
    func addGameButtonTapped(_ navigationController: UINavigationController) {
        router.pushCreateGameVC(navigationController)
    }
    
    func gameCellTapped(game: Game, _ navigationController: UINavigationController) {
        router.pushGameVC(navigationController, game: game)
    }
}

extension GamesPresenter: GamesInteractorToGamesPresenter {
    func onFetchGamesSuccess(_ games: [Game]) {
        var coordinateToGame = [CLLocationCoordinate2D : Game]()
        for game in games {
            let coordinate = CLLocationCoordinate2D(latitude: game.coordinate.latitude,
                                                    longitude: game.coordinate.longitude)
            coordinateToGame[coordinate] = game
        }
        view?.displayGames(coordinateToGame)
    }
    
    func onFetchGamesFailed(_ errorMessage: String) {
        view?.displayErrorMessage(errorMessage)
    }
}
