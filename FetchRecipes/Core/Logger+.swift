//
//  Logger+.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import OSLog
import Logging

/// The logging function used in the app.
/// avoids inporting Logging throughout the app
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
