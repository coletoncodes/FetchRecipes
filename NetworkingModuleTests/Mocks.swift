//
//  Mocks.swift
//
//
//  Created by Coleton Gorecke on 4/11/24.
//

@testable import NetworkingModule
import Foundation

enum MockError: Error {
    case expectedError
}

struct MockNetworkRequest: NetworkRequest {
    typealias SuccessResponse = String
    typealias ErrorResponse = String
    
    var body: Encodable?
    
    var method: HTTPMethod
    
    var path: String
    
    var headers: [NetworkHeader]
    
    init(
        body: Encodable?,
        method: HTTPMethod,
        path: String,
        headers: [NetworkHeader]
    ) {
        self.body = body
        self.method = method
        self.path = path
        self.headers = headers
    }
}

final class MockURLSession: URLSessionProtocol {
    var dataForRequestStub: ((URLRequest) async throws -> (Data, URLResponse))!
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await dataForRequestStub(request)
    }
}

final class MockRequestBody: Encodable {
    let value: String
    
    init(value: String) {
        self.value = value
    }
}

struct MockNetworkResponseHandler<SuccessResponse: Decodable, ErrorResponse: Decodable>: NetworkResponseHandler {
    typealias SuccessResponse = SuccessResponse
    typealias ErrorResponse = ErrorResponse
    
    var handleResponseStub: ((Int, Data) async throws -> NetworkResponse<SuccessResponse, ErrorResponse>)!
    
    func handleResponse(statusCode: Int, responseData: Data) async throws -> NetworkResponse<SuccessResponse, ErrorResponse> {
        try await handleResponseStub(statusCode, responseData)
    }
}

struct Unencodable: Encodable {
    func encode(to encoder: Encoder) throws {
        throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "This object cannot be encoded"))
    }
}
