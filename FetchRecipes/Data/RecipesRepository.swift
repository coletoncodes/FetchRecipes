//
//  RecipesRepository.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import Foundation

protocol RecipesRepository {
    func getRecipes() async throws -> [Recipe]
}

final class RecipesRepo: RecipesRepository {
    @Injected(\DataContainer.recipesNetworkRequester) private var recipesNetworkRequester

    func getRecipes() async throws -> [Recipe] {
        do {
            let recipeDTOS = try await recipesNetworkRequester.getRecipes()

            let recipes = recipeDTOS.compactMap { dto -> Recipe? in
                guard
                    let photoURLLarge = dto.photoURLLarge,
                    let photoURLSmall = dto.photoURLSmall,
                    let sourceURL = dto.sourceURL,
                    let youtubeURL = dto.youtubeURL
                else {
                    return nil
                }

                return Recipe(
                    cuisine: dto.cuisine,
                    name: dto.name,
                    photoURLLarge: photoURLLarge,
                    photoURLSmall: photoURLSmall,
                    sourceURL: sourceURL,
                    uuid: dto.uuid,
                    youtubeURL: youtubeURL
                )
            }

            // Requirements, if not complete (malformed) don't return any.
            guard recipes.count == recipeDTOS.count else {
                throw RecipesRepoError.recipesNotComplete
            }

            return recipes
        } catch {
            log("Failed to fetch recipes: \(error)", .error, .networking)
            throw error
        }
    }
}

enum RecipesRepoError: Error {
    case recipesNotComplete
}
