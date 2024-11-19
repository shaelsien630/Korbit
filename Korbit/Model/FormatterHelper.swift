//
//  FormatterHelper.swift
//  korbit
//
//  Created by 최서희 on 11/13/24.
//

import Foundation
import SwiftUI

enum FormattingOption {
    case thousandSeparator         // 천 단위 쉼표 사용
    case decimalPlaces             // 절대값이 100 미만일 경우 소수점 두 자리까지 표시
    case addPercentage             // 퍼센테이지 추가
    case addSign                   // +/- 부호 추가 (- 부호는 이미 붙어있음)
    case colorByValue              // 양수 : 빨간색, 음수 : 파란, 0 : 검정 표시
    case integerOnly               // 항상 정수로 표시
    case millionSuffix             // 백만 단위 시 'M' 접미사 추가
}

func formattedValue(_ value: String, options: [FormattingOption]) -> (text: String, color: Color) {
    guard let doubleValue = Double(value) else { return (value, .primary) }

    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    
    var formattedNumber: Double = doubleValue
   
    var useAddPercentage = false
    var useApplycolorByValue = false
    var useAddSign = false
    var useMillionSuffix = false
    
    // 옵션 적용
    for option in options {
        switch option {
        case .thousandSeparator:
            formatter.usesGroupingSeparator = true // 천 단위 구분 기호 사용
        case .decimalPlaces:
            formatter.maximumFractionDigits = abs(doubleValue) < 100 ? 2 : 0
        case .addPercentage:
            useAddPercentage = true
        case .addSign:
            useAddSign = doubleValue > 0
        case .colorByValue:
            useApplycolorByValue = true
        case .integerOnly:
            formatter.maximumFractionDigits = 0
        case .millionSuffix:
            useMillionSuffix = abs(doubleValue) >= 1_000_000
            formattedNumber = useMillionSuffix ? (doubleValue / 1_000_000) : doubleValue
        }
    }
    
    var formattedString = formatter.string(from: NSNumber(value: formattedNumber)) ?? value
    
    if useMillionSuffix { formattedString = formattedString + "M" }
    if useAddPercentage { formattedString = formattedString + "%" }
    if useAddSign { formattedString = "+" + formattedString }
    
    var color: Color = .primary
    if useApplycolorByValue {
        if doubleValue > 0 { color = .red }
        else if doubleValue < 0 { color = .blue }
        else { color = .primary }
    }
    
    return (text: formattedString, color: color)
}
