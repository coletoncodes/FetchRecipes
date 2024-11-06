//
//  NetworkRequestTests.swift
//  
//
//  Created by Coleton Gorecke on 4/25/24.
//

@testable import NetworkingModule
import Foundation
import XCTest

final class NetworkRequestTests: XCTestCase {
    private var sut: MockNetworkRequest!
    private var jsonEncoder: JSONEncoder!
    
    override func setUp() {
        jsonEncoder = JSONEncoder()
    }
    
    // MARK: - Tests
    func testNilBody() throws {
        /** Given */
        sut = MockNetworkRequest(
            body: nil,
            method: .GET,
            path: "https://example.com/api",
            headers: [.jsonContentType]
        )
        
        let expectedBody: Data? = nil
        let expectedURL = URL(string: sut.path)!
        let expectedHeaders = sut.headers.reduce(into: [String: String]()) { $0[$1.key] = $1.value }
        
        /** When */
        let urlRequest = try sut.urlRequest()
        
        /** Then */
        XCTAssertEqual(urlRequest.url, expectedURL)
        XCTAssertEqual(urlRequest.httpMethod, sut.method.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest.httpBody, expectedBody)
    }
    
    func testNonNilBody() throws {
        /** Given */
        let body = MockRequestBody(value: "Value")
        sut = MockNetworkRequest(
            body: body,
            method: .GET,
            path: "https://example.com/api",
            headers: [.jsonContentType]
        )
        
        let bodyData = try jsonEncoder.encode(body)
        let expectedURL = URL(string: sut.path)!
        let expectedHeaders = sut.headers.reduce(into: [String: String]()) { $0[$1.key] = $1.value }
        
        /** When */
        let urlRequest = try sut.urlRequest(with: bodyData)
        
        /** Then */
        XCTAssertEqual(urlRequest.url, expectedURL)
        XCTAssertEqual(urlRequest.httpMethod, sut.method.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, expectedHeaders)
        XCTAssertEqual(urlRequest.httpBody, bodyData)
    }
    
    func testInvalidPath_ThrowsError() throws {
        /** Given */
        let body = MockRequestBody(value: "Value")
        sut = MockNetworkRequest(
            body: body,
            method: .GET,
            path: "",
            headers: [.jsonContentType]
        )
        
        let bodyData = try jsonEncoder.encode(body)
        
        /** When */
        do {
            let _ = try sut.urlRequest(with: bodyData)
            XCTFail("Error should have been thrown")
        } catch NetworkRequestError.invalidRequestURL {
            /** Then */
            // success
        } catch {
            XCTFail("Unexpected error thrown: \(error)")
        }
    }
}
