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
            log("Returning cached recipes", .debug, .repository)
            return cachedRecipes
        }

        log("Fetching recipes..", .debug, .repository)
        do {
            // Fetch and map the recipes
            let recipeDTOs = try await recipesNetworkRequester.getRecipes()
            let recipes = recipeDTOs.toRecipes()

            // Cache the result if all recipes are valid
            self.cachedRecipes = recipes
            return recipes
        } catch {
            log("Failed to fetch recipes: \(error)", .error, .repository)
            throw error
        }
    }
}

extension Array where Element == RecipeDTO {
    /// Maps `RecipeDTO` array to `[Recipe]`, filtering out any items with invalid URLs.
    func toRecipes() -> [Recipe] {
        self.compactMap { dto -> Recipe? in
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
                // Log invalid URL if needed and skip this entry
                log("Invalid URL found in RecipeDTO with UUID \(dto.uuid)", .error, .repository)
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
    }
}
