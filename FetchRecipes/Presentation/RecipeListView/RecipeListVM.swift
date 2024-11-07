//
//  RecipeListVM.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import Foundation

class RecipeListVM: ObservableObject {
    @Injected(\ApplicationContainer.fetchRecipesUseCase) private var fetchRecipesUseCase
    @Injected(\ApplicationContainer.refreshRecipesUseCase) private var refreshRecipesUseCase

    @Published var viewState: PresentationState = .empty
    @Published var selectedCuisine: String? = nil  // Track selected cuisine for filtering

    private var allRecipes: [Recipe] = []
    private var allCuisines: [String] {
        allRecipes.cuisinesList
    }

    struct LoadedState: Equatable {
        let recipes: [Recipe]
        let cuisinesList: [String]
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
                allRecipes = recipes  // Store the full list of recipes
                applyFilter()         // Apply filter if any cuisine is selected
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
                allRecipes = recipes  // Store the full list of recipes
                applyFilter()         // Apply filter if any cuisine is selected
            } catch {
                log("Failed to refresh recipes with error: \(error.localizedDescription)", .error, .viewModel)
                viewState = .error(makeErrorState(message: "Would you like to try again?", retryAction: self.refreshRecipes))
            }
        }
    }

    private func applyFilter() {
        // Filter recipes based on selected cuisine or show all
        let filteredRecipes: [Recipe]
        if let cuisine = selectedCuisine, !cuisine.isEmpty {
            filteredRecipes = allRecipes.filter { $0.cuisine == cuisine }
        } else {
            filteredRecipes = allRecipes  // Show all recipes if no cuisine is selected
        }

        viewState = filteredRecipes.isEmpty ? .empty : .loaded(LoadedState(recipes: filteredRecipes, cuisinesList: self.allCuisines))
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
