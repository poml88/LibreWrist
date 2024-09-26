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
    case touNotAccepted

    var errorDescription: String? {
        switch self {
        case .noConnection:     "No connection."
        case .notAuthenticated: "Not authenticated. Check credentials."
        case .jsonDecoding:     "JSON decoding error."
        case .touNotAccepted:   "Terms of Use were updated. Open LibreLinkUp App, log in, and accept Terms of Use."
        }
    }
}
