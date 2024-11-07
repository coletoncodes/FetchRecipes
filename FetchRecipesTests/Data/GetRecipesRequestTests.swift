//
//  GetRecipesRequestTests.swift
//  FetchRecipesTests
//
//  Created by Coleton Gorecke on 11/6/24.
//

@testable import FetchRecipes
import Networking
import XCTest

final class GetRecipesRequestTests: XCTestCase {

    var request: GetRecipesRequest!

    override func setUpWithError() throws {
       try super.setUpWithError()
        // Initialize the request before each test
        request = GetRecipesRequest()
    }

    override func tearDownWithError() throws {
        // Cleanup after each test
        request = nil
        try super.tearDownWithError()
    }

    // Test to ensure the HTTP method is correctly set to GET
    func testHTTPMethod_GET() throws {
        XCTAssertEqual(request.method, .GET, "HTTP method should be GET.")
    }

    // Test to ensure the path is set to the correct URL
    func testPath_Matches() throws {
        XCTAssertEqual(request.path, "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json", "Request path should match the expected URL.")
    }

    // Test to ensure that headers contain the correct content type
    func testHeaders_Empty() throws {
        XCTAssertEqual(request.headers.count, 0, "There should be no headers.")
    }

    // Test to ensure the body is nil (since it's a GET request)
    func testBody_IsNil() throws {
        XCTAssertNil(request.body, "Body should be nil for GET requests.")
    }
}
