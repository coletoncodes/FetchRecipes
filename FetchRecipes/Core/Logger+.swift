//
//  Logger+.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import OSLog

/// The global logging function used in this module.
/// Copy this function almost exactly in host app's to simplify
/// logging across the app.
func log(
    _ message: String,
    _ osLogType: OSLogType = .debug,
    _ category: LogCategory,
    function: String = #function,
    line: Int = #line,
    file: String = #file
) {
    logger.log(message, osLogType, category, function: function, line: line, file: file)
}

fileprivate var logger: Logger {
    .init(subsystem: Bundle.main.bundleIdentifier ?? "", category: "FetchRecipesLogger")
}

/// The additional Log Category to include in log messages.
public enum LogCategory: String {
    case `default` = "[Default]"
    case networking = "[Networking]"
    case interactor = "[Interactor]"
    case viewModel = "[ViewModel]"
}

/// Extends the OSLog Logger into a standardized log message.
extension Logger {
    func log(
        _ message: String,
        _ osLogType: OSLogType = .debug,
        _ category: LogCategory,
        function: String = #function,
        line: Int = #line,
        file: String = #file
    ) {
        let fileInfo = file.components(separatedBy: "/").last ?? "Unparsable file"
        let logInfo = "File: \(fileInfo) | Function: \(function) at line: \(line)"
        let emoji = "[\(osLogType.emoji)] -- \(osLogType.rawDescription) | "
        let logMessage = "\(emoji)\(category.rawValue) | Message: \(message)"
        let logStr = "\(logMessage) | \(logInfo)"

        switch osLogType {
        case .debug:
            self.debug("\(logStr)")
        case .info:
            self.info("\(logStr)")
        case .error:
            self.error("\(logStr)")
        case .fault:
            self.fault("\(logStr)")
        default:
            self.log("\(logStr)")
        }
    }

}

extension OSLogType {
    var emoji: String {
        switch self {
        case .debug:
            return "🐛"
        case .info:
            return "ℹ️"
        case .error:
            return "❌"
        case .fault:
            return "💥"
        default:
            return "🤖"
        }
    }

    var rawDescription: String {
        switch self {
        case .debug:
            return "Debug"
        case .info:
            return "Info"
        case .error:
            return "Error"
        case .fault:
            return "Fault"
        default:
            return "Default"
        }
    }
}
