//
//  RecipesNetworkRequester.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import Foundation
import Networking

protocol RecipesNetworkRequesting {
    func getRecipes() async throws -> [RecipeDTO]
}

final class RecipesNetworkRequester: RecipesNetworkRequesting {
    private let getRecipesResponseHandler: RecipesResponseHandler<GetRecipesRequest.SuccessResponse>
    @Injected(\DataContainer.networkRequester) private var networkRequester

    init() {
        self.getRecipesResponseHandler = DataContainer.shared.makeRecipesResponseHandler(successResponse: GetRecipesRequest.SuccessResponse.self).resolve()
    }

    func getRecipes() async throws -> [RecipeDTO] {
        do {
            let networkResponse = try await networkRequester.performRequest(GetRecipesRequest(), responseHandler: getRecipesResponseHandler)
            switch networkResponse {
            case let .successResponse(response):
                return response.recipes
            case .errorResponse:
                log("Got error response, unable to return recipes", .error, .networking)
                throw RecipesNetworkRequesterError.failedToGetRecipes
            }
        } catch {
            log("Failed to get recipes with error: \(error)", .error, .networking)
            throw RecipesNetworkRequesterError.failedToGetRecipes
        }
    }
}

enum RecipesNetworkRequesterError: Error, LocalizedError {
    case failedToGetRecipes

    var errorDescription: String? {
        switch self {
        case .failedToGetRecipes:
            return "Unable to retrieve recipes at this time. Please try again later."
        }
    }
}
