//
//  TeamViewModel.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 7/8/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class TeamViewModel: ViewModel<TeamCVCell, [String: Position]>
{
    var soccerPlayerImageData: Data?
    
    deinit {
        print("\(type(of: self)) deinit")
    }
    
    override func config(cell: UICollectionViewCell, indexPath: IndexPath) {
        super.config(cell: cell, indexPath: indexPath)
        
        // home team
        if indexPath.item == 0 {
            view?.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5)
            view?.setBorderColorOfImageViews(color: UIColor.systemRed.withAlphaComponent(0.9))
            view?.addSubviewsForHomeTeam()
        }
        else {
        // away team
            view?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
            view?.setBorderColorOfImageViews(color: UIColor.systemBlue.withAlphaComponent(0.9))
            view?.addSubviewsForHomeTeam()
        }
        view?.setConstraints()
        
        guard let imageViews = view?.imageViews else {
            fatalError("Failed to get the imageViews")
        }
        
        for imageView in imageViews {
            imageView.image = nil
            imageView.alpha = 0.0
        }
        
        let imageData = getSoccerPlayerImage()
        for (_, position) in model {
            if let data = imageData {
                let index = Int(position.rawValue)
                imageViews[index].alpha = 1.0
                imageViews[index].image = UIImage(data: data)
            }
        }
    }
    
    private func getSoccerPlayerImage() -> Data? {
        if let imageData = soccerPlayerImageData {
            return imageData
        }
        
        if let imageURL = Bundle.main.url(forResource: "pexels-photo-5246967", withExtension: "jpeg") {
            do {
                let imageData = try Data(contentsOf: imageURL)
                soccerPlayerImageData = imageData
                return imageData
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
