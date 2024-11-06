//
//  FetchRecipesUseCase.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import Factory

protocol FetchRecipesUseCase {
    func fetchRecipes() async throws -> [Recipe]
}

final class FetchRecipesUseCaseImpl: FetchRecipesUseCase {
    @Injected(\DataContainer.recipesRepository) private var recipesRepo

    func fetchRecipes() async throws -> [Recipe] {
        do {
            return try await recipesRepo.getRecipes(forceRefresh: false)
        } catch {
            log("failed to fetch recipes with error: \(error)", .error, .useCase)
            throw error
        }
    }
}
