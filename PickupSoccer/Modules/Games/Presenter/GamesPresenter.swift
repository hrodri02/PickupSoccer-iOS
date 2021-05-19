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
}

extension GamesPresenter: GamesInteractorToGamesPresenter {
    func onFetchGamesSuccess(_ coordinateToGame: [CLLocationCoordinate2D : Game]) {
        var coordinateToGameViewModel = [CLLocationCoordinate2D : GameViewModel]()
        for (coordinate, game) in coordinateToGame {
            let viewModel = GameViewModel(game: game)
            coordinateToGameViewModel[coordinate] = viewModel
        }
        view?.displayGames(coordinateToGameViewModel)
    }
    
    func onFetchGamesFailed(_ errorMessage: String) {
        view?.displayErrorMessage(errorMessage)
    }
}
