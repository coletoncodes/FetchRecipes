//
//  ErrorState.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import SwiftUI

/// An encapsulation on a collection of data to populate the error with.
struct ErrorState: Equatable {
    let title: String
    let message: String
    let actions: [ButtonAction]

    init(title: String, message: String, actions: [ButtonAction] = []) {
        self.title = title
        self.message = message
        self.actions = actions
    }

    struct ButtonAction: Equatable, Identifiable {
        let text: String
        let action: () -> Void

        var id: String { text }

        static func == (lhs: ErrorState.ButtonAction, rhs: ErrorState.ButtonAction) -> Bool {
            lhs.text == rhs.text
        }
    }
}

struct ErrorStateView: View {
    let errorState: ErrorState

    @State private var shakeOffset: CGFloat = 0.0

    var body: some View {
        VStack(spacing: 16) {
            // Title with a shake animation
            Text(errorState.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .offset(x: shakeOffset)
                .animation(
                    .default.repeatCount(3, autoreverses: true),
                    value: shakeOffset
                )

            // Message
            Text(errorState.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            // Action buttons
            ForEach(errorState.actions) { action in
                Button(action.text, action: action.action)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
        )
        .onAppear {
            triggerShake()
        }
    }

    private func triggerShake() {
        // Simple shake effect by toggling the offset
        shakeOffset = 10
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            shakeOffset = -10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            shakeOffset = 0
        }
    }
}
