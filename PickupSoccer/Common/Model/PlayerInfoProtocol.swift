//
//  PlayerInfo.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/10/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import Foundation

protocol PlayerInfoProtocol
{
    var gameId: String {get}
    var uid: String {get}
    var isWithHomeTeam: Bool {get set}
    var positionEnum: Position {get set}
}
