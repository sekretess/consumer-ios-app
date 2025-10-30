//
//  SekretessRabbitMqClient.swift
//  sekretess
//
//  Created by Elnur Atakishiyev on 20.10.25.
//

import OSLog

import Foundation

class WebSocketClient: NSObject, URLSessionWebSocketDelegate {

    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL

    init(url: URL) {
        print("Initialized WebSocketClient")
        self.url = url
        super.init()
    }

    func connect() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        os_log("Attempting to connect to WebSocket...")
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        os_log("Disconnected from WebSocket.")
    }

    func send(message: String) {
        let webSocketMessage = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(webSocketMessage) { error in
            if let error = error {
                os_log("Error sending message: \(error)")
            } else {
                os_log("Sent message: \(message)")
            }
        }
    }

    func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    os_log("Received text message: \(text)")
                case .data(let data):
                    os_log("Received binary message: \(data)")
                @unknown default:
                    print("Received unknown message type")
                }
                // Continue receiving messages
                self?.receive()
            case .failure(let error):
                os_log("Error receiving message: \(error)")
            }
        }
    }

    // MARK: - URLSessionWebSocketDelegate

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        os_log("WebSocket connection opened.")
        // Start receiving messages once connected
        receive()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket connection closed with code: \(closeCode), reason: \(reason.map { String(data: $0, encoding: .utf8) ?? "" } ?? "nil")")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            os_log("WebSocket task completed with error: \(error)")
        }
    }
}

// Example Usage:
// let websocketURL = URL(string: "wss://echo.websocket.org")! // A public echo server for testing
// let client = WebSocketClient(url: websocketURL)
// client.connect()
//
// // Send a message after a short delay (to allow connection to establish)
// DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//     client.send(message: "Hello from Swift!")
// }
//
// // Disconnect after some time
// DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//     client.disconnect()
// }
