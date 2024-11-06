//
//  RecipeListView.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import SwiftUI

struct RecipeListView: View {
    @InjectedObject(\PresentationContainer.recipeListVM) private var vm

    var body: some View {
        NavigationStack {
            VStack {
                switch vm.viewState {
                case .empty:
                    EmptyStateView()
                case .loading:
                    ProgressView()
                case let .error(errorState):
                    ErrorStateView(errorState: errorState)
                case let .loaded(recipes):
                    List(recipes) {
                        Text($0.name)
                    }
                }
            }
            .padding()
            .navigationTitle("Recipes")
        }
        .onAppear {
            vm.dispatch(.onAppear)
        }
    }
}

// Empty View
#Preview {
    let vm = PresentationContainer.shared.recipeListVM()
    vm.viewState = .empty
    return RecipeListView()
}

// Loading View
#Preview {
    let vm = PresentationContainer.shared.recipeListVM()
    vm.viewState = .loading
    return RecipeListView()
}

// Error View
#Preview {
    let vm = PresentationContainer.shared.recipeListVM()
    let errorState = ErrorState(title: "Error", message: "Something went wrong")
    vm.viewState = .error(errorState)
    return RecipeListView()
}

// Loaded View
#Preview {
    let vm = PresentationContainer.shared.recipeListVM()
    let errorState = ErrorState(title: "Error", message: "Something went wrong")
    vm.viewState = .loaded(Recipe.previewData)
    return RecipeListView()
}
