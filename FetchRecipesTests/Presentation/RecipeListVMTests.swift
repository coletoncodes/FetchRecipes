//
//  RecipeListVMTests.swift
//  FetchRecipesTests
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
@testable import FetchRecipes
import XCTest

final class MockFetchRecipesUseCase: FetchRecipesUseCase {
    var fetchRecipesStub: (() async throws -> [Recipe])?

    func fetchRecipes() async throws -> [Recipe] {
        guard let fetchRecipesStub else {
            throw TestError.unexpected("fetchRecipesStub not set")
        }

        return try await fetchRecipesStub()
    }
}

final class MockRefreshRecipesUseCase: RefreshRecipesUseCase {
    var refreshRecipesStub: (() async throws -> [Recipe])?

    func refreshRecipes() async throws -> [Recipe] {
        guard let refreshRecipesStub else {
            throw TestError.unexpected("refreshRecipesStub not set")
        }
        return try await refreshRecipesStub()
    }
}

final class RecipeListVMTests: XCTestCase {

    private var mockFetchRecipesUseCase: MockFetchRecipesUseCase!
    private var mockRefreshRecipesUseCase: MockRefreshRecipesUseCase!
    private var sut: RecipeListVM!

    override func setUp() {
        super.setUp()
        ApplicationContainer.shared.reset()

        let mockFetchRecipesUseCase = MockFetchRecipesUseCase()
        let mockRefreshRecipesUseCase = MockRefreshRecipesUseCase()
        ApplicationContainer.shared.refreshRecipesUseCase.register { mockRefreshRecipesUseCase }
        ApplicationContainer.shared.fetchRecipesUseCase.register { mockFetchRecipesUseCase }

        self.mockFetchRecipesUseCase = ApplicationContainer.shared.fetchRecipesUseCase() as? MockFetchRecipesUseCase
        self.mockRefreshRecipesUseCase = ApplicationContainer.shared.refreshRecipesUseCase() as? MockRefreshRecipesUseCase
        sut = RecipeListVM()
    }

    func testOnAppear_withSuccessfulFetch_updatesViewStateToLoaded() async {
        let expectation = expectation(description: "awaiting fetch")
        // Arrange: Set up mock recipes
        let mockRecipe = Recipe(
            cuisine: "Italian",
            name: "Pizza",
            photoURLLarge: URL(string: "https://example.com/large.jpg")!,
            photoURLSmall: URL(string: "https://example.com/small.jpg")!,
            sourceURL: URL(string: "https://example.com")!,
            uuid: "1",
            youtubeURL: URL(string: "https://youtube.com/video")!
        )

        mockFetchRecipesUseCase.fetchRecipesStub = {
            expectation.fulfill()
            return [mockRecipe]
        }

        // Act: Dispatch onAppear action
        sut.dispatch(.onAppear)

        await fulfillment(of: [expectation], timeout: 0.1)
        // Assert: Verify viewState
        await MainActor.run {
            XCTAssertEqual(sut.viewState, .loaded([mockRecipe]))
        }
    }

    func testOnAppear_withEmptyResponse_updatesViewStateToEmpty() async {
        let expectation = expectation(description: "awaiting fetch to return empty")
        mockFetchRecipesUseCase.fetchRecipesStub = {
            expectation.fulfill()
            return []
        }

        sut.dispatch(.onAppear)

        await fulfillment(of: [expectation], timeout: 0.1)
        await MainActor.run {
            XCTAssertEqual(sut.viewState, .empty)
        }
    }

    func testOnAppear_withFetchError_updatesViewStateToError() async {
        let expectation = expectation(description: "awaiting fetch to fail")

        mockFetchRecipesUseCase.fetchRecipesStub = {
            expectation.fulfill()
            throw RecipesRepoError.recipesNotComplete
        }

        sut.dispatch(.onAppear)

        await fulfillment(of: [expectation], timeout: 0.1)
        await MainActor.run {
            if case .error(let errorState) = sut.viewState {
                XCTAssertEqual(errorState.title, "Oops! Something went wrong")
                XCTAssertEqual(errorState.message, "Would you like to try again?")
            } else {
                XCTFail("Expected viewState to be .error")
            }
        }
    }

    func testRefresh_withSuccessfulRefresh_updatesViewStateToLoaded() async {
        let expectation = expectation(description: "awaiting fetch to finish")
        let mockRecipe = Recipe(
            cuisine: "Mexican",
            name: "Tacos",
            photoURLLarge: URL(string: "https://example.com/large.jpg")!,
            photoURLSmall: URL(string: "https://example.com/small.jpg")!,
            sourceURL: URL(string: "https://example.com")!,
            uuid: "2",
            youtubeURL: URL(string: "https://youtube.com/video")!
        )

        mockRefreshRecipesUseCase.refreshRecipesStub = {
            expectation.fulfill()
            return [mockRecipe]
        }

        sut.dispatch(.refresh)

        await fulfillment(of: [expectation], timeout: 0.1)
        await MainActor.run {
            XCTAssertEqual(sut.viewState, .loaded([mockRecipe]))
        }
    }

    func testRefresh_withRefreshError_updatesViewStateToError() async {
        let expectation = expectation(description: "awaiting fetch to fail")

        mockRefreshRecipesUseCase.refreshRecipesStub = {
            expectation.fulfill()
            throw RecipesRepoError.recipesNotComplete
        }

        sut.dispatch(.refresh)


        await fulfillment(of: [expectation], timeout: 0.1)
        await MainActor.run {
            if case .error(let errorState) = sut.viewState {
                XCTAssertEqual(errorState.title, "Oops! Something went wrong")
                XCTAssertEqual(errorState.message, "Would you like to try again?")
            } else {
                XCTFail("Expected viewState to be .error")
            }
        }
    }
}
