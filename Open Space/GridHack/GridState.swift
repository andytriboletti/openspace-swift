//
//  GridState.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

public enum GridState {
    case open
    case waitingForFriendlyConstruction
    case waitingForEnemyConstruction
    case friendlyOwned
    case enemyOwned
    case underFriendlyConstruction
    case underEnemyConstruction
}
