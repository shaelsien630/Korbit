//
//  TickerView.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import SwiftUI

struct TickerView: View {
    let fullName: String
    let close: String
    let priceChangePercent: String
    let priceChange: String
    let quoteVolume: String
    @Binding var bookmark: Bool
    var onToggleBookmark: (() -> Void)?
    @State private var borderColor: Color = .clear
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                    bookmark.toggle()
                    onToggleBookmark?()
                }
            }) {
                Image(systemName: bookmark ? "star.fill" : "star")
                    .resizable()
                    .foregroundColor(bookmark ? .yellow : .gray)
                    .frame(width: 16, height: 16)
                    .padding(.trailing, 4)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(fullName)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            let closeFormatted = formattedValue(close, options: [.thousandSeparator, .decimalPlaces])
            let priceChangePercentFormatted = formattedValue(priceChangePercent, options: [.addPercentage, .addSign, .colorByValue])
            let priceChangeFormatted = formattedValue(priceChange, options: [.thousandSeparator, .decimalPlaces, .millionSuffix])
            let quoteVolumeFormatted = formattedValue(quoteVolume, options: [.thousandSeparator, .integerOnly, .millionSuffix])
            
            Text(closeFormatted.text)
                .foregroundColor(priceChangePercentFormatted.color)
                .font(.subheadline)
                .frame(width: 90, alignment: .trailing)
            VStack(alignment: .center, spacing: 0) {
                Text(priceChangePercentFormatted.text)
                    .foregroundColor(priceChangePercentFormatted.color)
                    .font(.caption)
                    .frame(width: 60, alignment: .trailing)
                Text(priceChangeFormatted.text)
                    .foregroundColor(priceChangePercentFormatted.color)
                    .font(.caption)
                    .frame(width: 60, alignment: .trailing)
            }
            Text(quoteVolumeFormatted.text)
                .font(.subheadline)
                .frame(width: 70, alignment: .trailing)
        }
        .listRowBackground(Rectangle()
            .stroke(borderColor, lineWidth: 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity))
        .onChange(of: close, perform: handleCloseChange) // close 값 변경 감지
    }
    
    // close 값 변경에 따른 테두리 색상 업데이트 함수
    private func handleCloseChange(_ newClose: String) {
        guard let newCloseValue = Double(newClose) else { return }
        guard let oldCloseValue = Double(close) else { return }
        
        withAnimation(.easeInOut(duration: 0.7)) {
            borderColor = newCloseValue > oldCloseValue ? .red : .blue
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeInOut(duration: 0.7)) {
                borderColor = .clear
            }
        }
    }
}
