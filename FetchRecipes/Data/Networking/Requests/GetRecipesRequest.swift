//
//  GetRecipesRequest.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Networking
import Foundation

struct GetRecipesRequest: NetworkRequest {
    typealias SuccessResponse = GetRecipesResponse
    typealias ErrorResponse = EmptyErrorResponse

    var body: (any Encodable)? = nil

    var method: HTTPMethod { .GET }

    var path: String { "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json" }

    var headers: [NetworkHeader] { [] }
}
