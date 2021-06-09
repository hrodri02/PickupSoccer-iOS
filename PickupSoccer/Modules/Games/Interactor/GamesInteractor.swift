//
//  GamesInteractor.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import CoreLocation
import UIKit

class GamesInteractor: GamesPresenterToGamesInteractor {
    private let dataStore: DataStore
    weak var presenter: GamesInteractorToGamesPresenter?
    private var games: [Game]
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
        self.games = []
    }
    
    deinit {
        print("Games Interactor \(#function)")
    }
    
    func getGame(index: Int) -> Game {
        return games[index]
    }
    
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees)
    {
        dataStore.fetchGames(center: center, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta) { (result) in
            switch result {
            case .success(let games):
                self.games = games
                self.presenter?.onFetchGamesSuccess(games)
            case .failure(let error):
                self.presenter?.onFetchGamesFailed(error.localizedDescription)
            }
        }
    }
}
