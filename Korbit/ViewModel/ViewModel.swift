//
//  ViewModel.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import Foundation
import Combine

enum SortOption {
    case symbol
    case closePrice
    case priceChangePercent
    case quoteVolume
}

final class ViewModel: ObservableObject {
    @Published var tickers: [Ticker] = []
    @Published var searchText: String = ""                          // 검색어 변수
    @Published var isDataLoaded = false                             // 로드 상태
    @Published var currentSortOption: SortOption = .quoteVolume     // 정렬 기준
    @Published var isAscending: Bool = false                        // 오름차순 여부
    @Published var bookmarkToastMessage: String?                    // 즐겨찾기 추가/삭제 토스트 메시지
    
    private let repository: RepositoryProtocol
    private let bookmarkManager = BookmarkManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MarketView - 검색어에 따라 필터링된 tickers
    var filteredTickers: [Ticker] {
        tickers.filter { ticker in
            searchText.isEmpty || ticker.fullName?.localizedCaseInsensitiveContains(searchText) == true || ticker.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // BookMarkView - 즐겨찾기와 검색어에 따라 필터링된 tickers
    var filteredBookmarkedTickers: [Ticker] {
        tickers.filter { ticker in
            (ticker.bookmark == true) && (searchText.isEmpty || ticker.fullName?.localizedCaseInsensitiveContains(searchText) == true || ticker.symbol.localizedCaseInsensitiveContains(searchText))
        }
    }

    init(repository: RepositoryProtocol = Repository()) {
        self.repository = repository
        fetchTickers()
        startPeriodicFetch()
    }
    
    deinit {
        cancellables.removeAll() // ViewModel 해제 시 모든 구독 해제
    }
    
    // 1초마다 현재가 조회 API를 호출하여 데이터를 업데이트하는 메서드
    private func startPeriodicFetch() {
        repository.fetchTickersPeriodically()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error in periodic fetch: \(error)")
                }
            }, receiveValue: { [weak self] newTickers in
                self?.updateTickers(with: newTickers)
            })
            .store(in: &cancellables)
    }
    
    // 새로운 데이터와 기존 데이터를 비교해 다른 부분만 업데이트
    private func updateTickers(with newTickers: [Ticker]) {
        // 새롭게 업데이트된 Ticker 목록을 순회하며 비교 및 업데이트
        newTickers.forEach { newTicker in
            // 기존 tickers에서 동일한 symbol을 가진 Ticker 검색
            if let index = tickers.firstIndex(where: { $0.symbol == newTicker.symbol }) {
                let existingTicker = tickers[index]
                
                // 비교를 통해 값이 달라진 경우에만 업데이트
                if existingTicker.close != newTicker.close ||
                    existingTicker.priceChangePercent != newTicker.priceChangePercent ||
                    existingTicker.quoteVolume != newTicker.quoteVolume {
                    
                    var updatedTicker = newTicker
                    // 기존 Ticker에서 fullName과 bookmark 정보를 유지
                    updatedTicker.fullName = existingTicker.fullName
                    updatedTicker.bookmark = existingTicker.bookmark
                    tickers[index] = updatedTicker  // 변경된 Ticker만 업데이트
                }
            } else {
                // 기존에 없던 새 Ticker는 추가
                tickers.append(newTicker)
            }
        }
    }
    
    // 1. fetchTickers(): 데이터를 가져오고, 결과에 따라 tickers 배열을 업데이트
    func fetchTickers() {
        repository.fetchTickersWithCurrencies()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching tickers: \(error)")
                }
            }, receiveValue: { [weak self] tickers in
                guard let self = self else { return }
                self.tickers = tickers.map { ticker in
                    var tickerWithBookmark = ticker
                    tickerWithBookmark.bookmark = self.bookmarkManager.isBookmarked(id: ticker.symbol)
                    return tickerWithBookmark
                }
                sortTickers()
                isDataLoaded = true
            })
            .store(in: &cancellables)
    }
    
    // 2. updateSortOption(): 정렬 옵션을 업데이트하고, ticker 목록을 다시 정렬
    func updateSortOption(_ option: SortOption) {
        if currentSortOption == option {
            isAscending.toggle()
        } else {
            currentSortOption = option
            isAscending = false
        }
        sortTickers()
    }
    
    // 3. sortTickers(): 정렬 옵션에 따라 tickers 목록을 정렬
    func sortTickers() {
        switch currentSortOption {
        case .symbol:
            tickers.sort {
                isAscending
                ? ($0.fullName?.uppercased() ?? $0.symbol.uppercased()) < ($1.fullName?.uppercased() ?? $1.symbol.uppercased())
                : ($0.fullName?.uppercased() ?? $0.symbol.uppercased()) > ($1.fullName?.uppercased() ?? $1.symbol.uppercased())
            }
        case .closePrice:
            tickers.sort {
                isAscending
                ? (Double($0.close) ?? 0, $0.symbol) < (Double($1.close) ?? 0, $1.symbol)
                : (Double($0.close) ?? 0, $0.symbol) > (Double($1.close) ?? 0, $1.symbol)
            }
        case .priceChangePercent:
            tickers.sort {
                isAscending
                ? (Double($0.priceChangePercent) ?? 0, $0.symbol) < (Double($1.priceChangePercent) ?? 0, $1.symbol)
                : (Double($0.priceChangePercent) ?? 0, $1.symbol) > (Double($1.priceChangePercent) ?? 0, $1.symbol)
            }
        case .quoteVolume:
            tickers.sort {
                isAscending
                ? (Double($0.quoteVolume) ?? 0, $0.symbol) < (Double($1.quoteVolume) ?? 0, $1.symbol)
                : (Double($0.quoteVolume) ?? 0, $1.symbol) > (Double($1.quoteVolume) ?? 0, $1.symbol)
            }
        }
    }
    
    // 4. toggleBookmark(): 즐겨찾기 토글 및 업데이트
    func toggleBookmark(for id: String) {
        bookmarkManager.toggleBookmark(for: id)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error toggling bookmark: \(error)")
                }
            }, receiveValue: { [weak self] success in
                guard success, let self = self else { return }
                if let index = self.tickers.firstIndex(where: { $0.id == id }) {
                    self.tickers[index].bookmark?.toggle()
                    let isBookmarked = self.tickers[index].bookmark ?? false
                    self.bookmarkToastMessage = isBookmarked ? "즐겨찾기에 추가되었습니다" : "즐겨찾기에서 삭제되었습니다"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.bookmarkToastMessage = nil
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    // 5. removeAllBookmarks(): 모든 즐겨찾기 해제
    func removeAllBookmarks() {
        if bookmarkManager.getBookmarkCount() == 0 {
            self.bookmarkToastMessage = "즐겨찾기가 없습니다"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.bookmarkToastMessage = nil
            }
        } else {
            bookmarkManager.clearAllBookmarks()
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error clearing all bookmarks: \(error)")
                    }
                }, receiveValue: { [weak self] in
                    guard let self = self else { return }
                    self.bookmarkToastMessage = "즐겨찾기가 모두 삭제되었습니다"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.bookmarkToastMessage = nil
                    }
                    self.tickers = self.tickers.map { ticker in
                        var updatedTicker = ticker
                        updatedTicker.bookmark = false
                        return updatedTicker
                    }
                })
                .store(in: &cancellables)
        }
    }
}
