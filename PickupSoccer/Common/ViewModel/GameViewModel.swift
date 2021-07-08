//
//  GameViewModel.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/19/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GameViewModel: ViewModel<GameCVCell, Game>
{    
    let id: String
    let address: String
    let startDate: String
    let duration: String
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    init(game: Game) {
        self.id =  game.id ?? ""
        self.address = game.address ?? ""
        self.startDate = GameViewModel.dateFormatter.string(from: game.timeInterval.start)
        let durationInSecs = Int(game.timeInterval.duration)
        let durationInMins = durationInSecs / 60
        let hours = Int(durationInMins) / 60
        let mins = Int(durationInMins) % 60
        self.duration = "\(hours) h \(mins) m"
        super.init(model: game)
    }
    
    deinit {
        print("\(type(of: self)) deinit")
    }
    
    override func config(cell: UICollectionViewCell, indexPath: IndexPath) {
        super.config(cell: cell, indexPath: indexPath)
        view?.locationLabel.text = "\(indexPath.item). \(address)"
        view?.dateLabel.text = startDate
        view?.durationLabel.text = duration
    }
    
    override func size(collectionViewBounds: CGRect) -> CGSize {
        return CGSize(width: CarouselLayoutConstants.minCellWidth,
                      height: CarouselLayoutConstants.minCellHeight)
    }
}
