//
//  LoggerDestination.swift
//  Logging
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import OSLog

public protocol LoggerDestination: Sendable {
    func log(
        _ message: String,
        _ osLogType: OSLogType,
        _ category: LogCategory,
        function: String,
        line: Int,
        file: String
    )
}
