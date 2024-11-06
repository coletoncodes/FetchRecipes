//
//  URLSessionProtocol.swift
//  
//
//  Created by Coleton Gorecke on 4/20/24.
//

import Foundation

/// Protocol to abstract the URLSession functionalities, allowing for better testability and flexibility in network communication.
public protocol URLSessionProtocol {
    /// Fetches data from a given URLRequest asynchronously.
    /// - Parameter request: The `URLRequest` to fetch data for.
    /// - Returns: A tuple containing the `Data` and `URLResponse` from the network request.
    /// - Throws: An error if the data fetching fails.
    func data(
        for request: URLRequest
    ) async throws -> (Data, URLResponse)
}

/// Extension to make URLSession conform to URLSessionProtocol, enabling it to be substituted with mock sessions in testing.
extension URLSession: URLSessionProtocol {}
