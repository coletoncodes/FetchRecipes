//
//  EmptyStateView.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import SwiftUI

struct EmptyStateView: View {
    let systemImageName: String = "exclamationmark.warninglight.fill"
    let title: String = "Nothing to see here..."
    
    @State private var animateImage = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with animation
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.secondary)
                .scaleEffect(animateImage ? 1.0 : 0.8) // Starting scale for animation
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: animateImage)
                .onAppear {
                    animateImage = true // Trigger animation on appear
                }
            
            // Title
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .padding(.horizontal)
    }
}
