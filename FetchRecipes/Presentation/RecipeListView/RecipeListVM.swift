//
//  RecipeListVM.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import Foundation

final class MockRecipeListVM: RecipeListVM {
    override func dispatch(_ action: RecipeListVM.Action) {
        // do nothin
    }
}

class RecipeListVM: ObservableObject {
    @Injected(\ApplicationContainer.fetchRecipesUseCase) private var fetchRecipesUseCase
    @Injected(\ApplicationContainer.refreshRecipesUseCase) private var refreshRecipesUseCase

    @Published var viewState: PresentationState = .empty

    enum PresentationState: Equatable {
        case empty
        case loaded([Recipe])
        case loading
        case error(ErrorState)
    }

    enum Action {
        case onAppear
        case refresh
    }

    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            fetchRecipes()
        case .refresh:
            refreshRecipes()
        }
    }

    private func fetchRecipes() {
        viewState = .loading
        Task { @MainActor in
            do {
                let recipes = try await fetchRecipesUseCase.fetchRecipes()
                viewState = recipes.isEmpty ? .empty : .loaded(recipes)
            } catch {
                log("Failed to fetch recipes with error: \(error.localizedDescription)", .error, .viewModel)
                viewState = .error(makeErrorState(message: "Would you like to try again?", retryAction: self.fetchRecipes))
            }
        }
    }

    private func refreshRecipes() {
        viewState = .loading
        Task { @MainActor in
            do {
                let recipes = try await refreshRecipesUseCase.refreshRecipes()
                viewState = recipes.isEmpty ? .empty : .loaded(recipes)
            } catch {
                log("Failed to refresh recipes with error: \(error.localizedDescription)", .error, .viewModel)
                viewState = .error(makeErrorState(message: "Would you like to try again?", retryAction: self.refreshRecipes))
            }
        }
    }

    private func makeErrorState(message: String, retryAction: @escaping () -> Void) -> ErrorState {
        ErrorState(
            title: "Oops! Something went wrong",
            message: message,
            actions: [
                .init(text: "Try Again", action: retryAction),
                .init(text: "Cancel") { [weak self] in
                    self?.viewState = .empty
                }
            ]
        )
    }
}
