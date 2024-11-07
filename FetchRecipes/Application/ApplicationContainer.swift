//
//  ApplicationContainer.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation

import Factory
import Foundation
import Networking

public final class ApplicationContainer: SharedContainer {
     public static let shared = ApplicationContainer()
     public let manager = ContainerManager()
}

extension ApplicationContainer {
    var fetchRecipesUseCase: Factory<FetchRecipesUseCase> {
        self { FetchRecipesUseCaseImpl() }
            .cached
    }

    var refreshRecipesUseCase: Factory<RefreshRecipesUseCase> {
        self { RefreshRecipesUseCaseImp() }
            .cached
    }
}
