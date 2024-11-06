//
//  RecipesResponseHandlerTests.swift
//  FetchRecipesTests
//
//  Created by Coleton Gorecke on 11/6/24.
//

@testable import FetchRecipes
import Networking
import XCTest

final class RecipesResponseHandlerTests: XCTestCase {

    var handler: RecipesResponseHandler<GetRecipesResponse>!
    var mockDecoder: MockJSONDecoder!

    override func setUpWithError() throws {
        mockDecoder = MockJSONDecoder()
        handler = RecipesResponseHandler<GetRecipesResponse>(decoder: mockDecoder)
    }

    override func tearDownWithError() throws {
        handler = nil
        mockDecoder = nil
        try super.tearDownWithError()
    }

    // Test handling a successful response with only required data
    func testSuccessfulResponse_RequiredDataOnly() async throws {
        let mockRecipe = RecipeDTO(cuisine: "Italian", name: "Pizza", photoURLLarge: "https://example.com/large.jpg", photoURLSmall: "https://example.com/small.jpg", sourceURL:  "https://example.com", uuid: "1", youtubeURL: "https://youtube.com/video")
        let mockRecipeResponse = GetRecipesResponse(recipes: [mockRecipe])

        let mockRecipeData = try JSONEncoder().encode(mockRecipe)

        mockDecoder.decodeClosure = { data in
            XCTAssertEqual(data, mockRecipeData)
            return mockRecipeResponse
        }

        let statusCode = 200
        let response = try await handler.handleResponse(statusCode: statusCode, responseData: mockRecipeData)

        switch response {
        case .successResponse(let recipesResponse):
            let recipe = recipesResponse.recipes.first
            XCTAssertEqual(recipesResponse.recipes.count, 1)
            XCTAssertEqual(recipe?.name, mockRecipe.name)
            XCTAssertEqual(recipe?.cuisine, mockRecipe.cuisine)
            XCTAssertEqual(recipe?.photoURLLarge, mockRecipe.photoURLLarge)
            XCTAssertEqual(recipe?.photoURLSmall, mockRecipe.photoURLSmall)
            XCTAssertEqual(recipe?.sourceURL, mockRecipe.sourceURL)
            XCTAssertEqual(recipe?.youtubeURL, mockRecipe.youtubeURL)
        default:
            XCTFail("Expected a successful response.")
        }
    }

    // Test handling a successful response with all optional data
    func testSuccessfulResponse_AllDataFieldsPresent() async throws {
        let mockRecipe = RecipeDTO(cuisine: "Italian", name: "Pizza", photoURLLarge: "https://example.com/large.jpg", photoURLSmall: "https://example.com/small.jpg", sourceURL:  "https://example.com", uuid: "1", youtubeURL: "https://youtube.com/video")
        let mockRecipeResponse = GetRecipesResponse(recipes: [mockRecipe])

        let mockRecipeData = try JSONEncoder().encode(mockRecipe)

        mockDecoder.decodeClosure = { data in
            XCTAssertEqual(data, mockRecipeData)
            return mockRecipeResponse
        }

        let statusCode = 200
        let response = try await handler.handleResponse(statusCode: statusCode, responseData: mockRecipeData)

        switch response {
        case .successResponse(let recipesResponse):
            XCTAssertEqual(recipesResponse.recipes.count, 1)
            let recipe = recipesResponse.recipes.first
            XCTAssertEqual(recipe?.name, mockRecipe.name)
            XCTAssertEqual(recipe?.cuisine, mockRecipe.cuisine)
            XCTAssertEqual(recipe?.photoURLLarge, mockRecipe.photoURLLarge)
            XCTAssertEqual(recipe?.photoURLSmall, mockRecipe.photoURLSmall)
            XCTAssertEqual(recipe?.sourceURL, mockRecipe.sourceURL)
            XCTAssertEqual(recipe?.youtubeURL, mockRecipe.youtubeURL)
        default:
            XCTFail("Expected a successful response.")
        }
    }

    // Test handling an error response with decoding failure
    func testErrorResponse_DecodingFailure() async throws {
        let invalidJsonData = "{}".data(using: .utf8)!
        let statusCode = 400

        // Configure the mock decoder to throw a decoding error when trying to decode the error response
        mockDecoder.decodeClosure = { _ in
            throw NetworkRequesterError.decodingError("Failed to decode error response")
        }

        do {
            // Attempt to handle response and expect a decoding error
            _ = try await handler.handleResponse(statusCode: statusCode, responseData: invalidJsonData)
            XCTFail("Expected decoding to throw an error.")
        } catch let error as NetworkRequesterError {
            switch error {
            case .decodingError(let message):
                XCTAssertEqual(message, "Failed to decode error response")
            default:
                XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // Test handling an error response when optional fields are missing
    func testErrorResponse() async throws {
        let mockData = "{}".data(using: .utf8)!  // Minimal error response
        let statusCode = 400
        let mockErrorResponse = EmptyErrorResponse()

        mockDecoder.decodeClosure = { data in
            XCTAssertEqual(data, mockData)
            return mockErrorResponse
        }

        do {
            let response = try await handler.handleResponse(statusCode: statusCode, responseData: mockData)
            switch response {
            case .successResponse:
                XCTFail("Expected error response but got a success")
            case .errorResponse(let errorResponse):
                XCTAssertTrue(type(of: errorResponse) == EmptyErrorResponse.self)
            }
        } catch {
            XCTFail("Expected no error but caught one: \(error)")
        }
    }
}
