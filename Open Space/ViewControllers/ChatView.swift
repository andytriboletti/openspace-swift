//
//  ChatView.swift
//  Open Space
//
//  Created by Andrew Triboletti on 2/28/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import SwiftUI

struct ChatView: View {
    @State private var messageText: String = ""
    @State private var messages: [String] = []

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            HStack {
                TextField("Enter message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: sendMessage) {
                    Text("Send")
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.trailing)
            }
        }
    }

    func sendMessage() {
        // Implement logic to send message to server
        // For now, just append the message to the local array
        messages.append(messageText)
        messageText = ""
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Chat Room")
                .font(.largeTitle)
                .padding()

            ChatView()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
