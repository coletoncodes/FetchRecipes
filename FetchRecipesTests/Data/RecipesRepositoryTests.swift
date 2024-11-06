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

    func testFetchRecipesFiltersInvalidURLs() async throws {
        // Arrange: Create mock RecipeDTOs with both valid and invalid URLs
        let validRecipeDTO = RecipeDTO(
            cuisine: "Italian",
            name: "Valid Recipe",
            photoURLLarge: "https://example.com/large.jpg",
            photoURLSmall: "https://example.com/small.jpg",
            sourceURL: "https://example.com",
            uuid: "1",
            youtubeURL: "https://youtube.com/video"
        )

        let invalidRecipeDTO = RecipeDTO(
            cuisine: "French",
            name: "Invalid Recipe",
            photoURLLarge: "",  // Invalid URL format
            photoURLSmall: "https://example.com/small.jpg",
            sourceURL: "https://example.com",
            uuid: "2",
            youtubeURL: "https://youtube.com/video"
        )

        // Arrange: Set up the stub to return both valid and invalid RecipeDTOs
        mockRecipesRequester.getRecipesStub = { [validRecipeDTO, invalidRecipeDTO] }

        // Act: Attempt to fetch recipes, which should filter out the invalid one
        let recipes = try await sut.getRecipes()

        // Assert: Ensure only the valid recipe is returned
        XCTAssertEqual(recipes.count, 1, "Expected only one valid recipe to be returned.")
        XCTAssertEqual(recipes.first?.uuid, validRecipeDTO.uuid, "The returned recipe should be the valid one.")
        XCTAssertEqual(recipes.first?.name, validRecipeDTO.name, "The name of the returned recipe should match the valid recipe.")
        XCTAssertEqual(recipes.first?.cuisine, validRecipeDTO.cuisine, "Cuisine of the returned recipe should match the valid recipe.")
        XCTAssertNotNil(recipes.first?.photoURLLarge, "Valid recipe should have a non-nil large photo URL.")
        XCTAssertNotNil(recipes.first?.photoURLSmall, "Valid recipe should have a non-nil small photo URL.")
        XCTAssertNotNil(recipes.first?.sourceURL, "Valid recipe should have a non-nil source URL.")
        XCTAssertNotNil(recipes.first?.youtubeURL, "Valid recipe should have a non-nil YouTube URL.")
    }

    func testFetchRecipesCaching() async throws {
        // Mock recipe data
        let recipeDTO = RecipeDTO(
            cuisine: "Italian",
            name: "Cached Recipe",
            photoURLLarge: "https://example.com/large.jpg",
            photoURLSmall: "https://example.com/small.jpg",
            sourceURL: "https://example.com",
            uuid: "1",
            youtubeURL: "https://youtube.com/video"
        )

        mockRecipesRequester.getRecipesStub = { [recipeDTO] }

        // Initial fetch should store in cache
        let recipesFirstLoad = try await sut.getRecipes(forceRefresh: false)
        XCTAssertEqual(recipesFirstLoad.count, 1)
        XCTAssertEqual(recipesFirstLoad.first?.name, "Cached Recipe")

        // Modify stub to simulate network change
        mockRecipesRequester.getRecipesStub = {
            [
                RecipeDTO(
                    cuisine: "Italian",
                    name: "New Recipe",
                    photoURLLarge: "https://example.com/new_large.jpg",
                    photoURLSmall: "https://example.com/new_small.jpg",
                    sourceURL: "https://example.com",
                    uuid: "2",
                    youtubeURL: "https://youtube.com/new_video"
                )
            ]
        }
        
        // Second fetch without refresh should return cached data
        let recipesCached = try await sut.getRecipes(forceRefresh: false)
        XCTAssertEqual(recipesCached.count, 1)
        XCTAssertEqual(recipesCached.first?.name, "Cached Recipe", "Expected cached recipe to be returned without refresh.")

        // Fetch with refresh should return new data
        let recipesAfterRefresh = try await sut.getRecipes(forceRefresh: true)
        XCTAssertEqual(recipesAfterRefresh.count, 1)
        XCTAssertEqual(recipesAfterRefresh.first?.name, "New Recipe", "Expected new recipe to be returned after forced refresh.")
    }
}
