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
    func getRecipes() async throws -> NetworkResponse<GetRecipesRequest.SuccessResponse, EmptyErrorResponse>
}

final class RecipesNetworkRequester: RecipesNetworkRequesting {
    private let getRecipesResponseHandler: RecipesResponseHandler<GetRecipesRequest.SuccessResponse>
    @Injected(\DataContainer.networkRequester) private var networkRequester

    init() {
        self.getRecipesResponseHandler = DataContainer.shared.makeRecipesResponseHandler(successResponse: GetRecipesRequest.SuccessResponse.self).resolve()
    }

    func getRecipes() async throws -> NetworkResponse<GetRecipesRequest.SuccessResponse, EmptyErrorResponse> {
        do {
            return try await networkRequester.performRequest(GetRecipesRequest(), responseHandler: getRecipesResponseHandler)
        } catch {
            log("Failed to get recipes with error: \(error)", .error, .networking)
            throw error
        }
    }
}
