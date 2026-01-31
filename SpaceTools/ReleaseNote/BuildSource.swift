//
//  BuildSource.swift
//  SpaceTools
//
//  Created by Giga Khizanishvili on 04.04.25.
//

import Foundation

enum BuildSource: CaseIterable, Hashable {
    case production
    case devAdhoc
    case devTestFlight
    case testAdhoc
    case testTestFlight

    static var allCases: [BuildSource] {
        [.production, .devAdhoc, .devTestFlight, .testAdhoc, .testTestFlight]
    }

    static var withoutDev: [BuildSource] {
        [.production, .testAdhoc, .testTestFlight]
    }

    static var devCases: [BuildSource] {
        [.devAdhoc, .devTestFlight]
    }

    static var testCases: [BuildSource] {
        [.testAdhoc, .testTestFlight]
    }

    var name: String {
        switch self {
        case .production: "Production"
        case .devAdhoc: "Dev Adhoc"
        case .devTestFlight: "Dev TestFlight"
        case .testAdhoc: "Test Adhoc"
        case .testTestFlight: "Test TestFlight"
        }
    }

    var badgeType: BadgeType {
        switch self {
        case .production: .production
        case .devAdhoc, .devTestFlight: .dev
        case .testAdhoc, .testTestFlight: .test
        }
    }
}

// MARK: - Badge Type

enum BadgeType {
    case production
    case dev
    case test
}
