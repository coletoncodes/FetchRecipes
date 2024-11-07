//
//  Logger+.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import OSLog

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
        let logMessage = "\(emoji)\(category.loggerDescription) | Message: \(message)"
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
