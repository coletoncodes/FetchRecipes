//
//  RecipesResponseHandler.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import Networking

final class RecipesResponseHandler<T: Decodable>: NetworkResponseHandler {
    typealias SuccessResponse = T
    typealias ErrorResponse = EmptyErrorResponse

    let decoder: JSONDecoder

    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    func handleResponse(statusCode: Int, responseData: Data) async throws -> NetworkResponse<T, EmptyErrorResponse> {
        // Handle response based on status code and decode data
        guard statusCode >= 200 && statusCode < 300 else {
            do {
                let errorResponse: ErrorResponse = try decoder.decodeResponse(
                    ErrorResponse.self,
                    from: responseData
                )
                return .errorResponse(errorResponse)
            } catch {
                log("Failed to decode error response with error: \(error)", .error, .networking)
                throw error
            }
        }

        do {
            let response = try decoder.decodeResponse(T.self, from: responseData)
            return .successResponse(response)
        } catch {
            log("Failed to decode error response with error: \(error)", .error, .networking)
            throw error
        }
    }
}
