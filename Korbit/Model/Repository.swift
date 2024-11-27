//
//  Repository.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import Foundation
import Combine

protocol RepositoryProtocol {
    func fetchTickers() -> AnyPublisher<[Ticker], Error>
    func fetchCurrencies() -> AnyPublisher<[Currency], Error>
    func fetchTickersWithCurrencies() -> AnyPublisher<[Ticker], Error>
    
    func connectWebSocket()
    func disconnectWebSocket()
    func subscribeToTickers(symbols: [String])
    func receiveTickerUpdates() -> AnyPublisher<Ticker, Error>
}

class Repository: RepositoryProtocol {
    private let dataSource: DataSourceProtocol
    
    init(dataSource: DataSourceProtocol = DataSource()) {
        self.dataSource = dataSource
    }
    
    private func decodeResponse<T: Decodable>(_ data: Data, type: T.Type) throws -> T {
        let decodedResponse = try JSONDecoder().decode(ResponseData<T>.self, from: data)
        return decodedResponse.data
    }
    
    func fetchTickers() -> AnyPublisher<[Ticker], Error> {
        dataSource.fetchTickers()
            .tryMap { try self.decodeResponse($0, type: [Ticker].self) }
            .eraseToAnyPublisher()
    }
    
    func fetchCurrencies() -> AnyPublisher<[Currency], Error> {
        dataSource.fetchCurrencies()
            .tryMap { try self.decodeResponse($0, type: [Currency].self) }
            .eraseToAnyPublisher()
    }
    
    func fetchTickersWithCurrencies() -> AnyPublisher<[Ticker], Error> {
        Publishers.Zip(fetchTickers(), fetchCurrencies())
            .map { [weak self] tickers, currencies in
                guard let self = self else { return [] } // self가 nil이면 빈 배열 반환
                return tickers.map { ticker in
                    var tickerWithFullName = ticker
                    let symbolWithoutKRW = ticker.symbol.replacingOccurrences(of: "_krw", with: "")
                    if let matchingCurrency = currencies.first(where: { $0.name == symbolWithoutKRW }) {
                        tickerWithFullName.fullName = matchingCurrency.fullName
                    }
                    return tickerWithFullName
                }
            }
            .eraseToAnyPublisher()
    }
    
    func connectWebSocket() {
        dataSource.connectWebSocket()
    }
    
    func disconnectWebSocket() {
        dataSource.disconnectWebSocket()
    }
    
    func subscribeToTickers(symbols: [String]) {
        let subscriptionMessage: [[String: Any]] =
        [[ "method": "subscribe", "type": "ticker", "symbols": symbols ]]
        dataSource.sendWebSocketMessage(message: subscriptionMessage)
    }
    
    func receiveTickerUpdates() -> AnyPublisher<Ticker, Error> {
        dataSource.receiveWebSocketMessages()
            .tryMap { data in
                let decodedResponse = try JSONDecoder().decode(TickerResponse.self, from: data)
                return Ticker(
                    symbol: decodedResponse.symbol,
                    open: decodedResponse.data.open,
                    high: decodedResponse.data.high,
                    low: decodedResponse.data.low,
                    close: decodedResponse.data.close,
                    prevClose: decodedResponse.data.prevClose,
                    priceChange: decodedResponse.data.priceChange,
                    priceChangePercent: decodedResponse.data.priceChangePercent,
                    volume: decodedResponse.data.volume,
                    quoteVolume: decodedResponse.data.quoteVolume,
                    bestBidPrice: decodedResponse.data.bestBidPrice,
                    bestAskPrice: decodedResponse.data.bestAskPrice,
                    lastTradedAt: decodedResponse.data.lastTradedAt
                )
            }
            .eraseToAnyPublisher()
    }
}

struct ResponseData<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}

struct TickerResponse: Decodable {
    let type: String
    let timestamp: Int
    let symbol: String
    let snapshot: Bool?
    let data: TickerData
}

struct TickerData: Decodable {
    let open: String
    let high: String
    let low: String
    let close: String
    let prevClose: String
    let priceChange: String
    let priceChangePercent: String
    let volume: String
    let quoteVolume: String
    let bestAskPrice: String
    let bestBidPrice: String
    let lastTradedAt: Int
}
