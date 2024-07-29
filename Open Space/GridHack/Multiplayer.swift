import Foundation
import Starscream
import SwiftyJSON
import FirebaseAuth
import SceneKit

class Multiplayer: WebSocketDelegate {

    var isConnected: Bool = false
    var socket: WebSocket?
    var connectionTimer: Timer?
    weak var delegate: MultiplayerProtocol?

    func sendString(string: String) {
        socket?.write(string: string)
    }

    func sendMessage(message: Any) {
        let jsonMessage = JSON(message)
        guard let jsonMessageString = jsonMessage.rawString() else {
            //print("Failed to create JSON string")
            return
        }
        //print("sending message:", jsonMessageString)
        sendString(string: jsonMessageString)
    }

    func tappedPosition(position: SCNVector3) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message: [String: Any] = [
            "action": "tapped_position",
            "x": position.x,
            "y": position.y,
            "firebase_uid": uid
        ]
        sendMessage(message: message)
    }

    func enemyRemoved(position: CGPoint, characterType: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message: [String: Any] = [
            "action": "enemy_removed",
            "x": position.x,
            "y": position.y,
            "character_type": characterType,
            "firebase_uid": uid
        ]
        sendMessage(message: message)
    }

    func spawnedUnit(enemyType: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message: [String: Any] = [
            "action": "enemy_spawned",
            "enemy_type": enemyType,
            "firebase_uid": uid
        ]
        sendMessage(message: message)
    }

    func enemyOwned(position: CGPoint) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message: [String: Any] = [
            "action": "enemy_owned",
            "x": position.x,
            "y": position.y,
            "firebase_uid": uid
        ]
        sendMessage(message: message)
    }

    func enemyMoved(initialPosition: CGPoint, finalPosition: CGPoint, characterType: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message: [String: Any] = [
            "action": "enemy_moved",
            "initial_x": initialPosition.x,
            "initial_y": initialPosition.y,
            "final_x": finalPosition.x,
            "final_y": finalPosition.y,
            "character_type": characterType,
            "firebase_uid": uid
        ]
        sendMessage(message: message)
    }

    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        //print("did receive \(event)")
        switch event {
        case .connected(let headers):
            handleConnected(headers: headers)
        case .disconnected(let reason, let code):
            handleDisconnected(reason: reason, code: code)
        case .text(let string):
            handleText(string: string)
        case .binary(let data):
            handleBinary(data: data)
        case .ping:
            handlePing()
        case .pong:
            handlePong()
        case .reconnectSuggested:
            handleReconnectSuggested()
        case .cancelled:
            handleCancelled()
        case .error(let error):
            handleError(error: error)
        case .viabilityChanged:
            handleViabilityChanged()
        case .peerClosed:
            handlePeerClosed()
        }
    }

    func handleConnected(headers: [String: String]) {
        isConnected = true
        //print("websocket is connected: \(headers)")
        let message: [String: Any] = [
            "action": "add_to_waiting_to_join",
            "firebase_uid": Auth.auth().currentUser?.uid ?? ""
        ]
        sendMessage(message: message)
    }

    func handleDisconnected(reason: String, code: UInt16) {
        isConnected = false
        //print("websocket is disconnected: \(reason) with code: \(code)")
    }

    func handleText(string: String) {
        //print("Received text: \(string)")
        let jsonMessage = JSON(parseJSON: string)
        let action = jsonMessage["action"].stringValue
        //print(action)
        switch action {
        case "opponent_found":
            handleOpponentFound(jsonMessage: jsonMessage)
        case "tapped_position":
            handleTappedPosition(jsonMessage: jsonMessage)
        case "enemy_owned":
            handleEnemyOwned(jsonMessage: jsonMessage)
        case "enemy_moved":
            handleEnemyMoved(jsonMessage: jsonMessage)
        case "enemy_spawned":
            handleEnemySpawned(jsonMessage: jsonMessage)
        case "end_game":
            handleEndGame()
        case "enemy_removed":
            handleEnemyRemoved(jsonMessage: jsonMessage)
        default:
            print("Unknown action: \(action)")
        }
    }

    func handleBinary(data: Data) {
        //print("Received binary data: \(data)")
    }

    func handlePing() {
        //print("Received ping")
    }

    func handlePong() {
        //print("Received pong")
    }

    func handleReconnectSuggested() {
        //print("Reconnect suggested")
    }

    func handleCancelled() {
        //print("Connection cancelled")
        isConnected = false
    }

    func handleViabilityChanged() {
        //print("Viability changed")
    }

    func handlePeerClosed() {
        //print("Peer closed")
    }

    func handleError(error: Error?) {
        //print("error with socket server. is it running?")
        //print(error?.localizedDescription as Any)
    }

    func disconnectFromWebSocket() {
        //print("disconnecting from websocket")
        socket?.disconnect()
    }

    func connectToWebSocket() {
        //print("connect to web socket")
        var request = URLRequest(url: URL(string: "wss://bernie-vs-trump.greenrobot.com:9001")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request, certPinner: nil)
        socket?.delegate = self
        socket?.connect()
        connectionTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(Common.connectionTimeout),
            target: self,
            selector: #selector(connectionNotEstablished),
            userInfo: nil,
            repeats: false
        )
    }

    @objc func connectionNotEstablished() {
        if !isConnected {
            //print("not connected, alert user")
            delegate?.connectionNotEstablished()
        } else {
            connectionTimer?.invalidate()
            connectionTimer = nil
        }
    }

    // Action handlers
    func handleOpponentFound(jsonMessage: JSON) {
        let opponentUsername = jsonMessage["opponent_username"].stringValue
        //print("opponent username is: \(opponentUsername)")
        delegate?.opponentFound()
    }

    func handleTappedPosition(jsonMessage: JSON) {
        let xCoord = jsonMessage["x"].intValue
        let yCoord = jsonMessage["y"].intValue
        //print("received tapped position for opponent x \(xCoord) y \(yCoord)")
        let location = CGPoint(x: xCoord, y: yCoord)
        GridHackUtils().setEnemyTapped(location: location)
    }

    func handleEnemyOwned(jsonMessage: JSON) {
        let xCoord = jsonMessage["x"].intValue
        let yCoord = jsonMessage["y"].intValue
        //print("received enemy_owned x \(xCoord) y \(yCoord)")
        let location = CGPoint(x: xCoord, y: yCoord)
        GridHackUtils().setToEnemyOwned(closest: location)
    }

    func handleEnemyMoved(jsonMessage: JSON) {
        let initialX = jsonMessage["initial_x"].intValue
        let initialY = jsonMessage["initial_y"].intValue
        let finalX = jsonMessage["final_x"].intValue
        let finalY = jsonMessage["final_y"].intValue
        let characterType = jsonMessage["character_type"].stringValue

        //print("received enemy_moved initial_x \(initialX) initial_y \(initialY) final_x \(finalX) final_y \(finalY)")
        let location = CGPoint(x: initialX, y: initialY)
        let finalLocation = CGPoint(x: finalX, y: finalY)
        if let enemy = GridHackUtils().findEnemyUnitFromCoordinates(coordinates: location, enemyType: characterType) {
            GridHackUtils().updateEnemyLocation(closest: finalLocation, myCharacter: enemy)

            switch enemy.characterType {
            case "builder":
                EnemyBuilderFactory.spawnEnemyBuilder(character: enemy)
            case "attacker":
                EnemyAttackerFactory.spawnEnemyAttacker(character: enemy)
            case "hacker":
                EnemyHackerFactory.spawnHacker(character: enemy)
            default:
                break
            }
        } else {
            //print("can't move enemy it's nil")
        }
    }

    func handleEnemySpawned(jsonMessage: JSON) {
        let enemyType = jsonMessage["enemy_type"].stringValue
        switch enemyType {
        case "builder":
            EnemyBuilderFactory.spawnEnemyBuilder(character: nil)
        case "attacker":
            EnemyAttackerFactory.spawnEnemyAttacker(character: nil)
        case "hacker":
            EnemyHackerFactory.spawnHacker(character: nil)
        default:
            break
        }
    }

    func handleEndGame() {
        delegate?.endGame()
    }

    func handleEnemyRemoved(jsonMessage: JSON) {
        let xCoord = jsonMessage["x"].intValue
        let yCoord = jsonMessage["y"].intValue
        let characterType = jsonMessage["character_type"].stringValue
        //print("received enemy removed x \(xCoord) y \(yCoord)")
        let location = CGPoint(x: xCoord, y: yCoord)
        //print(location)

        if let unit = GridHackUtils().findFriendlyUnitFromCoordinates(coordinates: location, friendlyType: characterType) {
            GridHackUtils().removeFriendly(friendlyToRemove: unit)
        } else {
            //print("couldn't find enemy to remove")
        }
    }
}
