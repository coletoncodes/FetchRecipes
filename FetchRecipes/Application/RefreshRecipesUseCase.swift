//
//  RefreshRecipesUseCase.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import Foundation

protocol RefreshRecipesUseCase {
    func refreshRecipes() async throws -> [Recipe]
}

final class RefreshRecipesUseCaseImp: RefreshRecipesUseCase {
    @Injected(\DataContainer.recipesRepository) private var recipesRepo

    func refreshRecipes() async throws -> [Recipe] {
        do {
            return try await recipesRepo.getRecipes(forceRefresh: true)
        } catch {
            log("failed to refresh recipes with error: \(error)", .error, .useCase)
            throw error
        }
    }
}
