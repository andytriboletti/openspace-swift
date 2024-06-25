//
//  AttributeProtocol.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit

protocol AttributeProtcol {
    func getColor() -> UIColor
    func getLightColor() -> UIColor
    func getAttackerTexture() -> String
    func getBuilderTexture() -> String
    func getHackerTexture() -> String
}
