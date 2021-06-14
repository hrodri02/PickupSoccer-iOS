//
//  User.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/20/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

protocol User
{
    var uid: String? {get set}
    var firstName: String? {get set}
    var lastName: String? {get set}
}

enum Position: Int16 {
    case goalKeeper
    case leftFullBack
    case leftCenterBack
    case rightCenterBack
    case rightFullBack
    case leftSideMidfielder
    case leftCenterMidfield
    case rightCenterMidField
    case rightSideMidfielder
    case leftCenterForward
    case rightCenterForward
    case none
}
