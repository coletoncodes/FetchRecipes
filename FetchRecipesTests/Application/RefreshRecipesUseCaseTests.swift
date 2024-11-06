//
//  RefreshRecipesUseCaseTests.swift
//  FetchRecipesTests
//
//  Created by Coleton Gorecke on 11/6/24.
//

import XCTest
import Factory
@testable import FetchRecipes

final class RefreshRecipesUseCaseTests: XCTestCase {
    private var mockRecipesRepo: MockRecipesRepository!
    private var sut: RefreshRecipesUseCaseImp!

    override func setUp() {
        super.setUp()
        DataContainer.shared.reset()

        let mockRecipesRepo = MockRecipesRepository()
        DataContainer.shared.recipesRepository.register { mockRecipesRepo }

        self.mockRecipesRepo = DataContainer.shared.recipesRepository() as? MockRecipesRepository
        sut = RefreshRecipesUseCaseImp()
    }


}
