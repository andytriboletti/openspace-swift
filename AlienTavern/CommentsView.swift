//
//  CommentsView.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/21/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//


import SwiftUI

struct CommentsView: View {
    @State private var comments: [Comment] = []
    @State private var newComment: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var boardDisplayName: String
    var board_id: String
    var app_id: String
    var app_secret: String

    var body: some View {
        VStack {
            Text("\(boardDisplayName) Comments")
                .font(.title)
                .padding()

            if isLoading {
                ProgressView("Loading comments...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if comments.isEmpty {
                Text("No comments yet. Be the first to post!")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    ForEach(comments, id: \.created_at) { comment in
                        VStack(alignment: .leading) {
                            Text(comment.username)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(comment.comment_text)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)
                            Text(comment.created_at)
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
                    postComment()
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
            loadComments()
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            loadComments()
        }
    }

    // Load comments method
    private func loadComments() {
        isLoading = true
        AlienTavern.loadComments(board_id: board_id, app_id: app_id, app_secret: app_secret) { fetchedComments, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
                } else if let fetchedComments = fetchedComments {
                    print("Raw JSON response: \(fetchedComments)")
                    self.comments = fetchedComments
                }
            }
        }
    }


    // Post new comment method
    private func postComment() {
        AlienTavern.postComment(board_id: board_id, app_id: app_id, app_secret: app_secret, comment_text: newComment, username: "Anonymous") { success, error in
            if success {
                self.newComment = ""
                self.loadComments() // Reload comments after posting
            } else if let error = error {
                self.errorMessage = "Failed to post comment: \(error.localizedDescription)"
            }
        }
    }
}

// Sample Comment model
//struct Comment: Codable {
//    let board_id: Int
//    let created_at: String
//    let comment_text: String
//    let username: String
//}

// Example usage in a SwiftUI view
//struct ContentView: View {
//    var body: some View {
//        CommentsView(boardDisplayName: "Test Board", board_id: "testboard123", app_id: "1499913239", app_secret: "c934b3a03d97f5cfccb1482bf219c7bf")
//    }
//}

// Preview for SwiftUI
//struct CommentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentsView(boardDisplayName: "Test Board", board_id: "testboard123", app_id: "1499913239", app_secret: "c934b3a03d97f5cfccb1482bf219c7bf")
//            .preferredColorScheme(.light) // Light mode
//        CommentsView(boardDisplayName: "Test Board", board_id: "testboard123", app_id: "1499913239", app_secret: "c934b3a03d97f5cfccb1482bf219c7bf")
//            .preferredColorScheme(.dark) // Dark mode
//    }
//}
