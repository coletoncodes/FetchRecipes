//
//  FetchRecipesUseCaseTests.swift
//  FetchRecipesTests
//
//  Created by Coleton Gorecke on 11/6/24.
//

import XCTest
import Factory
@testable import FetchRecipes

final class FetchRecipesUseCaseTests: XCTestCase {
    private var mockRecipesRepo: MockRecipesRepository!
    private var sut: FetchRecipesUseCaseImpl!

    override func setUp() {
        super.setUp()
        DataContainer.shared.reset()

        let mockRecipesRepo = MockRecipesRepository()
        DataContainer.shared.recipesRepository.register { mockRecipesRepo }

        self.mockRecipesRepo = DataContainer.shared.recipesRepository() as? MockRecipesRepository
        sut = FetchRecipesUseCaseImpl()
    }

    func testFetchRecipesSuccess() async throws {
        // Arrange: Stub the repository to return a list of recipes
        let mockRecipe = Recipe(
            cuisine: "Italian",
            name: "Pizza",
            photoURLLarge: URL(string: "https://example.com/large.jpg")!,
            photoURLSmall: URL(string: "https://example.com/small.jpg")!,
            sourceURL: URL(string: "https://example.com")!,
            uuid: "1",
            youtubeURL: URL(string: "https://youtube.com/video")!
        )

        mockRecipesRepo.getRecipesStub = { forceRefresh in
            XCTAssertFalse(forceRefresh)
            return [mockRecipe]
        }

        // Act: Call the use case
        let recipes = try await sut.fetchRecipes()

        // Assert: Check if the result matches the expected output
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first, mockRecipe)
    }

    func testFetchRecipesFailure() async throws {
        // Arrange: Set the stub to throw an error
        mockRecipesRepo.getRecipesStub = { _ in throw TestError.expected }

        // Act and Assert: Call the use case and verify it throws the expected error
        do {
            _ = try await sut.fetchRecipes()
            XCTFail("Expected fetchRecipes to throw an error")
        } catch TestError.expected {
            // Expected error, test passes
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
