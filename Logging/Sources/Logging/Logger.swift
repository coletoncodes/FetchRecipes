// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import OSLog

/// The global logging function used in this module.
/// Copy this function almost exactly in each module to avoid importing Logger everywhere, if desired.
/// logging across the app.
public func log(
    _ message: String,
    _ osLogType: OSLogType = .debug,
    _ category: LogCategory,
    function: String = #function,
    line: Int = #line,
    file: String = #file
) {
    logger.log(message, osLogType, category, function: function, line: line, file: file)
}

public let logger: AppLogger = AppLogger()

public final class AppLogger: @unchecked Sendable {

    private(set) var destinations: [LoggerDestination]
    
    /// Initializes the logger with the initial destinations
    /// - Parameter destinations: The destinations to include to the logger, defaults to include ``OSLogDestionation``
    public init(destinations: [LoggerDestination] = [OSLogDestination()]) {
        self.destinations = destinations
    }

    private let queue = DispatchQueue(label: "com.app.logger.queue", attributes: .concurrent)

    public func add(_ newDestination: LoggerDestination) {
        queue.async(flags: .barrier) {
            for existingDestination in self.destinations {
                if type(of: existingDestination) == type(of: newDestination) {
                    return
                }
            }
            self.destinations.append(newDestination)
        }
    }

    // MARK: - Interface
    public func log(
        _ message: String,
        _ osLogType: OSLogType = .debug,
        _ category: LogCategory,
        function: String,
        line: Int,
        file: String
    ) {
        queue.async {
            for destination in self.destinations {
                destination.log(message, osLogType, category, function: function, line: line, file: file)
            }
        }
    }
}
