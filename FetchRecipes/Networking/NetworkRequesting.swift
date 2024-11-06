//
//  NetworkRequesting.swift
//  FinanceFlow
//
//  Created by Coleton Gorecke on 5/21/23.
//

import Foundation

/// Protocol defining the basic requirements for performing network requests.
public protocol NetworkRequesting {
    /// Performs a network request and processes the response.
    /// - Parameters:
    ///   - request: A request conforming to `NetworkRequest`.
    ///   - responseHandler: A handler conforming to `NetworkResponseHandler` to process the response.
    /// - Returns: A `NetworkResponse` containing either a success or error response.
    /// - Throws: An error if the request or response processing fails.
    func performRequest<V: NetworkRequest, H: NetworkResponseHandler>(
        _ request: V,
        responseHandler: H
    ) async throws -> NetworkResponse<H.SuccessResponse, H.ErrorResponse>
}

/// Represents the possible responses from a network request, handling both success and error cases.
public enum NetworkResponse<SuccessResponse: Decodable, ErrorResponse: Decodable>: Decodable {
    case successResponse(SuccessResponse)
    case errorResponse(ErrorResponse)
    
    /// Initializes from a decoder, attempting to decode either a success or error response.
    /// - Parameter decoder: Decoder to parse the data.
    /// - Throws: `DecodingError` if the data does not match any expected response type.
    public init(from decoder: any Decoder) throws {
        if let successResponse = try? SuccessResponse(from: decoder) {
            self = .successResponse(successResponse)
        } else if let errorResponse = try? ErrorResponse(from: decoder) {
            self = .errorResponse(errorResponse)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Data does not match any response type"))
        }
    }
    
}

/// Protocol for handling the response of a network request, specifying the types for success and error responses.
public protocol NetworkResponseHandler {
    
    associatedtype SuccessResponse: Decodable
    associatedtype ErrorResponse: Decodable
    
    /// Handles the network response data.
    /// - Parameters:
    ///   - statusCode: HTTP status code of the response.
    ///   - responseData: Data returned from the response.
    /// - Returns: A `NetworkResponse` instance representing either a success or an error response, where either can be returned.
    func handleResponse(statusCode: Int, responseData: Data) async throws -> NetworkResponse<SuccessResponse, ErrorResponse>
}

/// A class responsible for making network requests using a configurable encoder and session.
open class NetworkRequester: NetworkRequesting {
    public let encoder: JSONEncoder
    public let urlSession: URLSessionProtocol
    
    /// Initializes a new `NetworkRequester`.
    /// - Parameters:
    ///   - encoder: JSON encoder to use for encoding request bodies.
    ///   - urlSession: URL session conforming to `URLSessionProtocol` to make network requests.
    public init(
        encoder: JSONEncoder = JSONEncoder(),
        urlSession: URLSessionProtocol
    ) {
        self.encoder = encoder
        self.urlSession = urlSession
    }
    
    /// See `NetworkRequesting.performRequest(_:responseHandler:)`.
    public func performRequest<V: NetworkRequest, H: NetworkResponseHandler>(
        _ request: V,
        responseHandler: H
    ) async throws -> NetworkResponse<H.SuccessResponse, H.ErrorResponse> {
        
        let data = try verifyBodyFor(request)
        let (responseData, response) = try await urlSession.data(for: request.urlRequest(with: data))
        
        guard let httpResponse = response as? HTTPURLResponse else {
            let logStr = "Failed to cast response as HTTPURLResponse"
            log(logStr, .error, .networking)
            throw NetworkRequesterError.nonHTTPURLResponse(response)
        }
        return try await responseHandler.handleResponse(statusCode: httpResponse.statusCode, responseData: responseData)
    }
    
    /// Verifies and encodes the body of the request if available.
    /// - Parameter request: The request to verify.
    /// - Returns: The encoded data or nil if no body is present.
    /// - Throws: `NetworkRequesterError.encodingError` if encoding fails.
    private func verifyBodyFor<U: NetworkRequest>(_ request: U) throws -> Data? {
        if let body = request.body {
            do {
                let encodedData = try encoder.encode(body)
                // Convert encoded data back to JSON object to print it prettily
                if let jsonObject = try? JSONSerialization.jsonObject(with: encodedData, options: []),
                   let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let prettyPrintedString = String(data: prettyPrintedData, encoding: .utf8) {
                    log("Encoded JSON body: \n\(prettyPrintedString)\n", .debug, .networking)
                }
                return encodedData
            } catch {
                throw NetworkRequesterError.encodingError("\(error)")
            }
        }
        return nil
    }
}
