//
//  MultiTurnConversationTests.swift
//  Hello World ToolsTests
//
//  Tests whether LanguageModelSession maintains conversation state across multiple turns
//

import Testing
import Foundation
import FoundationModels
import ChatCore
@testable import Hello_World_Tools

struct MultiTurnConversationTests {
    
    /// Test if LanguageModelSession maintains conversation state with base model
    @Test("Test base model multi-turn conversation")
    func testBaseModelMultiTurn() async throws {
        try await runMultiTurnTest(modelType: .base, systemPrompt: .systemPrompt_v4)
    }
    
    /// Test if LanguageModelSession maintains conversation state with adapter model
    @Test("Test adapter model multi-turn conversation")
    func testAdapterModelMultiTurn() async throws {
        let adapterURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
        try await runMultiTurnTest(modelType: .adapter(adapterURL), systemPrompt: .systemPrompt_v4)
    }
    
    /// Test if passing instructions explicitly to adapter changes behavior or token usage
    @Test("Test adapter model with explicit instructions")
    func testAdapterModelWithExplicitInstructions() async throws {
        let adapterURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
        
        print("\n🔬 TESTING ADAPTER WITH EXPLICIT INSTRUCTIONS")
        print("🔬 This test checks if passing instructions to an adapter that was")
        print("🔬 already trained with instructions changes behavior or token usage")
        
        // Test 1: Adapter WITHOUT explicit instructions (current approach)
        print("\n📝 Test 1: Adapter session WITHOUT explicit instructions")
        let adapterWithoutInstructions = try createAdapterSession(
            adapterURL: adapterURL,
            instructions: nil
        )
        
        let prompt1 = "generate a widget that says \"hello world\""
        let response1 = try await adapterWithoutInstructions.respond(to: prompt1)
        let transcript1 = Array(response1.transcriptEntries)
        let toolCalled1 = transcript1.contains { entry in
            String(describing: entry).contains("WriteUbersichtWidgetToFileSystem")
        }
        
        print("✅ Response received (length: \(response1.content.count) chars)")
        print("✅ Tool called: \(toolCalled1)")
        
        // Test 2: Adapter WITH explicit instructions
        print("\n📝 Test 2: Adapter session WITH explicit instructions")
        let adapterWithInstructions = try createAdapterSession(
            adapterURL: adapterURL,
            instructions: Constants.Prompts.systemPrompt_v4
        )
        
        let prompt2 = "generate a widget that says \"hello world\""
        let response2 = try await adapterWithInstructions.respond(to: prompt2)
        let transcript2 = Array(response2.transcriptEntries)
        let toolCalled2 = transcript2.contains { entry in
            String(describing: entry).contains("WriteUbersichtWidgetToFileSystem")
        }
        
        print("✅ Response received (length: \(response2.content.count) chars)")
        print("✅ Tool called: \(toolCalled2)")
        
        // Compare results
        print("\n📊 COMPARISON:")
        print("📊 Without instructions - Response length: \(response1.content.count) chars, Tool called: \(toolCalled1)")
        print("📊 With instructions - Response length: \(response2.content.count) chars, Tool called: \(toolCalled2)")
        
        let responseLengthDiff = response2.content.count - response1.content.count
        print("📊 Response length difference: \(responseLengthDiff) chars")
        
        // Check if both work
        #expect(toolCalled1, "Adapter without instructions should call tool")
        #expect(toolCalled2, "Adapter with instructions should call tool")
        
        // Note: We can't directly measure token usage, but we can observe behavior
        if responseLengthDiff > 100 {
            print("⚠️ WARNING: Response with instructions is significantly longer")
            print("⚠️ This might indicate instructions are consuming additional tokens")
        } else if responseLengthDiff < -100 {
            print("⚠️ WARNING: Response with instructions is significantly shorter")
            print("⚠️ This might indicate different behavior")
        } else {
            print("✅ Response lengths are similar - instructions may not significantly affect token usage")
        }
        
        print("\n💡 CONCLUSION:")
        print("💡 If both work similarly, explicit instructions may not add significant overhead")
        print("💡 If there's a big difference, instructions might be consuming extra tokens")
    }
    
