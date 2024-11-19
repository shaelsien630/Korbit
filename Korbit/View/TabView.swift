//
//  TabView.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import SwiftUI

enum tapInfo : String, CaseIterable {
    case market = "마켓"
    case bookmark = "즐겨찾기"
}

struct TabView: View {
    @State private var selectedPicker: tapInfo = .market
    @Namespace private var animation
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Tap()
            SortView()
            ZStack {
                if selectedPicker == .market {
                    MarketView()
                        .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    BookmarkView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.2), value: selectedPicker)
            
            
            Spacer()
        }
        .offset(y: -10)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    if value.translation.width < -50 {
                        // 스와이프 왼쪽 -> 다음 탭 (market -> bookmark)
                        if selectedPicker == .market {
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.2)) {
                                selectedPicker = .bookmark
                            }
                        }
                    } else if value.translation.width > 50 {
                        // 스와이프 오른쪽 -> 이전 탭 (bookmark -> market)
                        if selectedPicker == .bookmark {
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.2)) {
                                selectedPicker = .market
                            }
                        }
                    }
                }
        )
    }
    
    @ViewBuilder
    private func Tap() -> some View {
        HStack {
            ForEach(tapInfo.allCases, id: \.self) { item in
                VStack {
                    Text(item.rawValue)
                        .font(.headline)
                        .frame(maxWidth: .infinity/2)
                        .foregroundColor(selectedPicker == item ? .primary : .gray)
                        .fontWeight(selectedPicker == item ? .bold : .medium)
                    
                    if selectedPicker == item {
                        Capsule()
                            .foregroundColor(.primary)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "market", in: animation)
                    } else {
                        Capsule()
                            .foregroundColor(.darkPrimary)
                            .frame(height: 2)
                    }
                }
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.2)) {
                        self.selectedPicker = item
                    }
                }
            }
        }
    }
}

#Preview {
    TabView()
}
