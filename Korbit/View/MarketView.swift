//
//  MarketView.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import SwiftUI

struct MarketView: View {
    @EnvironmentObject var tickerVM: ViewModel
    
    var body: some View {
        ZStack {
            if tickerVM.isDataLoaded {
                List {
                    ForEach(tickerVM.filteredTickers, id: \.id) { ticker in
                        TickerView(
                            fullName: ticker.fullName ?? ticker.symbol,
                            close: ticker.close,
                            priceChangePercent: ticker.priceChangePercent,
                            priceChange: ticker.priceChange,
                            quoteVolume: ticker.quoteVolume,
                            bookmark: .constant(ticker.bookmark ?? false),
                            onToggleBookmark: {
                                tickerVM.toggleBookmark(for: ticker.id)
                            }
                        )
                    }
                }
                .listStyle(.plain)
                
                VStack {
                    Spacer()
                    if let message = tickerVM.bookmarkToastMessage {
                        ToastView(message: message)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
            } else {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MarketView()
}