    /// Create an adapter session with optional explicit instructions
    private func createAdapterSession(
        adapterURL: URL,
        instructions: String?
    ) throws -> LanguageModelSession {
        let tools = [WriteUbersichtWidgetToFileSystem()]
        let adapter = try SystemLanguageModel.Adapter(fileURL: adapterURL)
        let customAdapterModel = SystemLanguageModel(adapter: adapter)
        
        if let instructions = instructions {
            // Try to pass instructions explicitly
            return LanguageModelSession(
                model: customAdapterModel,
                tools: tools,
                instructions: instructions
            )
        } else {
            // No instructions (current approach)
            return LanguageModelSession(
                model: customAdapterModel,
                tools: tools
            )
        }
    }
    
    /// Run a multi-turn conversation test
    private func runMultiTurnTest(
        modelType: ModelType,
        systemPrompt: SystemPromptVersion
    ) async throws {
        // Create a single session that will be reused for both turns
        let session = try SessionFactory.createSession(
            modelType: modelType,
            systemPrompt: systemPrompt
        )
        
        print("\n🔄 MULTI-TURN CONVERSATION TEST")
        print("🔄 Model Type: \(modelType)")
        print("🔄 System Prompt: \(systemPrompt.rawValue)")
        
        // TURN 1: Initial widget creation
        print("\n📝 TURN 1: Creating initial widget")
        let firstPrompt = "generate a widget that says \"abc as easy as 123\""
        print("📝 User: \(firstPrompt)")
        
        let firstResponse = try await session.respond(to: firstPrompt)
        let firstContent = firstResponse.content
        let firstTranscript = Array(firstResponse.transcriptEntries)
        
        print("📥 Assistant: \(firstContent.prefix(200))...")
        
        // Extract JSX from first turn
        let firstJSX = extractJSXFromTranscript(firstTranscript)
        print("📄 First JSX extracted: \(firstJSX?.prefix(100) ?? "None")...")
        
        // Verify first turn succeeded
        let firstToolCalled = firstTranscript.contains { entry in
            String(describing: entry).contains("WriteUbersichtWidgetToFileSystem")
        }
        
        #expect(firstToolCalled, "First turn should call the tool")
        #expect(firstJSX != nil, "First turn should generate JSX content")
        
        // TURN 2: Follow-up instruction
        print("\n📝 TURN 2: Follow-up instruction")
        let secondPrompt = "move it to the top-right corner"
        print("📝 User: \(secondPrompt)")
        
        let secondResponse = try await session.respond(to: secondPrompt)
        let secondContent = secondResponse.content
        let secondTranscript = Array(secondResponse.transcriptEntries)
        
        print("📥 Assistant: \(secondContent.prefix(200))...")
        
        // Extract JSX from second turn
        let secondJSX = extractJSXFromTranscript(secondTranscript)
        print("📄 Second JSX extracted: \(secondJSX?.prefix(100) ?? "None")...")
        
        // Analyze results
        let secondToolCalled = secondTranscript.contains { entry in
            String(describing: entry).contains("WriteUbersichtWidgetToFileSystem")
        }
        
        print("\n📊 ANALYSIS:")
        print("📊 First turn tool called: \(firstToolCalled)")
        print("📊 Second turn tool called: \(secondToolCalled)")
        print("📊 First JSX length: \(firstJSX?.count ?? 0) chars")
        print("📊 Second JSX length: \(secondJSX?.count ?? 0) chars")
        
        // Check if second response shows understanding of context
        let understandsContext = secondContent.lowercased().contains("top") ||
                                 secondContent.lowercased().contains("right") ||
                                 secondContent.lowercased().contains("corner") ||
                                 (secondJSX?.contains("top") == true && secondJSX?.contains("right") == true)
        
        print("📊 Second response mentions position: \(understandsContext)")
        
        // Check if JSX was modified
        let jsxModified = secondJSX != nil && firstJSX != nil && secondJSX != firstJSX
        print("📊 JSX was modified in second turn: \(jsxModified)")
        
        if let firstJSX = firstJSX, let secondJSX = secondJSX {
            print("\n📄 FIRST JSX:")
            print(firstJSX)
            print("\n📄 SECOND JSX:")
            print(secondJSX)
            
            // Check if className was updated to top-right
            let hasTopRight = secondJSX.contains("top:") && 
                             (secondJSX.contains("right:") || secondJSX.contains("right :"))
            print("📊 Second JSX has top-right positioning: \(hasTopRight)")
        }
        
        // Determine if conversation state is maintained
        if understandsContext && secondToolCalled {
            print("\n✅ CONVERSATION STATE MAINTAINED")
            print("✅ Model understood the follow-up instruction and called the tool")
        } else if understandsContext && !secondToolCalled {
            print("\n⚠️ PARTIAL CONTEXT: Model understood but didn't call tool")
            print("⚠️ Response: \(secondContent)")
        } else {
            print("\n❌ NO CONVERSATION STATE: Model didn't understand the follow-up")
            print("❌ Response: \(secondContent)")
            print("❌ This suggests LanguageModelSession is stateless")
        }
        
        // Assertions
        // Note: If this fails, LanguageModelSession may not maintain conversation state
        print("📊 Second response content: \(secondContent)")
        #expect(understandsContext, "Second turn should understand context (mentions 'top', 'right', or 'corner')")
        
        if understandsContext {
            #expect(secondToolCalled, "If context is understood, tool should be called to update the widget")
        }
    }
    
