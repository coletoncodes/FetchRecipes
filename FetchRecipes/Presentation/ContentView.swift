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
                    EmptyView()
                case .loading:
                    ProgressView()
                case let .error(errorState):
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
                case let .loaded(recipes):
                    EmptyView()
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

#Preview {
    RecipeListView()
}
