//
//  ErrorState.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation

/// An encapsulation on a collection of data to populate the error with.
struct ErrorState {
    let title: String
    let message: String
    let actions: [ButtonAction]

    struct ButtonAction {
        let text: String
        let action: () -> Void
    }
}
