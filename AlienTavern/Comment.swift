//
//  Comment.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/25/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//


import Foundation

struct Comment: Codable {
    let boardID: String
    let createdAt: String
    let commentText: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case boardID = "board_id"
        case createdAt = "created_at"
        case commentText = "comment_text"
        case username
    }
}
