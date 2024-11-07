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
                case let .loaded(loadedState):
                    // Cuisine Picker
                    CuisinesList(
                        selectedCuisine: vm.selectedCuisine,
                        onSelect: { vm.dispatch(.selectCuisine($0)) },
                        cuisines: loadedState.cuisinesList
                    )

                    // Recipe List
                    RecipeList(recipes: loadedState.recipes)
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

import Kingfisher

fileprivate extension RecipeListView {

    struct CuisinesList: View {
        let selectedCuisine: String?
        let onSelect: (String?) -> Void
        let cuisines: [String]
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button(action: {
                        onSelect(nil)
                    }) {
                        Text("All")
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(selectedCuisine == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCuisine == nil ? .white : .primary)
                            .cornerRadius(8)
                    }

                    ForEach(cuisines, id: \.self) { cuisine in
                        Button(action: {
                            onSelect(cuisine)
                        }) {
                            Text(cuisine)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(selectedCuisine == cuisine ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedCuisine == cuisine ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                .safeAreaInset(edge: .bottom) {
                    Rectangle()
                        .tint(.primary)
                        .frame(width: .infinity, height: 2)
                }
            }
        }
    }

    struct RecipeList: View {
        let recipes: [Recipe]

        var body: some View {
            List(recipes, id: \.uuid) { recipe in
                RecipeCell(recipe: recipe)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .padding(.vertical)
            }
            .listStyle(.plain) // Plain list style for minimalism
        }
    }

    struct RecipeCell: View {
        let recipe: Recipe

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                // Recipe Image
                KFImage(recipe.photoURLSmall)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()

                // Recipe Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(recipe.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Link("Source", destination: recipe.sourceURL)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 2)
            )
            .padding(.horizontal)
        }
    }
}

// MARK: - Previews
#if DEBUG
// Empty View
#Preview("Empty State") {
    let vm = PresentationContainer.shared.recipeListVM()
    vm.viewState = .empty
    return RecipeListView()
}

// Loading View
#Preview("Loading State") {
    let vm = PresentationContainer.shared.recipeListVM()
    vm.viewState = .loading
    return RecipeListView()
}

// Error View
#Preview("Error State") {
    let vm = PresentationContainer.shared.recipeListVM()
    let errorState = ErrorState(title: "Error", message: "Something went wrong", actions: [.init(text: "Retry", action: {})])
    vm.viewState = .error(errorState)
    return RecipeListView()
}

// Loaded View
#Preview("Loaded State") {
    let vm = PresentationContainer.shared.recipeListVM()
    vm.viewState = .loaded(.init(recipes: Recipe.previewData))
    return RecipeListView()
}
#endif
