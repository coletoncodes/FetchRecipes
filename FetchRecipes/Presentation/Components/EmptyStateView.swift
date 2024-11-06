//
//  EmptyStateView.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import SwiftUI

struct EmptyStateView: View {
    private let systemImageName = "hand.raised.square.fill"
    private let title = "Nothing to see here.."
    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView(title, systemImage: systemImageName, description: nil)
        } else {
            VStack(spacing: 10) {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.secondary)

                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.systemGray6).cornerRadius(12))
            .shadow(radius: 5)
        }
    }
}
