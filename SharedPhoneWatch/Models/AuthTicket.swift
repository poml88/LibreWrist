//
//  AuthTicket.swift
//  LibreWrist
//
//  Created by Peter Müller on 10.09.24.
//

import Foundation

struct AuthTicket: Codable {
    let token: String
    let expires: Int
    let duration: UInt64
}
