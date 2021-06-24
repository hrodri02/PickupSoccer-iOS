//
//  AwayTeamCVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/27/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class AwayTeamCVCell: HomeTeamCVCell
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addSubviews() {
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(forwardStackView)
        verticalStackView.addArrangedSubview(midFieldStackView)
        verticalStackView.addArrangedSubview(defenseStackView)
        verticalStackView.addArrangedSubview(goalieImageView)
    }
    
    override func setBorderColorOfImageViews() {
        for imageView in imageViews {
            imageView.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
}
