//
//  Mocks.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

@testable import FetchRecipes
import Foundation
import Networking

enum TestError: Error {
    case expected
    case unexpected(String)
}

final class MockJSONDecoder: JSONDecoder, @unchecked Sendable {
    // Closure to customize decoding behavior
    var decodeClosure: ((Data) throws -> Any)?

    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        if let decodeClosure = decodeClosure {
            guard let result = try decodeClosure(data) as? T else {
                throw TestError.unexpected("Could not decode data to type \(T.self).")
            }
            return result
        }

        throw TestError.unexpected("Missing stubbed decode closure")
    }
}

final class MockRecipesRequester: RecipesNetworkRequesting {

    var getRecipesStub: (() async throws -> [RecipeDTO])?

    func getRecipes() async throws -> [RecipeDTO] {
        guard let getRecipesStub else {
            throw TestError.unexpected("getRecipesStub not set")
        }
        return try await getRecipesStub()
    }
}

final class MockRecipesRepository: RecipesRepository {
    var getRecipesStub: ((Bool) async throws -> [Recipe])?

    func getRecipes(forceRefresh: Bool) async throws -> [Recipe] {
        guard let getRecipesStub else {
            throw TestError.unexpected("getRecipesStub not set")
        }

        return try await getRecipesStub(forceRefresh)
    }
}

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
