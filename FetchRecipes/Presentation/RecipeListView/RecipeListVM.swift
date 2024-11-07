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
    @Published var selectedCuisine: String? = nil  // Track selected cuisine for filtering

    struct LoadedState: Equatable {
        let recipes: [Recipe]

        var cuisinesList: [String] {
            recipes.cuisinesList
        }
    }

    enum PresentationState: Equatable {
        case empty
        case loaded(LoadedState)
        case loading
        case error(ErrorState)
    }

    enum Action {
        case onAppear
        case refresh
        case selectCuisine(String?)
    }

    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            fetchRecipes()
        case .refresh:
            refreshRecipes()
        case .selectCuisine(let cuisine):
            selectedCuisine = cuisine
            applyFilter()  // Filter recipes based on selected cuisine
        }
    }

    private func fetchRecipes() {
        viewState = .loading
        Task { @MainActor in
            do {
                let recipes = try await fetchRecipesUseCase.fetchRecipes()
                viewState = recipes.isEmpty ? .empty : .loaded(LoadedState(recipes: recipes))
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
                viewState = recipes.isEmpty ? .empty : .loaded(LoadedState(recipes: recipes))
            } catch {
                log("Failed to refresh recipes with error: \(error.localizedDescription)", .error, .viewModel)
                viewState = .error(makeErrorState(message: "Would you like to try again?", retryAction: self.refreshRecipes))
            }
        }
    }

    private func applyFilter() {
        guard case .loaded(let loadedState) = viewState else { return }
        let recipes = loadedState.recipes

        Task { @MainActor in
            // Filter recipes based on selected cuisine or show all
            if let cuisine = selectedCuisine, !cuisine.isEmpty {
                let filteredRecipes = recipes.filter { $0.cuisine == cuisine }
                viewState = .loaded(LoadedState(recipes: filteredRecipes))
            } else {
                viewState = .loaded(loadedState)
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

extension Array where Element == Recipe {
    /// Returns a dictionary where keys are unique cuisines and values are arrays of recipes in that cuisine.
    var cuisinesDictionary: [String: [Recipe]] {
        self.reduce(into: [:]) { dictionary, recipe in
            dictionary[recipe.cuisine, default: []].append(recipe)
        }
    }

    /// Returns a list of unique cuisines in alphabetical order from the dictionary of cuisines.
    var cuisinesList: [String] {
        cuisinesDictionary.keys.sorted()
    }
}
