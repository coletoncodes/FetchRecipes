//
//  RecipeListVMTests.swift
//  FetchRecipesTests
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
@testable import FetchRecipes
import Combine
import XCTest

final class RecipeListVMTests: XCTestCase {

    private var mockFetchRecipesUseCase: MockFetchRecipesUseCase!
    private var mockRefreshRecipesUseCase: MockRefreshRecipesUseCase!
    private var sut: RecipeListVM!
    private var cancellables = Set<AnyCancellable>()

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

        sut.dispatch(.onAppear)

        await fulfillment(of: [expectation], timeout: 0.1)
        await MainActor.run {
            if case .loaded(let loadedState) = sut.viewState {
                XCTAssertEqual(loadedState.recipes, [mockRecipe])
                XCTAssertEqual(loadedState.cuisinesList, ["Italian"])
            } else {
                XCTFail("Expected viewState to be .loaded")
            }
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
            throw TestError.expected
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
            if case .loaded(let loadedState) = sut.viewState {
                XCTAssertEqual(loadedState.recipes, [mockRecipe])
                XCTAssertEqual(loadedState.cuisinesList, ["Mexican"])
            } else {
                XCTFail("Expected viewState to be .loaded")
            }
        }
    }

    func testSelectCuisine_withCuisineFilter_updatesFilteredRecipes() async {
            let expectation = expectation(description: "Filtered recipes based on selected cuisine")

            let mockRecipes = [
                Recipe(
                    cuisine: "Italian",
                    name: "Pizza",
                    photoURLLarge: URL(string: "https://example.com/large.jpg")!,
                    photoURLSmall: URL(string: "https://example.com/small.jpg")!,
                    sourceURL: URL(string: "https://example.com")!,
                    uuid: "1",
                    youtubeURL: URL(string: "https://youtube.com/video")!
                ),
                Recipe(
                    cuisine: "Mexican",
                    name: "Tacos",
                    photoURLLarge: URL(string: "https://example.com/large.jpg")!,
                    photoURLSmall: URL(string: "https://example.com/small.jpg")!,
                    sourceURL: URL(string: "https://example.com")!,
                    uuid: "2",
                    youtubeURL: URL(string: "https://youtube.com/video")!
                )
            ]

            mockFetchRecipesUseCase.fetchRecipesStub = { mockRecipes }

            sut.$viewState
                .sink { state in
                    if case .loaded(let loadedState) = state, loadedState.recipes.first?.cuisine == "Mexican" {
                        expectation.fulfill()
                    }
                }
                .store(in: &cancellables)

            sut.dispatch(.onAppear)
            sut.dispatch(.selectCuisine("Mexican"))

            await fulfillment(of: [expectation], timeout: 1.0)

            await MainActor.run {
                if case .loaded(let loadedState) = sut.viewState {
                    XCTAssertEqual(loadedState.recipes.count, 1)
                    XCTAssertEqual(loadedState.recipes.first?.cuisine, "Mexican")
                } else {
                    XCTFail("Expected viewState to be .loaded with filtered recipes")
                }
            }
        }
}
