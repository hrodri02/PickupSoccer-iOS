//
//  PlayerMO+Ext.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/10/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

extension PlayerInfoMO: PlayerInfoProtocol
{
    var uid: String {
        get {
            if let uid = player?.uid {
                return uid
            }
            return ""
        }
    }
    
    var gameId: String {
        get {
            if let id = game?.id {
                return id
            }
            return ""
        }
    }
    
    var positionEnum: Position {
        get {
            return Position(rawValue: position)!
        }
        set {
            position = newValue.rawValue
        }
    }
}
