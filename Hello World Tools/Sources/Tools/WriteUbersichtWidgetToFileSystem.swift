//
//  ToolA.swift
//  Hello World Tools
//
//  Created by mike on 15/07/2025.
//

import Foundation
import FoundationModels
import SwiftUI
import UniformTypeIdentifiers
import ChatCore

final class WriteUbersichtWidgetToFileSystem: Tool {
    let name = "WriteUbersichtWidgetToFileSystem"
    let description = "Writes an Übersicht Widget to the file system. Call this tool as the last step in processing a prompt that generates a widget."
    
    private let directory = "/Users/mike/Library/Application Support/Übersicht/widgets/hwta"
    
    @Generable
    struct Arguments: Codable {

        @Guide(description: """
        Complete JSX code for an Übersicht widget. This should include all required exports: command, refreshFrequency, render, and className.
        The JSX should be a complete, valid Übersicht widget file.
        """)
        let jsxContent: String
    }
    
    func call(arguments: Arguments) async throws -> String {
        let callId = UUID().uuidString.prefix(8)
        print("🔧 TOOL CALL #\(callId) - WriteUbersichtWidgetToFileSystem")
        print("   📄 JSX Content: \(arguments.jsxContent.count) characters")
        
        do {
            // Create the directory if it doesn't exist
            let fileManager = FileManager.default
            try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            print("📁 DIRECTORY CREATED #\(callId): \(directory)")
            
            let filePath = "\(directory)/index.jsx"
            print("💾 SAVING FILE #\(callId) to: \(filePath)")
            try arguments.jsxContent.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
            print("✅ FILE SAVED #\(callId) successfully")
            return "Widget JSX script saved to: \(filePath)"
        } catch {
            print("❌ FILE SAVE FAILED #\(callId): \(error.localizedDescription)")
            return "Widget JSX script failed to save: \(error.localizedDescription)"
        }
    }
    
    
    
    // MARK: - File Operations
    
    // File operations now handled by FilePickerUtility in ChatCore
    
    // MARK: - JSX Generation
    
    // Custom error types for the tool
    enum ToolSendWidgetToOutputError: LocalizedError {
        case emptyJsxContent
        case unexpectedError(Error)
        case fileWriteError(Error)
        
        var errorDescription: String? {
            switch self {
            case .emptyJsxContent:
                return "JSX content cannot be empty"
            case .unexpectedError(let error):
                return "Unexpected error: \(error.localizedDescription)"
            case .fileWriteError(let error):
                return "Error writing file: \(error.localizedDescription)"
            }
        }
    }
} 


