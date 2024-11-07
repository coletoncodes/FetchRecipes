//
//  NetworkRequesterTests.swift
//
//
//  Created by Coleton Gorecke on 4/20/24.
//

@testable import Networking
import Foundation
import XCTest

final class NetworkRequesterTests: XCTestCase {
    private var sut: NetworkRequester!
    private var mockURLSession: MockURLSession!
    private var mockResponseHandler: MockNetworkResponseHandler<MockNetworkRequest.SuccessResponse, MockNetworkRequest.ErrorResponse>!
    private var mockNetworkRequest: MockNetworkRequest!
    
    private var jsonEncoder: JSONEncoder!
    private var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        self.mockURLSession = MockURLSession()
        self.mockResponseHandler = MockNetworkResponseHandler()
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
        
        sut = NetworkRequester(
            encoder: jsonEncoder,
            urlSession: mockURLSession
        )
    }
    
    // MARK: - Tests
    func testPerformRequest_ReturnsSuccessResponse() async throws {
        // Given
        let body = MockRequestBody(value: "Test")
        let mockRequest = MockNetworkRequest(body: body, method: .POST, path: "https://example.com/api", headers: [.jsonContentType])
        let expectedData = try jsonEncoder.encode(body)
        let expectedStatusCode = 200
        let expectedURL = URL(string: mockRequest.path)!
        let urlResponse = HTTPURLResponse(
            url: expectedURL,
            statusCode: expectedStatusCode,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Success response to be returned by the handler
        let expectedSuccessValue: MockNetworkRequest.SuccessResponse = "Success"
        let expectedSuccessResponse: NetworkResponse<MockNetworkRequest.SuccessResponse, MockNetworkRequest.ErrorResponse> = .successResponse(expectedSuccessValue)
        
        mockResponseHandler.handleResponseStub = { givenStatusCode, givenData in
            XCTAssertEqual(givenStatusCode, expectedStatusCode)
            XCTAssertEqual(givenData, expectedData)
            return expectedSuccessResponse
        }
        
        mockURLSession.dataForRequestStub = { request in
            XCTAssertEqual(request.httpBody, expectedData)
            XCTAssertEqual(request.url, expectedURL)
            return (expectedData, urlResponse!)
        }
        
        // When
        let response = try await sut.performRequest(mockRequest, responseHandler: mockResponseHandler)
        
        // Then
        switch response {
        case let .successResponse(successResponse):
            XCTAssertEqual(successResponse, expectedSuccessValue)
        case .errorResponse(_):
            XCTFail("Expected success response, received error response instead.")
        }
    }
    
    func testPerformRequest_ReturnsErrorResponse() async throws {
        // Given
        let body = MockRequestBody(value: "Test")
        let mockRequest = MockNetworkRequest(body: body, method: .POST, path: "https://example.com/api", headers: [.jsonContentType])
        let expectedData = try jsonEncoder.encode(body)
        let expectedStatusCode = 200
        let expectedURL = URL(string: mockRequest.path)!
        let urlResponse = HTTPURLResponse(
            url: expectedURL,
            statusCode: expectedStatusCode,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Success response to be returned by the handler
        let expectedErrorValue: MockNetworkRequest.ErrorResponse = "Failure"
        let expectedResponse: NetworkResponse<MockNetworkRequest.SuccessResponse, MockNetworkRequest.ErrorResponse> = .errorResponse(expectedErrorValue)
        
        mockResponseHandler.handleResponseStub = { givenStatusCode, givenData in
            XCTAssertEqual(givenStatusCode, expectedStatusCode)
            XCTAssertEqual(givenData, expectedData)
            return expectedResponse
        }
        
        mockURLSession.dataForRequestStub = { request in
            XCTAssertEqual(request.httpBody, expectedData)
            XCTAssertEqual(request.url, expectedURL)
            return (expectedData, urlResponse!)
        }
        
        // When
        let response = try await sut.performRequest(mockRequest, responseHandler: mockResponseHandler)
        
        // Then
        switch response {
        case .successResponse(_):
            XCTFail("Expected error response, received success response instead.")
        case let .errorResponse(errorResponse):
            XCTAssertEqual(errorResponse, expectedErrorValue)
        }
    }
    
    func testPerformRequest_WhenBodyCannotBeEncoded_ThrowsError() async throws {
        // Given
        let body = Unencodable()
        let mockRequest = MockNetworkRequest(body: body, method: .POST, path: "https://example.com/api", headers: [.jsonContentType])
        
        // When & Then
        do {
            _ = try await sut.performRequest(mockRequest, responseHandler: mockResponseHandler)
            XCTFail("An error was expected to be thrown for unencodable body, but the request completed.")
        } catch NetworkRequesterError.encodingError {
            // success
        } catch {
            XCTFail("Unexpected error type thrown: \(error)")
        }
    }
    
    func testPerformRequest_NoBodySuccess() async throws {
        // Given
        let mockRequest = MockNetworkRequest(body: nil, method: .POST, path: "https://example.com/api", headers: [.jsonContentType])
        let expectedStatusCode = 200
        let expectedURL = URL(string: mockRequest.path)!
        let urlResponse = HTTPURLResponse(
            url: expectedURL,
            statusCode: expectedStatusCode,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Success response to be returned by the handler
        let expectedValue: MockNetworkRequest.SuccessResponse = "Success"
        let expectedResponse: NetworkResponse<MockNetworkRequest.SuccessResponse, MockNetworkRequest.ErrorResponse> = .successResponse(expectedValue)
        
        mockResponseHandler.handleResponseStub = { givenStatusCode, givenData in
            XCTAssertEqual(givenStatusCode, expectedStatusCode)
            return expectedResponse
        }
        
        mockURLSession.dataForRequestStub = { request in
            XCTAssertNil(request.httpBody)
            XCTAssertEqual(request.url, expectedURL)
            return (Data(), urlResponse!)
        }
        
        // When
        let response = try await sut.performRequest(mockRequest, responseHandler: mockResponseHandler)
        
        // Then
        switch response {
        case let .successResponse(successResponse):
            XCTAssertEqual(successResponse, expectedValue)
        case .errorResponse(_):
            XCTFail("Expected success response, received error response instead.")
        }
    }
    
    func testPerformRequest_ResponseIsNotHTTPURLResponse_ThrowsError() async throws {
        // Given
        let mockRequest = MockNetworkRequest(body: nil, method: .POST, path: "https://example.com/api", headers: [.jsonContentType])
        let expectedURL = URL(string: mockRequest.path)!
        let urlResponse = URLResponse(
            url: expectedURL,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        
        mockURLSession.dataForRequestStub = { request in
            XCTAssertNil(request.httpBody)
            XCTAssertEqual(request.url, expectedURL)
            return (Data(), urlResponse)
        }
        
        // When
        do {
            let _ = try await sut.performRequest(mockRequest, responseHandler: mockResponseHandler)
        } catch NetworkRequesterError.nonHTTPURLResponse(let response) {
            // Then
            XCTAssertEqual(response, urlResponse)
        }
    }
    
}
