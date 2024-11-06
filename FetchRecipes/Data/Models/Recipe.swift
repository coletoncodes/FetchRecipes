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
