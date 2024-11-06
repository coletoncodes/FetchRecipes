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

    var body: some View {
        VStack {
            Text(errorState.title)
                .font(.title)

            Text(errorState.message)
                .font(.body)

            HStack {
                ForEach(errorState.actions) {
                    Button($0.text, action: $0.action)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        }
    }
}
