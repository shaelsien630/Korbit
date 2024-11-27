//
//  DataSource.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import Foundation
import Combine

protocol DataSourceProtocol {
    // REST API
    func fetchTickers() -> AnyPublisher<Data, URLError>
    func fetchCurrencies() -> AnyPublisher<Data, URLError>
    
    // WebSocket API
    func connectWebSocket()
    func sendWebSocketMessage(message: [[String: Any]])
    func receiveWebSocketMessages() -> AnyPublisher<Data, Error>
    func disconnectWebSocket()
    func reconnectWebSocket()
}

final class DataSource: DataSourceProtocol {
    private let tickerURL: String = APIConfig.value(forKey: "tickerURL") ?? ""
    private let currencyURL: String = APIConfig.value(forKey: "currencyURL") ?? ""
    private let webSocketManager: WebSocketManager
    
    init(webSocketManager: WebSocketManager = WebSocketManager()) {
        self.webSocketManager = webSocketManager
    }
    
    // MARK: - REST API
    func fetchTickers() -> AnyPublisher<Data, URLError> {
        guard let url = URL(string: tickerURL) else {
            return Fail(error: URLError(.badURL))
                        .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
    
    func fetchCurrencies() -> AnyPublisher<Data, URLError> {
        guard let url = URL(string: currencyURL) else {
            return Fail(error: URLError(.badURL))
                        .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .eraseToAnyPublisher()
    }
    
    // MARK: - WebSocket API
    func connectWebSocket() {
        webSocketManager.connect(to: APIConfig.value(forKey: "webSocketURL") ?? "")
    }
    
    func sendWebSocketMessage(message: [[String: Any]]) {
        webSocketManager.sendMessage(message)
    }
    
    func receiveWebSocketMessages() -> AnyPublisher<Data, Error> {
        webSocketManager.messagePublisher()
    }
    
    func disconnectWebSocket() {
        webSocketManager.disconnect()
    }
    
    func reconnectWebSocket() {
        webSocketManager.reconnect()
    }
}

struct APIConfig {
    static func value(forKey key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "APIURL", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) else {
            print("Failed to load APIURL.plist")
            return nil
        }
        return plist[key] as? String
    }
}
