//
//  RecipesRepositoryTests.swift
//  FetchRecipesTests
//
//  Created by Coleton Gorecke on 11/6/24.
//

@testable import FetchRecipes
import Networking
import XCTest

final class RecipesRepositoryTests: XCTestCase {
    private var mockRecipesRequester: MockRecipesRequester!
    private var sut: RecipesRepo!

    override func setUp() {
        super.setUp()
        DataContainer.shared.reset()

        let mockRequester = MockRecipesRequester()
        DataContainer.shared.recipesNetworkRequester.register { mockRequester }

        self.mockRecipesRequester = DataContainer.shared.recipesNetworkRequester() as? MockRecipesRequester
        sut = RecipesRepo()
    }

    func testGetRecipesSuccess() async throws {
        // Arrange: Provide complete data for success
        let mockRecipeDTO = RecipeDTO(
            cuisine: "Italian",
            name: "Pizza",
            photoURLLarge: "https://example.com/large.jpg",
            photoURLSmall: "https://example.com/small.jpg",
            sourceURL: "https://example.com",
            uuid: "1",
            youtubeURL: "https://youtube.com/video"
        )

        mockRecipesRequester.getRecipesStub = { [mockRecipeDTO] }

        // Act
        let recipes = try await sut.getRecipes()

        // Assert
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.name, "Pizza")
    }

    func testGetRecipesIncompleteData() async throws {
        // Arrange: Provide incomplete data to simulate a malformed response
        let incompleteRecipeDTO = RecipeDTO(
            cuisine: "Italian",
            name: "Pizza",
            photoURLLarge: nil,  // Missing required field
            photoURLSmall: "https://example.com/small.jpg",
            sourceURL: "https://example.com",
            uuid: "1",
            youtubeURL: "https://youtube.com/video"
        )

        mockRecipesRequester.getRecipesStub = { [incompleteRecipeDTO] }

        // Act & Assert
        do {
            _ = try await sut.getRecipes()
            XCTFail("Expected to throw RecipesRepoError.recipesNotComplete")
        } catch let error as RecipesRepoError {
            XCTAssertEqual(error, .recipesNotComplete)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testGetRecipesEmptyData() async throws {
        // Arrange: Return an empty array
        mockRecipesRequester.getRecipesStub = { [] }

        // Act
        let recipes = try await sut.getRecipes()

        // Assert
        XCTAssertTrue(recipes.isEmpty, "Expected no recipes to be returned.")
    }

    func testGetRecipesThrowsError() async throws {
        // Arrange: Simulate network error
        mockRecipesRequester.getRecipesStub = {
            throw URLError(.notConnectedToInternet)
        }

        // Act & Assert
        do {
            _ = try await sut.getRecipes()
            XCTFail("Expected network error to be thrown")
        } catch {
            // Check that the error was passed through correctly
            XCTAssertTrue(error is URLError)
        }
    }
}
