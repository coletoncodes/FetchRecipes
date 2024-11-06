//
//  OSLogDestination.swift
//  Logging
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import OSLog

/// The OS logging destination to ensure logs are submitted to the OS Log System.
final class OSLogDestination: LoggerDestination {
    private let logger: Logger

    init() {
        let subsystem = Bundle.main.bundleIdentifier ?? "Unknown Subsystem"
        self.logger = Logger(subsystem: subsystem, category: "FetchRecipesLogger")
    }

    func log(
        _ message: String,
        _ osLogType: OSLogType,
        _ category: LogCategory,
        function: String,
        line: Int,
        file: String
    ) {
        logger.log(message, osLogType, category, function: function, line: line, file: file)
    }
}
