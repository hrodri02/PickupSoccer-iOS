//
//  PlayerInfo+Ext.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/4/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

extension PlayerInfo {
    var positionEnum: Position {
        get {
            return Position(rawValue: position)!
        }
        set {
            position = newValue.rawValue
        }
    }
}
