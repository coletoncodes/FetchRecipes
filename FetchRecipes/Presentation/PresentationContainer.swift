//
//  PresentationContainer.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import Foundation
import Networking

public final class PresentationContainer: SharedContainer {
     public static let shared = PresentationContainer()
     public let manager = ContainerManager()
}

extension PresentationContainer {
    var recipeListVM: Factory<RecipeListVM> {
        self { RecipeListVM() }
            .cached
            .context(.test, .preview) {
                MockRecipeListVM()
            }
    }
}
