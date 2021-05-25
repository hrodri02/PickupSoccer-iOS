//
//  GameVC.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/25/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
    weak var presenter: GameViewToGamePresenter?
    
    deinit {
        print("GameVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
    }
}

extension GameVC: GamePresenterToGameView {
    func displayPlayers(_ players: [User]) {
        
    }
    
    func displayErrorMessage(_ errorMessage: String) {
        presentErrorMessage(errorMessage)
    }
}
