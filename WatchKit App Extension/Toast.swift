//
//  Toast.swift
//  WatchKit App Extension
//
//  Created by kaoji on 5/1/23.
//  Copyright © 2023 Jonny. All rights reserved.
//

import Foundation
import SwiftUI

enum ToastType {
    case success, error, warning
}

struct ToastView: View {
    let message: String
    let type: ToastType
    let duration: Double

    @State private var isVisible = false

    var body: some View {
        VStack {
            Spacer()

            if isVisible {
                HStack {
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                }
                .background(typeColor())
                .cornerRadius(8)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    isVisible = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }

    private func typeColor() -> Color {
        switch type {
        case .success:
            return Color.green
        case .error:
            return Color.red
        case .warning:
            return Color.yellow
        }
    }
}
