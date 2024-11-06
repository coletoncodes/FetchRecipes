//
//  NetworkRequest.swift
//  FinanceFlow
//
//  Created by Coleton Gorecke on 5/21/23.
//

import Foundation

/// Defines a protocol that all network request objects must conform to.
public protocol NetworkRequest {
    associatedtype SuccessResponse: Decodable
    associatedtype ErrorResponse: Decodable
    
    /// The request body, conforming to `Encodable`.
    var body: Encodable? { get }
    
    /// HTTP method to be used for the request.
    var method: HTTPMethod { get }
    
    /// Endpoint path for the request.
    var path: String { get }
    
    /// Collection of headers to be included in the request.
    var headers: [NetworkHeader] { get }
    
    /// Generates a `URLRequest` object configured with the specified body data.
    /// - Parameter body: Data to set as the HTTP body of the request.
    /// - Returns: A configured `URLRequest` instance.
    /// - Throws: `NetworkRequestError.invalidRequestURL` if the URL cannot be constructed.
    func urlRequest(with body: Data?) throws -> URLRequest
}

/// Represents a single HTTP header, used in network requests.
public struct NetworkHeader: Equatable {
    public let key: String
    public let value: String
    
    /// Initializes a new `NetworkHeader` with a key and value.
    /// - Parameters:
    ///   - key: The header key.
    ///   - value: The header value.
    public init(
        key: String,
        value: String
    ) {
        self.key = key
        self.value = value
    }
    
    /// A predefined `NetworkHeader` for `Content-Type: application/json`.
    public static let jsonContentType: NetworkHeader = {
        return .init(key: "Content-Type", value: "application/json")
    }()
}

/// Enum defining the supported HTTP methods for network requests.
public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

/// Enum representing possible errors that can occur during network request creation.
public enum NetworkRequestError: Error {
    /// Error thrown when a URL cannot be constructed from a given string.
    case invalidRequestURL(String)
}

/// Extension to provide a default implementation for generating `URLRequest` instances from `NetworkRequest` objects.
public extension NetworkRequest {
    
    /// Generates a `URLRequest` configured with optional body data.
    /// - Parameter body: Optional `Data` to set as the HTTP body of the request.
    /// - Returns: A fully configured `URLRequest`.
    /// - Throws: `NetworkRequestError.invalidRequestURL` if the URL cannot be constructed.
    func urlRequest(with body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: path) else {
            let logStr = "Failed to build url from: \(path)"
            log(logStr, .error, .networking)
            throw NetworkRequestError.invalidRequestURL(logStr)
        }
        
        log("Performing request to URL: \(url)", .debug, .networking)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        log("HTTPMethod: \(method.rawValue)", .debug, .networking)
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if let headers = request.allHTTPHeaderFields {
            log("Request Headers: \(headers.prettyPrintedHeaders())", .debug, .networking)
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
}

fileprivate extension Dictionary where Key == String, Value == String {
    /// Formats the dictionary into a pretty-printed key-value pair string.
    func prettyPrintedHeaders() -> String {
        self.map { "\($0.key): \($0.value)" }
            .sorted()
            .joined(separator: "\n")
    }
}
