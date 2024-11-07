//
//  Recipe.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation

struct Recipe: Identifiable, Equatable {
    let cuisine: String
    let name: String
    let photoURLLarge, photoURLSmall: URL
    let sourceURL: URL
    let uuid: String
    let youtubeURL: URL

    var id: String { uuid }

    init(
        cuisine: String,
        name: String,
        photoURLLarge: URL,
        photoURLSmall: URL,
        sourceURL: URL,
        uuid: String,
        youtubeURL: URL
    ) {
        self.cuisine = cuisine
        self.name = name
        self.photoURLLarge = photoURLLarge
        self.photoURLSmall = photoURLSmall
        self.sourceURL = sourceURL
        self.uuid = uuid
        self.youtubeURL = youtubeURL
    }
}

#if DEBUG
extension Recipe {
    static var previewData: [Recipe] {
        guard let url = Bundle.main.url(forResource: "preview-recipes", withExtension: "json") else {
            fatalError("failed to load from resource")
        }

        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try! decoder.decode(GetRecipesResponse.self, from: data).recipes.toRecipes()
    }
}
#endif
