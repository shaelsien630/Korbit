//
//  MainView.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var tickerVM: ViewModel
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            TabView()
                .searchable(text: $tickerVM.searchText, prompt: "코인명 또는 심볼 검색")
                .navigationTitle("Korbit 가상자산 거래소")
                .navigationBarTitleDisplayMode(.inline)
                .padding(.vertical, 14)
                .ignoresSafeArea(edges: .bottom)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAlert = true
                        } label: {
                            Image(systemName: "star.slash")
                                .resizable()
                                .foregroundStyle(Color.primary)
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 4)
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("전체 즐겨찾기 삭제"),
                        message: Text("즐겨찾기를 모두 삭제하시겠습니까?"),
                        primaryButton: .destructive(Text("삭제"), action: {
                            tickerVM.removeAllBookmarks() // 삭제 확인 시 삭제 함수 호출
                        }),
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(ViewModel())
}
