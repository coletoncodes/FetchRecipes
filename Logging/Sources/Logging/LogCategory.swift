//
//  LogCategory.swift
//  Logger
//
//  Created by Coleton Gorecke on 11/6/24.
//

/// The additional Log Category to include in log messages.
public enum LogCategory: Sendable, Equatable {
    case `default`
    case networking
    case useCase
    case repository
    case viewModel

    case custom(String)

    public var loggerDescription: String {
        switch self {
        case .default: return "Default"
        case .networking: return "Networking"
        case .useCase: return "UseCase"
        case .repository: return "Repository"
        case .viewModel: return "ViewModel"
        case .custom(let description): return description
        }
    }
}
