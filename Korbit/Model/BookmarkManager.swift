//
//  BookmarkManager.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import Foundation
import Combine

class BookmarkManager {
    private let userDefaultsKey = "bookmarkedItems"
    
    // 현재 즐겨찾기 목록을 불러오는 함수
    private var bookmarks: Set<String> {
        get {
            let savedItems = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] ?? []
            return Set(savedItems)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: userDefaultsKey)
        }
    }
    
    // 즐겨찾기 추가 함수
    func addBookmark(for id: String) -> AnyPublisher<Bool, Never> {
        return Future { [weak self] promise in
            DispatchQueue.global().async { // 비동기 저장
                var updatedBookmarks = self?.bookmarks ?? []
                updatedBookmarks.insert(id)
                self?.bookmarks = updatedBookmarks // UserDefaults에 저장
                promise(.success(true))
            }
        }
        .receive(on: DispatchQueue.main) // 결과를 메인 스레드로 전달
        .eraseToAnyPublisher()
    }
    
    // 즐겨찾기 해제 함수
    func removeBookmark(for id: String) -> AnyPublisher<Bool, Never> {
        return Future { [weak self] promise in
            DispatchQueue.global().async { // 비동기 저장
                var updatedBookmarks = self?.bookmarks ?? []
                updatedBookmarks.remove(id)
                self?.bookmarks = updatedBookmarks // UserDefaults에 저장
                promise(.success(true))
            }
        }
        .receive(on: DispatchQueue.main) // 결과를 메인 스레드로 전달
        .eraseToAnyPublisher()
    }
    
    // 즐겨찾기 상태 토글 함수
    func toggleBookmark(for id: String) -> AnyPublisher<Bool, Never> {
        if bookmarks.contains(id) {
            return removeBookmark(for: id)
        } else {
            return addBookmark(for: id)
        }
    }
    
    // 즐겨찾기 상태 확인 함수
    func isBookmarked(id: String) -> Bool {
        return bookmarks.contains(id)
    }
    
    // 모든 즐겨찾기 삭제 함수
    func clearAllBookmarks() -> AnyPublisher<Void, Never> {
        return Future { [weak self] promise in
            DispatchQueue.global().async {
                self?.bookmarks = [] // UserDefaults의 즐겨찾기 초기화
                promise(.success(()))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // 즐겨찾기 개수 확인 함수
    func getBookmarkCount() -> Int {
        return bookmarks.count
    }
}
