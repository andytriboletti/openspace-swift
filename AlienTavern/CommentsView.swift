//
//  CommentsView.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/21/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import SwiftUI

struct CommentsView: View {
    @StateObject private var viewModel: CommentsViewModel
    @State private var newComment: String = ""

    init(boardDisplayName: String, boardID: String) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(boardID: boardID))
        self.boardDisplayName = boardDisplayName
    }

    var boardDisplayName: String

    var body: some View {
        VStack {
            Text("\(boardDisplayName) Comments")
                .font(.title)
                .padding()

            if viewModel.isLoading {
                ProgressView("Loading comments...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if viewModel.comments.isEmpty {
                Text("No comments yet. Be the first to post!")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    ForEach(viewModel.comments, id: \.createdAt) { comment in
                        VStack(alignment: .leading) {
                            Text(comment.username)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(comment.commentText)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                            Text(comment.createdAt)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemBackground)))
                        .padding(.horizontal)
                    }
                }
            }

            Spacer()

            // New comment entry
            HStack {
                TextField("Write a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    viewModel.postComment(text: newComment, username: "Anonymous")
                    newComment = ""
                }) {
                    Text("Post")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(newComment.isEmpty)
                .padding()
            }
        }
        .onAppear {
            viewModel.loadComments()
        }
        .background(Color(UIColor.systemBackground))
    }
}

import Foundation

class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let boardID: String

    init(boardID: String) {
        self.boardID = boardID
    }

    func loadComments() {
        isLoading = true
        errorMessage = nil

        AlienTavernManager.shared.getComments(for: boardID) { [weak self] comments in
            DispatchQueue.main.async(execute: DispatchWorkItem(block: {
                guard let self = self else { return }
                self.isLoading = false
                if let fetchedComments = comments {
                    self.comments = fetchedComments
                } else {
                    self.errorMessage = "Failed to load comments"
                }
            }))
        }
    }

    func postComment(text: String, username: String) {
        isLoading = true
        errorMessage = nil

        AlienTavernManager.shared.postComment(boardID: boardID, text: text, username: username) { [weak self] success in
            DispatchQueue.main.async(execute: DispatchWorkItem(block: {
                guard let self = self else { return }
                self.isLoading = false
                if success {
                    self.loadComments() // Reload comments after posting
                } else {
                    self.errorMessage = "Failed to post comment"
                }
            }))
        }
    }
}
