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
    let photoURLLarge, photoURLSmall: String
    let sourceURL: String
    let uuid: String
    let youtubeURL: String

    var id: String { uuid }

    init(
        cuisine: String,
        name: String,
        photoURLLarge: String,
        photoURLSmall: String,
        sourceURL: String,
        uuid: String,
        youtubeURL: String
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
