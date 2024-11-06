//
//  NetworkRequesterError.swift
//
//
//  Created by Coleton Gorecke on 7/4/23.
//

import Foundation

/// Protocol to define errors related to network operations, providing an error description.
public protocol NetworkError: Error, Equatable {
    /// A human-readable description of the error.
    var errorDescription: String { get }
}

/// Enumeration of errors specific to `NetworkRequester` operations.
public enum NetworkRequesterError: NetworkError {
    case decodingError(String)
    case encodingError(String)
    case nonHTTPURLResponse(URLResponse)
    case invalidStatusCode(StatusCodeError)
    case errorResponse(String)
    case nilData(String)
    
    /// Enumeration detailing specific status code related errors.
    public enum StatusCodeError: NetworkError {
        /// Errors typically representing 1xx informational responses.
        ///
        /// > Note: This error can be used at will for various reasons. Typically defined by a ``NetworkResponseHandler``
        case informational
        /// Errors typically representing 3xx redirection responses.
        ///
        /// > Note: This error can be used at will for various reasons. Typically defined by a ``NetworkResponseHandler``
        case redirection
        /// Error typically representing a 400 Bad Request response.
        ///
        /// > Note: This error can be used at will for various reasons. Typically defined by a ``NetworkResponseHandler``
        case badRequest
        /// Error typically representing a 401 Unauthorized response.
        ///
        /// > Note: This error can be used at will for various reasons. Typically defined by a ``NetworkResponseHandler``
        case unauthorized
        /// Error typically representing a 500 Internal Server Error response.
        ///
        /// > Note: This error can be used at will for various reasons. Typically defined by a ``NetworkResponseHandler``
        case internalServerError
        /// Errors for unhandled status codes.
        case unhandled(Int)
        
        public var errorDescription: String {
            switch self {
            case .informational:
                return "Informational"
            case .redirection:
                return "Redirect"
            case .badRequest:
                return "Bad request"
            case .unauthorized:
                return "Unauthorized"
            case .internalServerError:
                return "Internal Server Error"
            case let .unhandled(statusCode):
                return "Unhandled status code: \(statusCode)"
            }
        }
    }
    
    public var errorDescription: String {
        switch self {
        case let .decodingError(details),
             let .encodingError(details),
             let .errorResponse(details),
             let .nilData(details):
            return details
        case let .nonHTTPURLResponse(response):
            return "Non-HTTP URL response: \(response)"
        case let .invalidStatusCode(statusCodeError):
            return statusCodeError.errorDescription
        }
    }
}

