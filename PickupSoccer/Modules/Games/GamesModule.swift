//
//  GamesModule.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

struct GamesModule
{
    static func build() -> UIViewController {
        let view = GamesVC()
        let presenter = GamesPresenter()
        let interactor = GamesInteractor()
        let router = GamesRouter()
        
        view.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        
        return view
    }
}
