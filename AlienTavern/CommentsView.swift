import SwiftUI

struct CommentsView: View {
    @StateObject private var viewModel: CommentsViewModel
    @State private var newComment: String = ""

    init(config: ATConfig) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(config: config))
    }

    var body: some View {
        VStack {
            Text("\(viewModel.config.boardDisplayName) Comments")
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
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.comments, id: \.createdAt) { comment in
                            CommentView(comment: comment)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()

            // New comment entry
            HStack {
                TextField("Write a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    viewModel.postComment(text: newComment)
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

struct CommentView: View {
    let comment: Comment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comment.username)
                .font(.headline)
                .foregroundColor(.primary)
            Text(comment.commentText)
                .font(.body)
                .foregroundColor(.secondary)
            Text(comment.createdAt)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color(UIColor.secondarySystemBackground)))
    }
}
