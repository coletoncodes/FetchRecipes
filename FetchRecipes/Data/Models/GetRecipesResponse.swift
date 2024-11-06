//
//  GetRecipesResponse.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation

// MARK: - GetRecipesResponse
struct GetRecipesResponse: Decodable {
    let recipes: [RecipeDTO]
}

// MARK: - Recipe
struct RecipeDTO: Decodable {
    let cuisine: String
    let name: String?
    let photoURLLarge, photoURLSmall: String
    let sourceURL: String?
    let uuid: String
    let youtubeURL: String?

    enum CodingKeys: String, CodingKey {
        case cuisine, name
        case photoURLLarge = "photo_url_large"
        case photoURLSmall = "photo_url_small"
        case sourceURL = "source_url"
        case uuid
        case youtubeURL = "youtube_url"
    }
}
