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
    weak var presenter: GamesInteractorToGamesPresenter?
    let dataManager: GamesDataManager
    
    init(dataManager: GamesDataManager) {
        self.dataManager = dataManager
    }
    
    deinit {
        print("Games Interactor \(#function)")
    }
    
    func fetchGames(center: CLLocationCoordinate2D,
                    latitudeDelta: CLLocationDegrees,
                    longitudeDelta: CLLocationDegrees)
    {
        dataManager.fetchGames(center: center, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta) { (result) in
            switch result {
            case .success(let coordinateToGame):
                self.presenter?.onFetchGamesSuccess(coordinateToGame)
            case .failure(let error):
                self.presenter?.onFetchGamesFailed(error.localizedDescription)
            }
        }
    }
}
