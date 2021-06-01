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
    let uid: Int
    let firstName: String
    let lastName: String
    var isWithHomeTeam: Bool
    var position: Position
}

extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}

enum Position {
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
