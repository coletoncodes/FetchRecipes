//
//  AppLoggerTests.swift
//  Logging
//
//  Created by Coleton Gorecke on 11/6/24.
//

@testable import Logging
import XCTest

final class AppLoggerTests: XCTestCase {

    func testAddNewDestination() {
        // Arrange
        // no destinations
        let logger = AppLogger(destinations: [])
        let mockDestination = MockLoggerDestination()
        let expectation = XCTestExpectation(description: "Wait for logging destination to be added")

        // Act
        logger.add(mockDestination)

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertEqual(logger.destinations.count, 1) // Original + Mock
        XCTAssertTrue(logger.destinations.contains { $0 is MockLoggerDestination })
    }

    func testPreventDuplicateDestination() {
        // Arrange
        // no destinations
        let logger = AppLogger(destinations: [])
        let mockDestination = MockLoggerDestination()
        let expectation = XCTestExpectation(description: "Wait for logging destination to be called")

        // Act
        logger.add(mockDestination)
        logger.add(mockDestination) // Attempt to add duplicate

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertEqual(logger.destinations.count, 1) // Original + Mock
    }

    func testLogMessageIsSentToAllDestinations() {
        // Arrange
        let logger = AppLogger()
        let mockDestination = MockLoggerDestination()
        logger.add(mockDestination)
        let expectation = XCTestExpectation(description: "Wait for logging to complete")

        // Act
        logger.log("Test Message", .debug, .networking, function: "testFunction", line: 123, file: "testFile")

        // Add a small delay to allow async logging to complete
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Assert on the stubbed loggedMessages in MockLoggerDestination
        XCTAssertEqual(mockDestination.loggedMessages.count, 1)
        let logEntry = mockDestination.loggedMessages.first
        XCTAssertEqual(logEntry!.message, "Test Message")
        XCTAssertEqual(logEntry!.type, .debug)
        XCTAssertEqual(logEntry!.category, .networking)
        XCTAssertEqual(logEntry!.function, "testFunction")
        XCTAssertEqual(logEntry!.line, 123)
        XCTAssertEqual(logEntry!.file, "testFile")
    }
}
