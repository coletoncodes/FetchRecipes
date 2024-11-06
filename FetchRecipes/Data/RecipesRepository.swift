//
//  RecipesRepository.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import Foundation

protocol RecipesRepository {
    func getRecipes(forceRefresh: Bool) async throws -> [Recipe]
}

final class RecipesRepo: RecipesRepository {
    @Injected(\DataContainer.recipesNetworkRequester) private var recipesNetworkRequester

    var cachedRecipes: [Recipe]?  // In-memory cache

    func getRecipes(forceRefresh: Bool = false) async throws -> [Recipe] {
        // Return cached recipes if available and not forcing a refresh
        if let cachedRecipes = cachedRecipes, !forceRefresh {
            return cachedRecipes
        }

        // Otherwise, fetch recipes from the network
        do {
            let recipeDTOs = try await recipesNetworkRequester.getRecipes()
            let recipes = recipeDTOs.compactMap { dto -> Recipe? in
                // Validate all necessary URLs
                guard
                    let photoURLLargeString = dto.photoURLLarge,
                    let photoURLSmallString = dto.photoURLSmall,
                    let sourceURLString = dto.sourceURL,
                    let youtubeURLString = dto.youtubeURL,
                    let photoURLLarge = URL(string: photoURLLargeString),
                    let photoURLSmall = URL(string: photoURLSmallString),
                    let sourceURL = URL(string: sourceURLString),
                    let youtubeURL = URL(string: youtubeURLString)
                else {
                    // Skip this entry if any data is invalid (nil)
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

            // Cache the result if all recipes are valid
            guard recipes.count == recipeDTOs.count else {
                throw RecipesRepoError.recipesNotComplete
            }
            self.cachedRecipes = recipes  // Store in cache
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
