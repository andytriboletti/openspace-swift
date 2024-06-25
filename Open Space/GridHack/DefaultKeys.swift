//
//  DefaultKeys.swift
//  Ask A Robot
//
//  Created by Andy Triboletti on 11/20/19.
//  Copyright © 2019 GreenRobot LLC. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
extension DefaultsKeys {
    var firebaseUid: DefaultsKey<String?> { return .init("firebase_uid") }
    var phoneNumber: DefaultsKey<String?> { return .init("phone_number")}
    var isAdmin: DefaultsKey<Int?> { return .init("is_admin")}
}
