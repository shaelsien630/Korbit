//
//  DataSource.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import Foundation
import Combine

protocol DataSourceProtocol {
    func fetchTickersPeriodically() -> AnyPublisher<Data, URLError>
    func fetchTickers() -> AnyPublisher<Data, URLError>
    func fetchCurrencies() -> AnyPublisher<Data, URLError>
}

final class DataSource: DataSourceProtocol {
    private let tickerURL: String = "https://api.korbit.co.kr/v2/tickers"
    private let currencyURL: String = "https://api.korbit.co.kr/v2/currencies"
    private var cancellables = Set<AnyCancellable>()
    
    // 1초마다 데이터를 요청하는 함수
    func fetchTickersPeriodically() -> AnyPublisher<Data, URLError> {
        guard let url = URL(string: tickerURL) else {
            fatalError("Invalid URL")
        }
        
        return Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .flatMap { _ in
                URLSession.shared.dataTaskPublisher(for: url)
                    .map { $0.data }
                    .catch { _ in Empty<Data, URLError>() }
            }
            .eraseToAnyPublisher()
    }
    
    // 기존 단발성 데이터 요청
    func fetchTickers() -> AnyPublisher<Data, URLError> {
        guard let url = URL(string: tickerURL) else {
            fatalError("Invalid URL")
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.cancellables.insert(AnyCancellable { })
            })
            .eraseToAnyPublisher()
    }
    
    func fetchCurrencies() -> AnyPublisher<Data, URLError> {
        guard let url = URL(string: currencyURL) else {
            fatalError("Invalid URL")
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.cancellables.insert(AnyCancellable { })
            })
            .eraseToAnyPublisher()
    }
}
