//
//  File.swift
//  LibreWrist
//
//  Created by Peter Müller on 10.10.24.
//



import AppIntents

struct ReloadWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Reload widget"
    static var description = IntentDescription("Reload widget.")

    init() {}

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
