//
//  AwayTeamCVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/27/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class AwayTeamCVCell: TeamCVCell
{
    override var positionToIndex: [Position : Int] {
        [Position.goalKeeper : 0,
        Position.leftFullBack: 4,
        Position.leftCenterBack: 3,
        Position.rightCenterBack: 2,
        Position.rightFullBack: 1,
        Position.leftSideMidfielder: 8,
        Position.leftCenterMidfield: 7,
        Position.rightCenterMidField: 6,
        Position.rightSideMidfielder: 5,
        Position.leftCenterForward: 10,
        Position.rightCenterForward: 9]
    }
    
    override func addSubviews() {
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(forwardStackView)
        verticalStackView.addArrangedSubview(midFieldStackView)
        verticalStackView.addArrangedSubview(defenseStackView)
        verticalStackView.addArrangedSubview(goalieImageView)
    }
}
