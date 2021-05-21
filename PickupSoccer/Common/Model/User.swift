//
//  User.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

struct User
{
    let firstName: String
    let lastName: String
    let position: Position
}

enum Position {
    case goalKeeper
    case centerBack
    case sweeper
    case fullBack
    case wingBack
    case centerMidfield
    case defensiveMidfield
    case attackingMidfield
    case wideMidfield
    case centerForward
    case secondStriker
    case winger
}
