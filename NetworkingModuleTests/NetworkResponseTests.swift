//
//  NetworkResponseTests.swift
//
//
//  Created by Coleton Gorecke on 4/29/24.
//

@testable import NetworkingModule
import XCTest

final class NetworkResponseTests: XCTestCase {
    
    struct MockSuccessResponse: Decodable {
        let message: String
    }
    
    struct MockErrorResponse: Decodable {
        let error: String
    }
    
    func testSuccessResponseDecoding() throws {
        let jsonData = "{\"message\":\"Success!\"}".data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(NetworkResponse<MockSuccessResponse, MockErrorResponse>.self, from: jsonData)
        
        switch result {
        case let .successResponse(response):
            XCTAssertEqual(response.message, "Success!")
        default:
            XCTFail("Expected error response, received something else.")
        }
    }
    
    func testErrorResponseDecoding() throws {
        let jsonData = "{\"error\":\"Failed!\"}".data(using: .utf8)!
        let decoder = JSONDecoder()
        let result = try decoder.decode(NetworkResponse<MockSuccessResponse, MockErrorResponse>.self, from: jsonData)
        
        switch result {
        case .errorResponse(let response):
            XCTAssertEqual(response.error, "Failed!")
        default:
            XCTFail("Expected error response, received something else.")
        }
    }
    
    func testDataCorruption() {
        let jsonData = "{\"unexpected\":\"data\"}".data(using: .utf8)!
        let decoder = JSONDecoder()
        
        XCTAssertThrowsError(try decoder.decode(NetworkResponse<MockSuccessResponse, MockErrorResponse>.self, from: jsonData)) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail("Expected decoding to fail due to data corruption, but it failed for another reason.")
            }
        }
    }
}
