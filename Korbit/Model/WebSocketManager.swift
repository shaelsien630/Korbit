//
//  WebSocketManager.swift
//  Korbit
//
//  Created by 최서희 on 11/25/24.
//

import Foundation
import Combine

final class WebSocketManager {
    private var webSocketURL: String?
    private var webSocketTask: URLSessionWebSocketTask?
    private var subject = PassthroughSubject<Data, Error>()
    private var pingTimer: Timer?
    
    // WebSocket 연결 시작
    func connect(to url: String) {
        webSocketURL = url
        guard let webSocketURL = URL(string: url) else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: webSocketURL)
        webSocketTask?.resume()
        receiveMessage() // 메시지 수신 시작
    }
    
    // WebSocket 메시지 전송
    func sendMessage(_ message: [[String: Any]]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []) {
            webSocketTask?.send(.string(String(data: jsonData, encoding: .utf8)!)) { error in
                if let error = error {
                    print("Error sending subscription: \(error)")
                }
            }
        }
    }
    
    // WebSocket 메시지 수신
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8) { self?.subject.send(data) }
                case .data(let data):
                    self?.subject.send(data)
                @unknown default:
                    print("Unknown message type received")
                }
                // 메시지 수신 후 다시 receive() 호출
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            }
        }
    }
    
    // 데이터 수신을 Publisher로 노출
    func messagePublisher() -> AnyPublisher<Data, Error> {
        subject.eraseToAnyPublisher()
    }
    
    // 연결이 유지되도록 ping 주기적으로 전송
    private func startPing() {
        pingTimer?.invalidate() // 기존 Ping 타이머 종료
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.webSocketTask?.sendPing { error in
                if let error = error {
                    print("Ping failed: \(error)")
                    self.reconnect() // 연결이 끊긴 경우 재연결
                }
            }
        }
    }
    
    // WebSocket 연결 종료
    func disconnect() {
        pingTimer?.invalidate() // Ping 타이머 중지
        pingTimer = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }
    
    func reconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        if let url = webSocketURL { connect(to: url) }
    }
}
