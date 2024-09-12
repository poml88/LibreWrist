//
//  LibreLinkUpError.swift
//  LibreWrist
//
//  Created by Peter Müller on 10.09.24.
//

import Foundation

enum LibreLinkUpError: LocalizedError {
    case noConnection
    case notAuthenticated
    case jsonDecoding

    var errorDescription: String? {
        switch self {
        case .noConnection:     "no connection"
        case .notAuthenticated: "not authenticated"
        case .jsonDecoding:     "JSON decoding"
        }
    }
}
