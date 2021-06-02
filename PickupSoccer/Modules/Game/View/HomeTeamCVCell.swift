//
//  TeamCVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/26/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class HomeTeamCVCell: TeamCVCell
{
    override var positionToIndex: [Position : Int] {
        [Position.goalKeeper : 0,
         Position.leftFullBack: 1,
         Position.leftCenterBack: 2,
         Position.rightCenterBack: 3,
         Position.rightFullBack: 4,
         Position.leftSideMidfielder: 5,
         Position.leftCenterMidfield: 6,
         Position.rightCenterMidField: 7,
         Position.rightSideMidfielder: 8,
         Position.leftCenterForward: 9,
         Position.rightCenterForward: 10]
    }
}
