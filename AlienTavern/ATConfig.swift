//
//  ATConfig.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/25/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import Foundation

struct ATAppConfig {
    let app_id: String
    let app_secret: String

    init(app_id: String) {
        self.app_id = app_id
        if let appSecret = ProcessInfo.processInfo.environment["APP_SECRET"] {
            print("App secret from environment: \(appSecret)")
            self.app_secret = appSecret
        } else {
            print("Failed to read APP_SECRET from environment")
            fatalError("APP_SECRET not found in environment variables")
        }
    }
}

struct ATConfig {
    let boardDisplayName: String
    let board_id: String

    init(boardDisplayName: String, board_id: String) {
        self.boardDisplayName = boardDisplayName
        self.board_id = board_id
    }
}
