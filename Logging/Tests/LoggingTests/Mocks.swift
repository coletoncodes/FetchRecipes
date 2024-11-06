//
//  Mocks.swift
//  Logging
//
//  Created by Coleton Gorecke on 11/6/24.
//

@testable import Logging
import Foundation
import OSLog

final class MockLoggerDestination: LoggerDestination, @unchecked Sendable {
    var loggedMessages: [(message: String, type: OSLogType, category: LogCategory, function: String, line: Int, file: String)] = []

    func log(
        _ message: String,
        _ osLogType: OSLogType,
        _ category: LogCategory,
        function: String,
        line: Int,
        file: String
    ) {
        loggedMessages.append((message, osLogType, category, function, line, file))
    }
}
