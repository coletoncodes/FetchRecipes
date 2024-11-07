//
//  NetworkRequesterErrorTests.swift
//
//
//  Created by Coleton Gorecke on 4/29/24.
//

@testable import Networking
import XCTest

final class NetworkRequesterErrorTests: XCTestCase {
    
    func testDecodingError() {
        let error = NetworkRequesterError.decodingError("Failed to decode data")
        XCTAssertEqual(error.errorDescription, "Failed to decode data")
    }
    
    func testEncodingError() {
        let error = NetworkRequesterError.encodingError("Failed to encode data")
        XCTAssertEqual(error.errorDescription, "Failed to encode data")
    }
    
    func testNonHTTPURLResponse() {
        let response = URLResponse(url: URL(string: "https://example.com")!,
                                   mimeType: nil,
                                   expectedContentLength: 0,
                                   textEncodingName: nil)
        let error = NetworkRequesterError.nonHTTPURLResponse(response)
        XCTAssertTrue(error.errorDescription.contains("Non-HTTP URL response"))
    }
    
    func testInvalidStatusCode_Informational() {
        let statusCodeError = NetworkRequesterError.StatusCodeError.informational
        let error = NetworkRequesterError.invalidStatusCode(statusCodeError)
        XCTAssertEqual(error.errorDescription, "Informational")
    }
    
    func testInvalidStatusCode_Redirection() {
        let statusCodeError = NetworkRequesterError.StatusCodeError.redirection
        let error = NetworkRequesterError.invalidStatusCode(statusCodeError)
        XCTAssertEqual(error.errorDescription, "Redirect")
    }
    
    func testInvalidStatusCode_BadRequest() {
        let statusCodeError = NetworkRequesterError.StatusCodeError.badRequest
        let error = NetworkRequesterError.invalidStatusCode(statusCodeError)
        XCTAssertEqual(error.errorDescription, "Bad request")
    }
    
    func testInvalidStatusCode_Unauthorized() {
        let statusCodeError = NetworkRequesterError.StatusCodeError.unauthorized
        let error = NetworkRequesterError.invalidStatusCode(statusCodeError)
        XCTAssertEqual(error.errorDescription, "Unauthorized")
    }
    
    func testInvalidStatusCode_InternalServerError() {
        let statusCodeError = NetworkRequesterError.StatusCodeError.internalServerError
        let error = NetworkRequesterError.invalidStatusCode(statusCodeError)
        XCTAssertEqual(error.errorDescription, "Internal Server Error")
    }
    
    func testInvalidStatusCode_Unhandled() {
        let statusCodeError = NetworkRequesterError.StatusCodeError.unhandled(1)
        let error = NetworkRequesterError.invalidStatusCode(statusCodeError)
        XCTAssertEqual(error.errorDescription, "Unhandled status code: \(1)")
    }
    
    func testErrorResponse() {
        let error = NetworkRequesterError.errorResponse("Server error occurred")
        XCTAssertEqual(error.errorDescription, "Server error occurred")
    }
    
    func testNilData() {
        let error = NetworkRequesterError.nilData("No data received")
        XCTAssertEqual(error.errorDescription, "No data received")
    }
    
    func testStatusCodeErrorDescription() {
        // Test for a specific status code error
        let statusCodeError = NetworkRequesterError.StatusCodeError.unhandled(501)
        XCTAssertEqual(statusCodeError.errorDescription, "Unhandled status code: 501")
    }
    
}
