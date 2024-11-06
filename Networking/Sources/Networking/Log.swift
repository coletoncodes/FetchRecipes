//
//  log.swift
//  Networking
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Foundation
import Logging
import OSLog

func log(
    _ message: String,
    _ osLogType: OSLogType = .debug,
    function: String = #function,
    line: Int = #line,
    file: String = #file
) {
    logger.log(message, osLogType, .networking, function: #function, line: #line, file: #file)
}
