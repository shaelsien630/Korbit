//
//  ToastView.swift
//  korbit
//
//  Created by 최서희 on 11/14/24.
//

import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
            Text(message)
                .font(.caption)
                .padding(14)
                .background(Color.primary.opacity(0.6))
                .foregroundColor(.darkPrimary)
                .cornerRadius(8)
                .transition(.opacity)
                .zIndex(1)
                .padding(.horizontal)
        }
    }
}

#Preview {
    ToastView(message: "")
}
