//
//  Character.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/1/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import SceneKit

class MyCharacter: Equatable, Identifiable {
    static func == (lhs: MyCharacter, rhs: MyCharacter) -> Bool {
        if lhs.self.id == rhs.self.id {
            return true

        } else {
            return false
        }
    }

    var characterType: String?
    var location: CGPoint?
    var scnNode: SCNNode?

}
