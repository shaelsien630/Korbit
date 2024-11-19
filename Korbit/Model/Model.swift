//
//  Model.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

struct Ticker: Identifiable, Decodable {
    var id: String { symbol }
    let symbol: String
    let open: String
    let high: String
    let low: String
    let close: String
    let prevClose: String
    let priceChange: String
    let priceChangePercent: String
    let volume: String
    let quoteVolume: String
    let bestBidPrice: String
    let bestAskPrice: String
    let lastTradedAt: Int
    
    var fullName: String?
    var bookmark: Bool?
}

struct Currency: Identifiable, Decodable {
    var id: String { name }
    let name: String
    let fullName: String
    let withdrawalStatus: String
    let depositStatus: String
    let withdrawalTxFee: String
    let withdrawalMinAmount: String
    let withdrawalMaxAmountPerRequest: String
}
