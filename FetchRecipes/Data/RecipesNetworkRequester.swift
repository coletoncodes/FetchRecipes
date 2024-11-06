//
//  RecipesNetworkRequester.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import Networking

protocol RecipesNetworkRequesting {
    func getRecipes() async throws -> NetworkResponse<[RecipeDTO], EmptyErrorResponse>
}

final class RecipesNetworkRequester: RecipesNetworkRequesting {
//    @Injected(\.networkRequesting) private var requester
//    @Injected(\.jsonDecoder) private var decoder

//    func getActivities() async throws -> NetworkResponse<[ActivityDTO], SimpleErrorResponse> {
//        do {
//            let responseHandler = ActivitiesResponseHandler<GetActivitiesRequest.SuccessResponse>(decoder: decoder)
//            return try await requester.performRequest(GetActivitiesRequest(), responseHandler: responseHandler)
//        } catch {
//            log("Failed to handle request with error: \(error)", .error, .networking)
//            throw error
//        }
//    }

    func getRecipes() async throws -> NetworkResponse<[RecipeDTO], EmptyErrorResponse> {
        fatalError("Unimplemented")
    }
}
