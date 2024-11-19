//
//  Repository.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import Foundation
import Combine

protocol RepositoryProtocol {
    func fetchTickersPeriodically() -> AnyPublisher<[Ticker], Error>
    func fetchTickers() -> AnyPublisher<[Ticker], Error>
    func fetchCurrencies() -> AnyPublisher<[Currency], Error>
    func fetchTickersWithCurrencies() -> AnyPublisher<[Ticker], Error>
}

class Repository: RepositoryProtocol {
    private let dataSource: DataSourceProtocol
    private var cancellables = Set<AnyCancellable>() // Cancellable 관리를 위한 Set
    
    init(dataSource: DataSourceProtocol = DataSource()) {
        self.dataSource = dataSource
    }
    
    func fetchTickersPeriodically() -> AnyPublisher<[Ticker], Error> {
        dataSource.fetchTickersPeriodically() // DataSource의 주기적 호출 기능 사용
            .tryMap { data in
                struct ResponseData: Decodable {
                    let success: Bool
                    let data: [Ticker]
                }
                let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
                return decodedResponse.data
            }
            .eraseToAnyPublisher()
    }
    
    func fetchTickers() -> AnyPublisher<[Ticker], Error> {
        dataSource.fetchTickers()
            .tryMap { data in
                struct ResponseData: Decodable {
                    let success: Bool
                    let data: [Ticker]
                }
                let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
                return decodedResponse.data
            }
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.cancellables.insert(AnyCancellable { })
            })
            .eraseToAnyPublisher()
    }
    
    func fetchCurrencies() -> AnyPublisher<[Currency], Error> {
        dataSource.fetchCurrencies()
            .tryMap { data in
                struct ResponseData: Decodable {
                    let success: Bool
                    let data: [Currency]
                }
                let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
                return decodedResponse.data
            }
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.cancellables.insert(AnyCancellable { })
            })
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
}
