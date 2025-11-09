//
//  ToolsEnabledAIService.swift
//  Hello World Tools
//
//  Created by mike on 15/07/2025.
//

import Foundation
import FoundationModels
import ChatCore
import SwiftUI
import Combine
import Playgrounds

public final class ToolsEnabledAIService: AIServiceProtocol, @unchecked Sendable {
    @Published public var isLoading = false
    @Published public var lastError: String?
    
    private let session: LanguageModelSession
    
    public init() {

        do
        {
            let useAdapter = true // Set this based on your needs

            if useAdapter {
                // The absolute path to your adapter.
                let localURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
                
                // An instance of the the system language model using your adapter.
                let adapter = try SystemLanguageModel.Adapter(fileURL: localURL)
                
                // An instance of the the system language model using your adapter.
                let customAdapterModel = SystemLanguageModel(adapter: adapter)
                session = LanguageModelSession(
                    model: customAdapterModel,
                    tools: [WriteUbersichtWidgetToFileSystem(),
    //                        ListDataSourcesTool()
                        ]
                )
            }
            else {
                session = LanguageModelSession(
                    tools: [WriteUbersichtWidgetToFileSystem()],
/*                    instructions: Constants.Prompts.humanRolePrompt2 */
                    instructions: Constants.Prompts.systemPrompt_v4
                )
            }
            session.prewarm()
        } catch {
            fatalError("Failed to create session with adapter: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func sendMessage(_ input: String) async -> String? {
        isLoading = true
        lastError = nil
        
        do {
            let response = try await session.respond(to: input)
            
            // Log comprehensive response information
            print("📥 Response received from session")
            print("📥 Response type: \(type(of: response))")
            print("📥 Response content length: \(response.content.count) characters")
            print("📥 Response content preview (first 200 chars): \(String(response.content.prefix(200)))")
            print("📥 Response content preview (last 200 chars): \(String(response.content.suffix(200)))")
            
            // Compare rawContent vs content to see if there's any difference
            let rawContentString = String(describing: response.rawContent)
            print("📥 Raw content type: \(type(of: response.rawContent))")
            print("📥 Raw content string length: \(rawContentString.count) characters")
            if rawContentString != response.content {
                print("⚠️ WARNING: rawContent differs from content!")
                print("📥 Raw content preview (first 200 chars): \(String(rawContentString.prefix(200)))")
                print("📥 Raw content preview (last 200 chars): \(String(rawContentString.suffix(200)))")
            } else {
                print("📥 rawContent matches content")
            }
            
            // Log full response object details
            print("📥 Full response object: \(response)")
            
            // Check for any truncation indicators
            if let responseString = String(describing: response) as String? {
                print("📥 Response string representation length: \(responseString.count) characters")
            }
            
            // Log any additional properties if available
            let mirror = Mirror(reflecting: response)
            print("📥 Response properties:")
            for child in mirror.children {
                if let label = child.label {
                    print("📥   - \(label): \(child.value)")
                }
            }
            
            // Log detailed transcript entries to understand tool calls
            print("📋 TRANSCRIPT ENTRIES ANALYSIS:")
            print("📋 Total transcript entries: \(response.transcriptEntries.count)")
            for (index, entry) in response.transcriptEntries.enumerated() {
                print("📋 Entry #\(index):")
                print("📋   Type: \(type(of: entry))")
                print("📋   String representation: \(String(describing: entry))")
                
                // Try to extract tool call information
                let entryMirror = Mirror(reflecting: entry)
                print("📋   Entry properties:")
                for child in entryMirror.children {
                    if let label = child.label {
                        let valueString = String(describing: child.value)
                        // Truncate very long values for readability
                        let displayValue = valueString.count > 500 ? String(valueString.prefix(500)) + "..." : valueString
                        print("📋     - \(label): \(displayValue)")
                        
                        // If this looks like tool call arguments, log it in detail
                        if label.contains("argument") || label.contains("Argument") || label.contains("jsx") || label.contains("jsxContent") {
                            print("📋     🔍 DETAILED \(label) ANALYSIS:")
                            print("📋     🔍   Full value length: \(valueString.count) characters")
                            print("📋     🔍   Full value: \(valueString)")
                        }
                    }
                }
                print("📋   ---")
            }
            
            isLoading = false
            return response.content
        } catch {
            isLoading = false
            
            // Handle specific model availability error
            if let generationError = error as? LanguageModelSession.GenerationError {
                switch generationError {
                case .assetsUnavailable:
                    lastError = "AI model is not available. Please download the model in System Settings > AI."
                default:
                    lastError = "AI Error: \(generationError.localizedDescription)"
                }
            } else {
                lastError = "Failed to send message: \(error.localizedDescription)"
            }
            
            print("❌ AI Error: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error description: \(error.localizedDescription)")
            
            // Log more details for debugging content safety issues
            if error.localizedDescription.contains("unsafe") || error.localizedDescription.contains("content") {
                print("🔍 DEBUG: Potential content safety issue detected")
                print("🔍 DEBUG: Input that triggered error: \(input)")
                print("🔍 DEBUG: Full error details: \(error)")
            }
            
            return nil
        }
    }
}
