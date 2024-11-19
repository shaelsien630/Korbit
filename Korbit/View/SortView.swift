//
//  SortView.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import SwiftUI

struct SortView: View {
    @EnvironmentObject var tickerVM: ViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            SortButton(title: "가상자산명", sortOption: .symbol, currentSortOption: tickerVM.currentSortOption, isAscending: tickerVM.isAscending) {
                tickerVM.updateSortOption(.symbol)
            }
            
            Spacer()
            
            SortButton(title: "현재가", sortOption: .closePrice, currentSortOption: tickerVM.currentSortOption, isAscending: tickerVM.isAscending) {
                tickerVM.updateSortOption(.closePrice)
            }
            
            SortButton(title: "24시간", sortOption: .priceChangePercent, currentSortOption: tickerVM.currentSortOption, isAscending: tickerVM.isAscending) {
                tickerVM.updateSortOption(.priceChangePercent)
            }
            
            SortButton(title: "거래대금", sortOption: .quoteVolume, currentSortOption: tickerVM.currentSortOption, isAscending: tickerVM.isAscending) {
                tickerVM.updateSortOption(.quoteVolume)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 32)
        .background(Color(.sortViewBg))
    }
}

struct SortButton: View {
    let title: String
    let sortOption: SortOption
    let currentSortOption: SortOption
    let isAscending: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                
                VStack(spacing: 2) {
                    let upColor : Color = (currentSortOption == sortOption && isAscending) ? .primary : .sortArrow
                    let downColor : Color = (currentSortOption == sortOption && !isAscending) ? .primary : .sortArrow
                    
                    Image(systemName: "arrowtriangle.up.fill")
                        .resizable()
                        .foregroundColor(upColor)
                        .frame(width: 8, height: 4)
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .foregroundColor(downColor)
                        .frame(width: 8, height: 4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 70)
    }
}
#Preview {
    SortView()
}
