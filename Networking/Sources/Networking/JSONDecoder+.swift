//
//  JSONDecoder+.swift
//
//
//  Created by Coleton Gorecke on 4/29/24.
//

import Foundation

extension JSONDecoder {
    /// Attempts to decode a specific Response object that conforms to Decodable.
    /// - Parameters:
    ///   - type: The type to try and decode
    ///   - data: The data to use for decoding
    /// - Returns: The decoded data
    /// - Throws: A ``DecodingError`` if decoding fails, or the raw error if is not a   ``DecodingError`` type
    func decodeResponse<T: Decodable>(
        _ type: T.Type,
        from data: Data
    ) throws -> T {
        do {
            return try self.decode(type, from: data)
        } catch let error as DecodingError {
            log("Failed to decode type of \(type) with error: \(error)", .error)
            throw error
        } catch {
            log("Unexpected error during decoding: \(error)", .error)
            throw error
        }
    }
}