    /// Extract JSX content from transcript entries
    private func extractJSXFromTranscript(_ transcriptEntries: [Any]) -> String? {
        for entry in transcriptEntries {
            let entryString = String(describing: entry)
            let isToolCall = entryString.contains("WriteUbersichtWidgetToFileSystem") ||
                           entryString.contains("ToolCalls")
            
            if isToolCall {
                // Try to extract JSX content using reflection
                let entryMirror = Mirror(reflecting: entry)
                for child in entryMirror.children {
                    if let label = child.label,
                       (label.contains("jsx") || label.contains("jsxContent") || label.contains("argument")) {
                        let valueString = String(describing: child.value)
                        
                        // Look for jsxContent in the string representation
                        if valueString.contains("jsxContent") {
                            // Try to extract the actual content
                            if let contentRange = valueString.range(of: "jsxContent") {
                                let afterLabel = String(valueString[contentRange.upperBound...])
                                // Look for the content after the label
                                if let quoteRange = afterLabel.range(of: "\"") ?? afterLabel.range(of: "'") {
                                    let contentStart = afterLabel.index(after: quoteRange.lowerBound)
                                    // Find the end quote (simplified - might need more sophisticated parsing)
                                    if let endQuoteRange = afterLabel[contentStart...].range(of: "\"") ?? afterLabel[contentStart...].range(of: "'") {
                                        var extracted = String(afterLabel[contentStart..<endQuoteRange.lowerBound])
                                        // Unescape newlines
                                        extracted = extracted.replacingOccurrences(of: "\\n", with: "\n")
                                        return extracted
                                    }
                                }
                            }
                        }
                        
                        // Fallback: try JSON parsing if it looks like JSON
                        if valueString.contains("{") && valueString.contains("jsxContent") {
                            // Try to parse as JSON
                            if let jsonData = valueString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                               let jsxContent = json["jsxContent"] as? String {
                                return jsxContent
                            }
                        }
                    }
                }
            }
        }
        
        // Fallback: try reading from the saved file
        let widgetPath = "/Users/mike/Library/Application Support/Übersicht/widgets/hwta/index.jsx"
        if let fileContent = try? String(contentsOfFile: widgetPath, encoding: .utf8) {
            return fileContent
        }
        
        return nil
    }
}

// MARK: - Note
// This test uses ModelType, SystemPromptVersion, and SessionFactory
// which are already defined in LanguageModelComparisonTests.swift
// Since all test files are in the same module, they can access these types directly

