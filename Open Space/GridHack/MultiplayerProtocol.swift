//
//  MultiplayerProtocol.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/6/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
protocol MultiplayerProtocol: AnyObject {
    func opponentFound()
    func endGame()
    func connectionNotEstablished()
}
