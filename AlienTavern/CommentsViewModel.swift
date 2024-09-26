//
//  CommentsViewModel.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/25/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//


import Foundation

class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let config: ATConfig

    init(config: ATConfig) {
        self.config = config
    }

    func loadComments() {
        isLoading = true
        errorMessage = nil

        AlienTavernManager.shared.getComments(for: config.board_id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let comments):
                    self.comments = comments
                case .failure(let error):
                    self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
                }
            }
        }
    }

    func postComment(text: String) {
        isLoading = true
        errorMessage = nil

        AlienTavernManager.shared.postComment(boardID: config.board_id, text: text) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success:
                    self.loadComments() // Reload comments after posting
                case .failure(let error):
                    self.errorMessage = "Failed to post comment: \(error.localizedDescription)"
                }
            }
        }
    }
}
