//
//  WebSocketManager.swift
//  Open Space
//
//  Created by Andrew Triboletti on 2/28/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
import Starscream

class WebSocketManager: WebSocketDelegate {

    var socket: WebSocket!

    init() {
        let url = URL(string: "wss://server2.openspace.greenrobot.com:8080")!
        // Create a URLRequest with the URL
        var request = URLRequest(url: url)
        // Set additional headers if needed
        // request.setValue("value", forHTTPHeaderField: "headerField")
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("Connected to WebSocket server with headers: \(headers)")
        case .disconnected(let reason, let code):
            print("Disconnected from WebSocket server: \(reason) (code: \(code))")
        case .text(let string):
            print("Received text: \(string)")
        case .ping:
            break
        case .pong:
            break
        case .error(let error):
            print("WebSocket error: \(String(describing: error))")
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            break
        case .binary:
            break
        case .peerClosed:
            break
        }
    }
}
