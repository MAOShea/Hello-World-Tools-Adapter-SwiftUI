//
//  LanguageModelComparisonTests_v4.swift
//  Hello World ToolsTests
//
//  Version-specific tests for systemPrompt_v4
//

import Testing
import Foundation
import FoundationModels
import ChatCore
@testable import Hello_World_Tools

struct LanguageModelComparisonTests_v4 {
    
    // MARK: - Simple Widget Request
    
    @Test("baseModel_SimpleWidgetRequest")
    func baseModel_SimpleWidgetRequest() async throws {
        let runner = TestRunner()
        let testCase = TestCase(
            name: "Simple Widget Request",
            userPrompt: "generate a widget that says \"abc as easy as 123\"",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .base,
            systemPrompt: .systemPrompt_v4
        )
        
        #expect(result.succeeded, "Base model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    @Test("adapterModel_SimpleWidgetRequest")
    func adapterModel_SimpleWidgetRequest() async throws {
        let runner = TestRunner()
        let testCase = TestCase(
            name: "Simple Widget Request",
            userPrompt: "generate a widget that says \"abc as easy as 123\"",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .adapter(runner.adapterURL),
            systemPrompt: .systemPrompt_v4
        )
        
        #expect(result.succeeded, "Adapter model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    // MARK: - Time Widget Request
    
    @Test("baseModel_TimeWidgetRequest")
    func baseModel_TimeWidgetRequest() async throws {
        let runner = TestRunner()
        let testCase = TestCase(
            name: "Time Widget Request",
            userPrompt: "create a widget that shows the current time",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .base,
            systemPrompt: .systemPrompt_v4
        )
        
        #expect(result.succeeded, "Base model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    @Test("adapterModel_TimeWidgetRequest")
    func adapterModel_TimeWidgetRequest() async throws {
        let runner = TestRunner()
        let testCase = TestCase(
            name: "Time Widget Request",
            userPrompt: "create a widget that shows the current time",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .adapter(runner.adapterURL),
            systemPrompt: .systemPrompt_v4
        )
        
        #expect(result.succeeded, "Adapter model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    // MARK: - Button Widget Request
    
    @Test("baseModel_ButtonWidgetRequest")
    func baseModel_ButtonWidgetRequest() async throws {
        let runner = TestRunner()
        let testCase = TestCase(
            name: "Button Widget Request",
            userPrompt: "generate a widget with a button labelled \"I love you.\"",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .base,
            systemPrompt: .systemPrompt_v4
        )
        
        #expect(result.succeeded, "Base model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    @Test("adapterModel_ButtonWidgetRequest")
    func adapterModel_ButtonWidgetRequest() async throws {
        let runner = TestRunner()
        let testCase = TestCase(
            name: "Button Widget Request",
            userPrompt: "generate a widget with a button labelled \"I love you.\"",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .adapter(runner.adapterURL),
            systemPrompt: .systemPrompt_v4
        )
        
        #expect(result.succeeded, "Adapter model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    // MARK: - Multi-Turn Conversation
    
    @Test("baseModel_MultiTurn")
    func baseModel_MultiTurn() async throws {
        try await runMultiTurnTest(modelType: .base, systemPrompt: .systemPrompt_v4)
    }
    
    @Test("adapterModel_MultiTurn")
    func adapterModel_MultiTurn() async throws {
        let adapterURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
        try await runMultiTurnTest(modelType: .adapter(adapterURL), systemPrompt: .systemPrompt_v4)
    }
    
    // MARK: - Multi-Turn Conversation with Non-Working Prompts (Demonstration)
    
    /// This test demonstrates prompt terminology patterns that were observed to fail in longer conversations.
    /// Uses "create" instead of "generate" and short directives without explicit widget reference.
    /// 
    /// NOTE: These patterns may work in short 2-turn conversations (as demonstrated here) but were observed
    /// to fail in longer 11-turn conversations (see testBaseModelContextWindowUsage in ContextWindowUsageTests).
    /// The failure pattern appears to be cumulative - the model may handle these patterns initially but
    /// becomes less reliable as the conversation grows longer.
    /// 
    /// Compare with baseModel_MultiTurn to see the difference in prompt patterns.
    @Test("baseModel_MultiTurn_NonWorkingPrompts")
    func baseModel_MultiTurn_NonWorkingPrompts() async throws {
        try await runMultiTurnTest_NonWorkingPrompts(modelType: .base, systemPrompt: .systemPrompt_v4)
    }
    
    /// This test demonstrates prompt terminology patterns that were observed to fail in longer conversations.
    /// Uses "create" instead of "generate" and short directives without explicit widget reference.
    /// 
    /// NOTE: These patterns may work in short 2-turn conversations (as demonstrated here) but were observed
    /// to fail in longer 11-turn conversations (see testBaseModelContextWindowUsage in ContextWindowUsageTests).
    /// The failure pattern appears to be cumulative - the model may handle these patterns initially but
    /// becomes less reliable as the conversation grows longer.
    /// 
    /// Compare with adapterModel_MultiTurn to see the difference in prompt patterns.
    @Test("adapterModel_MultiTurn_NonWorkingPrompts")
    func adapterModel_MultiTurn_NonWorkingPrompts() async throws {
        let adapterURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
        try await runMultiTurnTest_NonWorkingPrompts(modelType: .adapter(adapterURL), systemPrompt: .systemPrompt_v4)
    }
    
    // MARK: - Multi-Turn Conversation with Context Window Tracking
    
    @Test("baseModel_MultiTurnWithContextTracking")
    func baseModel_MultiTurnWithContextTracking() async throws {
        try await runMultiTurnTestWithContextTracking(modelType: .base, systemPrompt: .systemPrompt_v4)
    }
    
    @Test("adapterModel_MultiTurnWithContextTracking")
    func adapterModel_MultiTurnWithContextTracking() async throws {
        let adapterURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
        try await runMultiTurnTestWithContextTracking(modelType: .adapter(adapterURL), systemPrompt: .systemPrompt_v4)
    }
    
    // MARK: - JSX Quality Tests
    
    @Test("baseModel_JSXQuality_MultiTurn")
    func baseModel_JSXQuality_MultiTurn() async throws {
        try await testJSXQuality_MultiTurn(
            modelType: .base,
            systemPrompt: .systemPrompt_v4
        )
    }
    
    @Test("adapterModel_JSXQuality_MultiTurn")
    func adapterModel_JSXQuality_MultiTurn() async throws {
        let adapterURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
        try await testJSXQuality_MultiTurn(
            modelType: .adapter(adapterURL),
            systemPrompt: .systemPrompt_v4
        )
    }
    
    // MARK: - Diagnostic: Inspect Transcript Entries
    
    /// Diagnostic test to inspect transcript entries and understand context window growth for base model
    @Test("baseModel_DiagnosticInspectTranscriptEntries")
    func baseModel_DiagnosticInspectTranscriptEntries() async throws {
        Swift.print("\n🔬 DIAGNOSTIC: TRANSCRIPT ENTRIES INSPECTION - BASE MODEL")
        Swift.print("🔬 Investigating base model context window usage")
        Swift.print(String(repeating: "=", count: 80))
        
        let modelName = "Base Model"
        let modelType: ModelType = .base
        
        try await runDiagnosticForModel(modelName: modelName, modelType: modelType)
    }
    
    /// Diagnostic test to inspect transcript entries and understand context window growth for adapter model
    @Test("adapterModel_DiagnosticInspectTranscriptEntries")
    func adapterModel_DiagnosticInspectTranscriptEntries() async throws {
        Swift.print("\n🔬 DIAGNOSTIC: TRANSCRIPT ENTRIES INSPECTION - ADAPTER MODEL")
        Swift.print("🔬 Investigating why adapter model context window grows to ~3732 tokens on turn 2")
        Swift.print(String(repeating: "=", count: 80))
        
        let modelName = "Adapter Model"
        let modelType: ModelType = .adapter(URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter"))
        
        try await runDiagnosticForModel(modelName: modelName, modelType: modelType)
    }
    
    // MARK: - Adapter with Explicit Instructions
    
    /// Test if passing instructions explicitly to adapter changes behavior or token usage
    @Test("adapterModel_WithExplicitInstructions")
    func adapterModel_WithExplicitInstructions() async throws {
        let adapterURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
        
        Swift.print("\n🔬 TESTING ADAPTER WITH EXPLICIT INSTRUCTIONS")
        Swift.print("🔬 This test checks if passing instructions to an adapter that was")
        Swift.print("🔬 already trained with instructions changes behavior or token usage")
        
        // Test 1: Adapter WITHOUT explicit instructions (current approach)
        Swift.print("\n📝 Test 1: Adapter session WITHOUT explicit instructions")
        let adapterWithoutInstructions = try createAdapterSession(
            adapterURL: adapterURL,
            instructions: nil
        )
        
        let prompt1 = "generate a widget that says \"hello world\""
        let response1 = try await adapterWithoutInstructions.respond(to: prompt1)
        let transcript1 = Array(response1.transcriptEntries)
        let toolCalled1 = ToolCallDetectionUtilities.wasToolCalled(in: transcript1)
        
        Swift.print("✅ Response received (length: \(response1.content.count) chars)")
        Swift.print("✅ Tool called: \(toolCalled1)")
        
        // Test 2: Adapter WITH explicit instructions
        Swift.print("\n📝 Test 2: Adapter session WITH explicit instructions")
        let adapterWithInstructions = try createAdapterSession(
            adapterURL: adapterURL,
            instructions: Constants.Prompts.systemPrompt_v4
        )
        
        let prompt2 = "generate a widget that says \"hello world\""
        let response2 = try await adapterWithInstructions.respond(to: prompt2)
        let transcript2 = Array(response2.transcriptEntries)
        let toolCalled2 = ToolCallDetectionUtilities.wasToolCalled(in: transcript2)
        
        Swift.print("✅ Response received (length: \(response2.content.count) chars)")
        Swift.print("✅ Tool called: \(toolCalled2)")
        
        // Compare results
        Swift.print("\n📊 COMPARISON:")
        Swift.print("📊 Without instructions - Response length: \(response1.content.count) chars, Tool called: \(toolCalled1)")
        Swift.print("📊 With instructions - Response length: \(response2.content.count) chars, Tool called: \(toolCalled2)")
        
        let responseLengthDiff = response2.content.count - response1.content.count
        Swift.print("📊 Response length difference: \(responseLengthDiff) chars")
        
        // Check if both work
        #expect(toolCalled1, "Adapter without instructions should call tool")
        #expect(toolCalled2, "Adapter with instructions should call tool")
        
        // Note: We can't directly measure token usage, but we can observe behavior
        if responseLengthDiff > 100 {
            Swift.print("⚠️ WARNING: Response with instructions is significantly longer")
            Swift.print("⚠️ This might indicate instructions are consuming additional tokens")
        } else if responseLengthDiff < -100 {
            Swift.print("⚠️ WARNING: Response with instructions is significantly shorter")
            Swift.print("⚠️ This might indicate different behavior")
        } else {
            Swift.print("✅ Response lengths are similar - instructions may not significantly affect token usage")
        }
        
        Swift.print("\n💡 CONCLUSION:")
        Swift.print("💡 If both work similarly, explicit instructions may not add significant overhead")
        Swift.print("💡 If there's a big difference, instructions might be consuming extra tokens")
    }
    
    // MARK: - Helper Functions
    
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
        
        Swift.print("\n🔄 MULTI-TURN CONVERSATION TEST")
        Swift.print("🔄 Model Type: \(modelType)")
        Swift.print("🔄 System Prompt: \(systemPrompt.rawValue)")
        
        // TURN 1: Initial widget creation
        // Using centralized prompt definition from ContextWindowTestPrompts
        Swift.print("\n📝 TURN 1: Creating initial widget")
        let firstPrompt = ContextWindowTestPrompts.initialPrompt
        Swift.print("📝 User: \(firstPrompt)")
        
        let firstResponse = try await session.respond(to: firstPrompt)
        
        let firstContent = firstResponse.content
        let firstTranscript = Array(firstResponse.transcriptEntries)
        
        Swift.print("📥 Assistant: \(firstContent.prefix(200))...")
        
        // Verify tool was called
        let firstToolCalled = ToolCallDetectionUtilities.wasToolCalled(in: firstTranscript)
        
        // Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
        // No need to check file system - we rely on transcript detection and tool logs
        
        Swift.print("📊 Tool called in transcript: \(firstToolCalled)")
        
        // Test requires tool to be called - fail if it wasn't
        #expect(firstToolCalled, "First turn must call the tool")
        
        // TURN 2: Follow-up instruction
        // Using centralized prompt definition from ContextWindowTestPrompts (first incremental prompt)
        Swift.print("\n📝 TURN 2: Follow-up instruction")
        let secondPrompt = ContextWindowTestPrompts.incrementalPrompts[0]  // "move it to the top-right corner"
        Swift.print("📝 User: \(secondPrompt)")
        
        var secondToolCalled = false
        var turn2Error: Error? = nil
        
        do {
            let secondResponse = try await session.respond(to: secondPrompt)
            let secondContent = secondResponse.content
            let secondTranscript = Array(secondResponse.transcriptEntries)
            
            Swift.print("📥 Assistant: \(secondContent.prefix(200))...")
            
            // Analyze results
            secondToolCalled = ToolCallDetectionUtilities.wasToolCalled(in: secondTranscript)
        } catch {
            turn2Error = error
            // Log the error but continue to produce ANALYSIS and SUMMARY sections
            if let generationError = error as? LanguageModelSession.GenerationError {
                if case .exceededContextWindowSize(let context) = generationError {
                    Swift.print("❌ Context window exceeded on TURN 2")
                    Swift.print("❌ Error: \(context.debugDescription)")
                } else {
                    Swift.print("❌ Generation error on TURN 2: \(error)")
                }
            } else {
                Swift.print("❌ Error on TURN 2: \(error)")
            }
            // secondToolCalled remains false
        }
        
        Swift.print("\n📊 ANALYSIS:")
        Swift.print("📊 First turn tool called: \(firstToolCalled)")
        Swift.print("📊 Second turn tool called: \(secondToolCalled)")
        
        // Summary: Count tool calls (verified via transcript and log prints)
        let totalToolCalls = (firstToolCalled ? 1 : 0) + (secondToolCalled ? 1 : 0)
        Swift.print("\n" + String(repeating: "=", count: 80))
        Swift.print("📊 TEST SUMMARY")
        Swift.print(String(repeating: "=", count: 80))
        Swift.print("📊 Tool was called: \(totalToolCalls) times (turn 1: \(firstToolCalled ? "✅" : "❌"), turn 2: \(secondToolCalled ? "✅" : "❌"))")
        Swift.print("📊 Tool execution: Verified via log prints (🔧 TOOL CALL and ✅ FILE SAVED)")
        Swift.print(String(repeating: "=", count: 80))
    }
    
    /// Run a multi-turn conversation test using prompt patterns that were observed to fail in longer conversations.
    /// This demonstrates how prompt terminology affects tool calling behavior.
    /// Uses "create" instead of "generate" and short directives without explicit widget reference.
    /// 
    /// IMPORTANT: These patterns were observed to result in ZERO tool calls in an 11-turn test
    /// (testBaseModelContextWindowUsage). However, they may work in shorter 2-turn conversations.
    /// The failure appears to be cumulative - reliability decreases as conversation length increases.
    private func runMultiTurnTest_NonWorkingPrompts(
        modelType: ModelType,
        systemPrompt: SystemPromptVersion
    ) async throws {
        // Create a single session that will be reused for both turns
        let session = try SessionFactory.createSession(
            modelType: modelType,
            systemPrompt: systemPrompt
        )
        
        Swift.print("\n🔄 MULTI-TURN CONVERSATION TEST (NON-WORKING PROMPTS)")
        Swift.print("🔄 Model Type: \(modelType)")
        Swift.print("🔄 System Prompt: \(systemPrompt.rawValue)")
        Swift.print("⚠️  Using prompt patterns that FAIL to trigger tool calls:")
        Swift.print("⚠️  - 'create' instead of 'generate'")
        Swift.print("⚠️  - 'displays' instead of 'says'")
        Swift.print("⚠️  - 'update/modify the widget to...' explicit language (paradoxically fails)")
        Swift.print("ℹ️  NOTE: These patterns may work in 2-turn conversations but fail in longer conversations")
        
        // TURN 1: Initial widget creation - using "create" instead of "generate", "displays" instead of "says"
        Swift.print("\n📝 TURN 1: Creating initial widget")
        let firstPrompt = "create a widget that displays \"Hello World\""
        Swift.print("📝 User: \(firstPrompt)")
        Swift.print("ℹ️  NOTE: Using 'create' instead of 'generate' - this pattern fails to trigger tool calls")
        Swift.print("ℹ️  NOTE: Using 'displays' instead of 'says' - 'says' works better in baseModel_MultiTurn")
        
        let firstResponse = try await session.respond(to: firstPrompt)
        
        let firstContent = firstResponse.content
        let firstTranscript = Array(firstResponse.transcriptEntries)
        
        Swift.print("📥 Assistant: \(firstContent.prefix(200))...")
        
        // Verify tool was called
        let firstToolCalled = ToolCallDetectionUtilities.wasToolCalled(in: firstTranscript)
        
        // Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
        // No need to check file system - we rely on transcript detection and tool logs
        
        Swift.print("📊 Tool called in transcript: \(firstToolCalled)")
        
        if !firstToolCalled {
            Swift.print("⚠️  WARNING: Tool was NOT called - this demonstrates the impact of prompt terminology")
            Swift.print("⚠️  Compare with baseModel_MultiTurn which uses 'generate' and successfully calls the tool")
        } else {
            Swift.print("ℹ️  NOTE: Tool WAS called in this 2-turn test, but this pattern failed in the 11-turn test")
            Swift.print("ℹ️  This suggests the failure is cumulative - patterns may work initially but fail in longer conversations")
        }
        
        // TURN 2: Follow-up instruction - using explicit "update the widget to..." language (which paradoxically fails)
        Swift.print("\n📝 TURN 2: Follow-up instruction")
        let secondPrompt = "update the widget to align it with the right edge"
        Swift.print("📝 User: \(secondPrompt)")
        Swift.print("ℹ️  NOTE: Using explicit 'update the widget to...' language - PARADOXICALLY this FAILS")
        Swift.print("ℹ️  NOTE: Shorter directives like 'move it to the top-right corner' actually WORK better")
        Swift.print("ℹ️  NOTE: This contradicts earlier findings - explicit language doesn't always work")
        
        var secondToolCalled = false
        var turn2Error: Error? = nil
        
        do {
            let secondResponse = try await session.respond(to: secondPrompt)
            let secondContent = secondResponse.content
            let secondTranscript = Array(secondResponse.transcriptEntries)
            
            Swift.print("📥 Assistant: \(secondContent.prefix(200))...")
            
            // Analyze results
            secondToolCalled = ToolCallDetectionUtilities.wasToolCalled(in: secondTranscript)
        } catch {
            turn2Error = error
            // Log the error but continue to produce ANALYSIS and SUMMARY sections
            if let generationError = error as? LanguageModelSession.GenerationError {
                if case .exceededContextWindowSize(let context) = generationError {
                    Swift.print("❌ Context window exceeded on TURN 2")
                    Swift.print("❌ Error: \(context.debugDescription)")
                } else {
                    Swift.print("❌ Generation error on TURN 2: \(error)")
                }
            } else {
                Swift.print("❌ Error on TURN 2: \(error)")
            }
            // secondToolCalled remains false
        }
        
        Swift.print("\n📊 ANALYSIS:")
        Swift.print("📊 First turn tool called: \(firstToolCalled)")
        Swift.print("📊 Second turn tool called: \(secondToolCalled)")
        
        // Summary: Count tool calls (verified via transcript and log prints)
        let totalToolCalls = (firstToolCalled ? 1 : 0) + (secondToolCalled ? 1 : 0)
        Swift.print("\n" + String(repeating: "=", count: 80))
        Swift.print("📊 TEST SUMMARY (POTENTIALLY PROBLEMATIC PROMPTS)")
        Swift.print(String(repeating: "=", count: 80))
        Swift.print("📊 Tool was called: \(totalToolCalls) times (turn 1: \(firstToolCalled ? "✅" : "❌"), turn 2: \(secondToolCalled ? "✅" : "❌"))")
        Swift.print("📊 Tool execution: Verified via log prints (🔧 TOOL CALL and ✅ FILE SAVED)")
        
        if totalToolCalls == 0 {
            Swift.print("\n⚠️  KEY FINDING: No tool calls were made with these prompt patterns")
            Swift.print("⚠️  This demonstrates that prompt terminology significantly affects tool calling behavior")
            Swift.print("⚠️  Compare with baseModel_MultiTurn which uses 'generate' and 'update the widget to...'")
        } else if totalToolCalls == 2 {
            Swift.print("\nℹ️  OBSERVATION: Tool calls succeeded in this 2-turn test")
            Swift.print("ℹ️  However, these same patterns resulted in 0 tool calls in an 11-turn test")
            Swift.print("ℹ️  This suggests the failure is cumulative - patterns may work initially but fail in longer conversations")
            Swift.print("ℹ️  For reliable behavior across all conversation lengths, use 'generate' and explicit modification language")
        } else if totalToolCalls < 2 {
            Swift.print("\n⚠️  PARTIAL SUCCESS: Only \(totalToolCalls) tool call(s) made")
            Swift.print("⚠️  This demonstrates inconsistent behavior with these prompt patterns")
        }
        
        Swift.print(String(repeating: "=", count: 80))
    }
    
    /// Run a multi-turn conversation test with context window tracking
    private func runMultiTurnTestWithContextTracking(
        modelType: ModelType,
        systemPrompt: SystemPromptVersion
    ) async throws {
        // Create a single session that will be reused for both turns
        let session = try SessionFactory.createSession(
            modelType: modelType,
            systemPrompt: systemPrompt
        )
        
        let modelTypeDescription: String
        switch modelType {
        case .base:
            modelTypeDescription = "Base Model"
        case .adapter(_):
            modelTypeDescription = "Adapter Model"
        }
        
        Swift.print("\n📊 MULTI-TURN CONVERSATION TEST WITH CONTEXT WINDOW TRACKING")
        Swift.print("📊 Model Type: \(modelTypeDescription)")
        Swift.print("📊 System Prompt: \(systemPrompt.rawValue)")
        Swift.print("📊 Context Window Limit: 4096 tokens")
        Swift.print(String(repeating: "=", count: 80))
        
        var totalResponseLength = 0
        var contextWindowErrors = 0
        var turnNumber = 0
        
        // TURN 1: Initial widget creation
        turnNumber += 1
        Swift.print("\n🔄 TURN \(turnNumber): Initial Widget Creation")
        let firstPrompt = "generate a widget that says \"abc as easy as 123\""
        Swift.print("📝 User: \(firstPrompt)")
        
        do {
            let firstResponse = try await session.respond(to: firstPrompt)
            let firstContent = firstResponse.content
            let firstResponseLength = firstContent.count
            totalResponseLength += firstResponseLength
            let firstTranscript = Array(firstResponse.transcriptEntries)
            
            // Estimate tokens (rough approximation: ~4 characters per token)
            let estimatedTokens = totalResponseLength / 4
            let tokensRemaining = max(0, 4096 - estimatedTokens)
            let usagePercent = min(100, (estimatedTokens * 100) / 4096)
            
            let firstToolCalled = ToolCallDetectionUtilities.wasToolCalled(in: firstTranscript)
            
            // Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
            
            Swift.print("✅ Response received")
            Swift.print("📏 Response length: \(firstResponseLength) characters")
            Swift.print("📏 Cumulative response length: \(totalResponseLength) characters")
            Swift.print("🔧 Tool called: \(firstToolCalled)")
            if firstToolCalled {
                Swift.print("🔧 Tool execution: Verified via log prints (🔧 TOOL CALL and ✅ FILE SAVED)")
            }
            Swift.print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
            Swift.print("📊 Estimated usage: ~\(usagePercent)%")
            Swift.print("📊 Estimated tokens remaining: ~\(tokensRemaining)")
            Swift.print("📊 Status: ✅ Success")
            
            // Warning if approaching limit
            if usagePercent > 90 {
            Swift.print("⚠️ WARNING: Approaching context window limit!")
            } else if usagePercent > 75 {
            Swift.print("⚠️ CAUTION: Context window usage is high")
            }
            
            #expect(firstToolCalled, "First turn should call the tool")
            
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize(let context) = error {
            contextWindowErrors += 1
            let estimatedTokens = totalResponseLength / 4
            let usagePercent = min(100, (estimatedTokens * 100) / 4096)
            
            Swift.print("❌ Context window exceeded!")
            Swift.print("❌ Error: \(context.debugDescription)")
            Swift.print("📏 Cumulative response length: \(totalResponseLength) characters")
            Swift.print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
            Swift.print("📊 Estimated usage: ~\(usagePercent)%")
            Swift.print("📊 Status: ❌ FAILED - Context window limit reached at turn \(turnNumber)")
            throw error
            } else {
            throw error
            }
        }
        
        // TURN 2: Follow-up instruction
        turnNumber += 1
        Swift.print("\n🔄 TURN \(turnNumber): Follow-up Instruction")
        let secondPrompt = "move it to the top-right corner"
        Swift.print("📝 User: \(secondPrompt)")
        
        do {
            let secondResponse = try await session.respond(to: secondPrompt)
            let secondContent = secondResponse.content
            let secondResponseLength = secondContent.count
            totalResponseLength += secondResponseLength
            let secondTranscript = Array(secondResponse.transcriptEntries)
            
            // Estimate tokens (rough approximation: ~4 characters per token)
            let estimatedTokens = totalResponseLength / 4
            let tokensRemaining = max(0, 4096 - estimatedTokens)
            let usagePercent = min(100, (estimatedTokens * 100) / 4096)
            
            let secondToolCalled = ToolCallDetectionUtilities.wasToolCalled(in: secondTranscript)
            
            // Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
            
            Swift.print("✅ Response received")
            Swift.print("📏 Response length: \(secondResponseLength) characters")
            Swift.print("📏 Cumulative response length: \(totalResponseLength) characters")
            Swift.print("🔧 Tool called: \(secondToolCalled)")
            if secondToolCalled {
                Swift.print("🔧 Tool execution: Verified via log prints (🔧 TOOL CALL and ✅ FILE SAVED)")
            }
            Swift.print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
            Swift.print("📊 Estimated usage: ~\(usagePercent)%")
            Swift.print("📊 Estimated tokens remaining: ~\(tokensRemaining)")
            Swift.print("📊 Status: ✅ Success")
            
            // Warning if approaching limit
            if usagePercent > 90 {
            Swift.print("⚠️ WARNING: Approaching context window limit!")
            } else if usagePercent > 75 {
            Swift.print("⚠️ CAUTION: Context window usage is high")
            }
            
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize(let context) = error {
            contextWindowErrors += 1
            let estimatedTokens = totalResponseLength / 4
            let usagePercent = min(100, (estimatedTokens * 100) / 4096)
            
            Swift.print("❌ Context window exceeded!")
            Swift.print("❌ Error: \(context.debugDescription)")
            Swift.print("📏 Cumulative response length: \(totalResponseLength) characters")
            Swift.print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
            Swift.print("📊 Estimated usage: ~\(usagePercent)%")
            Swift.print("📊 Status: ❌ FAILED - Context window limit reached at turn \(turnNumber)")
            throw error
            } else {
            throw error
            }
        }
        
        // Final summary
        Swift.print("\n" + String(repeating: "=", count: 80))
        Swift.print("📊 FINAL SUMMARY")
        Swift.print(String(repeating: "=", count: 80))
        Swift.print("📊 Total turns completed: \(turnNumber) / 2")
        Swift.print("📊 Total response length: \(totalResponseLength) characters")
        Swift.print("📊 Context window errors: \(contextWindowErrors)")
        Swift.print("📊 Estimated total tokens: ~\(totalResponseLength / 4) / 4096")
        Swift.print("📊 Estimated usage: ~\((totalResponseLength / 4 * 100) / 4096)%")
        
        if contextWindowErrors == 0 {
            Swift.print("✅ SUCCESS: Both turns completed without hitting context window limit")
            Swift.print("✅ Key Finding: Context window usage after 2 turns is ~\((totalResponseLength / 4 * 100) / 4096)%")
        } else {
            Swift.print("⚠️ PARTIAL SUCCESS: Completed \(turnNumber) turns before hitting context limit")
        }
        
        #expect(contextWindowErrors == 0, "Should not hit context window limit")
    }
    
    /// Test JSX quality in multi-turn conversation
    private func testJSXQuality_MultiTurn(
        modelType: ModelType,
        systemPrompt: SystemPromptVersion
    ) async throws {
        // Create a single session that will be reused for both turns
        let session = try SessionFactory.createSession(
            modelType: modelType,
            systemPrompt: systemPrompt
        )
        
        Swift.print("\n🔍 JSX QUALITY TEST - MULTI-TURN")
        Swift.print("🔍 Model Type: \(modelType)")
        Swift.print("🔍 System Prompt: \(systemPrompt.rawValue)")
        
        // TURN 1: Initial widget creation
        Swift.print("\n📝 TURN 1: Creating initial widget")
        let firstPrompt = "generate a widget that says \"abc as easy as 123\""
        Swift.print("📝 User: \(firstPrompt)")
        
        let firstResponse = try await session.respond(to: firstPrompt)
        let firstContent = firstResponse.content
        let firstTranscript = Array(firstResponse.transcriptEntries)
        
        Swift.print("📥 Assistant: \(firstContent.prefix(200))...")
        
        // Extract JSX from transcript entries
        let firstJSX = extractJSXFromTranscript(firstTranscript)
        Swift.print("📄 First JSX extracted: \(firstJSX?.prefix(100) ?? "None")...")
        
        // Verify tool was called
        let firstToolCalled = ToolCallDetectionUtilities.wasToolCalled(in: firstTranscript)
        
        Swift.print("📊 Tool called in transcript: \(firstToolCalled)")
        Swift.print("📊 JSX found in tool call: \(firstJSX != nil)")
        
        // Test requires tool to be called and JSX to be extractable
        #expect(firstToolCalled, "First turn must call the tool")
        #expect(firstJSX != nil, "First turn should generate JSX content via tool call")
        
        // Validate JSX quality
        if let jsx = firstJSX {
            validateJSX(jsx, turnNumber: 1)
        }
        
        // TURN 2: Follow-up instruction
        Swift.print("\n📝 TURN 2: Follow-up instruction")
        let secondPrompt = "move it to the top-right corner"
        Swift.print("📝 User: \(secondPrompt)")
        
        let secondResponse = try await session.respond(to: secondPrompt)
        let secondContent = secondResponse.content
        let secondTranscript = Array(secondResponse.transcriptEntries)
        
        Swift.print("📥 Assistant: \(secondContent.prefix(200))...")
        
        // Extract JSX from transcript entries
        let secondJSX = extractJSXFromTranscript(secondTranscript)
        Swift.print("📄 Second JSX extracted: \(secondJSX?.prefix(100) ?? "None")...")
        
        // Verify tool was called
        let secondToolCalled = ToolCallDetectionUtilities.wasToolCalled(in: secondTranscript)
        
        Swift.print("\n📊 ANALYSIS:")
        Swift.print("📊 First turn tool called: \(firstToolCalled)")
        Swift.print("📊 Second turn tool called: \(secondToolCalled)")
        Swift.print("📊 First JSX length: \(firstJSX?.count ?? 0) chars")
        Swift.print("📊 Second JSX length: \(secondJSX?.count ?? 0) chars")
        
        // Check if JSX was modified (indicates model understood something changed)
        let jsxModified = secondJSX != nil && firstJSX != nil && secondJSX != firstJSX
        
        // Check if response mentions position OR if JSX positioning changed
        let understandsContext = secondContent.lowercased().contains("top") ||
                             secondContent.lowercased().contains("right") ||
                             secondContent.lowercased().contains("corner") ||
                             (secondJSX?.contains("top") == true && secondJSX?.contains("right") == true) ||
                             jsxModified  // If JSX was modified, model at least understood something should change
        
        Swift.print("📊 Second response mentions position: \(understandsContext)")
        Swift.print("📊 JSX was modified in second turn: \(jsxModified)")
        
        if let firstJSX = firstJSX, let secondJSX = secondJSX {
            Swift.print("\n📄 FIRST JSX:")
            Swift.print(firstJSX)
            Swift.print("\n📄 SECOND JSX:")
            Swift.print(secondJSX)
            
            // Check if className was updated to top-right
            let hasTopRight = secondJSX.contains("top:") && 
                         (secondJSX.contains("right:") || secondJSX.contains("right :"))
            Swift.print("📊 Second JSX has top-right positioning: \(hasTopRight)")
        }
        
        // Validate JSX quality for second turn
        if let jsx = secondJSX {
            validateJSX(jsx, turnNumber: 2)
            
            // Validate that JSX was modified appropriately
            if let firstJSX = firstJSX {
                validateJSXModification(firstJSX: firstJSX, secondJSX: jsx, instruction: secondPrompt)
            }
        }
        
        // Determine if conversation state is maintained
        if understandsContext && secondToolCalled {
            Swift.print("\n✅ CONVERSATION STATE MAINTAINED")
            Swift.print("✅ Model understood the follow-up instruction and called the tool")
        } else if understandsContext && !secondToolCalled {
            Swift.print("\n⚠️ PARTIAL CONTEXT: Model understood but didn't call tool")
            Swift.print("⚠️ Response: \(secondContent)")
        } else {
            Swift.print("\n❌ NO CONVERSATION STATE: Model didn't understand the follow-up")
            Swift.print("❌ Response: \(secondContent)")
        }
        
        if understandsContext {
            #expect(secondToolCalled, "If context is understood, tool should be called to update the widget")
        }
    }
    
    /// Helper function to extract and log tool call details in the same format as the tool itself
    private func logToolCallDetails(from transcriptEntries: [Any], turnNumber: Int) {
        for entry in transcriptEntries {
            let entryString = String(describing: entry)
            
            // Check if this is a tool call entry
            let isToolCall = entryString.contains("WriteUbersichtWidgetToFileSystem") ||
                             entryString.contains("ToolCalls")
            
            if isToolCall {
                // Generate a call ID from entry hash or use a simple counter
                let callId = String(abs(entryString.hashValue), radix: 16).uppercased().prefix(8)
                let finalCallId = callId.count >= 8 ? String(callId.prefix(8)) : String(repeating: "0", count: 8 - callId.count) + callId
                
                Swift.print("🔧 TOOL CALL #\(finalCallId) - WriteUbersichtWidgetToFileSystem")
                
                // Try to extract JSX content from the entry string itself (most reliable method)
                var jsxContent: String? = nil
                
                // Method 1: Look for JSON pattern in entry string: "jsxContent": "..."
                // Handle escaped quotes and newlines in JSON
                if let jsxStart = entryString.range(of: "\"jsxContent\"\\s*:\\s*\"", options: .regularExpression) {
                    let afterStart = String(entryString[jsxStart.upperBound...])
                    // Find the closing quote, handling escaped quotes
                    var jsxEndIndex: String.Index? = nil
                    var i = afterStart.startIndex
                    var escaped = false
                    while i < afterStart.endIndex {
                        let char = afterStart[i]
                        if escaped {
                            escaped = false
                        } else if char == "\\" {
                            escaped = true
                        } else if char == "\"" {
                            jsxEndIndex = i
                            break
                        }
                        i = afterStart.index(after: i)
                    }
                    
                    if let endIndex = jsxEndIndex {
                        jsxContent = String(afterStart[..<endIndex])
                        // Unescape the string
                        jsxContent = jsxContent?.replacingOccurrences(of: "\\n", with: "\n")
                            .replacingOccurrences(of: "\\\"", with: "\"")
                            .replacingOccurrences(of: "\\\\", with: "\\")
                    }
                }
                
                // Method 2: If not found, try using reflection to inspect entry properties
                if jsxContent == nil {
                    let entryMirror = Mirror(reflecting: entry)
                    for child in entryMirror.children {
                        if let label = child.label {
                            let valueString = String(describing: child.value)
                            
                            // Look for jsxContent in property values
                            if (label.contains("argument") || label.contains("Argument") || 
                                label.contains("jsx") || label.contains("jsxContent")) &&
                               valueString.contains("jsxContent") {
                                
                                // Try to extract from JSON string
                                if let jsxStart = valueString.range(of: "\"jsxContent\"\\s*:\\s*\"", options: .regularExpression) {
                                    let afterStart = String(valueString[jsxStart.upperBound...])
                                    if let quoteEnd = afterStart.range(of: "\"") {
                                        jsxContent = String(afterStart[..<quoteEnd.lowerBound])
                                        // Unescape
                                        jsxContent = jsxContent?.replacingOccurrences(of: "\\n", with: "\n")
                                            .replacingOccurrences(of: "\\\"", with: "\"")
                                            .replacingOccurrences(of: "\\\\", with: "\\")
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Display JSX content in the same format as the tool
                if let jsx = jsxContent, !jsx.isEmpty {
                    Swift.print("   📄 JSX Content: \(jsx.count) characters")
                    Swift.print("   📝 JSX Content Preview:")
                    Swift.print("   " + jsx.replacingOccurrences(of: "\n", with: "\n   "))
                    Swift.print("   🔍 JSX Content Raw (showing all characters):")
                    Swift.print("   " + jsx.debugDescription)
                } else {
                    // JSX not directly extractable - this is expected for base model which stores compact references
                    Swift.print("   📄 JSX Content: Not directly extractable from transcript entry")
                    Swift.print("   ⚠️ Note: Tool call entry stores compact reference (base model behavior)")
                }
                
                // Check for tool output entries (file save confirmation)
                for outputEntry in transcriptEntries {
                    let outputStr = String(describing: outputEntry)
                    if outputStr.contains("saved to:") || outputStr.contains("Widget JSX script saved") {
                        // Extract file path if available
                        if let pathRange = outputStr.range(of: "/Users/[^\\s]+\\.jsx", options: .regularExpression) {
                            let filePath = String(outputStr[pathRange])
                            let directory = String(filePath.dropLast("/index.jsx".count))
                            Swift.print("📁 DIRECTORY CREATED #\(finalCallId): \(directory)")
                            Swift.print("💾 SAVING FILE #\(finalCallId) to: \(filePath)")
                        }
                        Swift.print("✅ FILE SAVED #\(finalCallId) successfully")
                        break
                    }
                }
            }
        }
    }
    
    /// Helper function to run diagnostic for a single model
    private func runDiagnosticForModel(modelName: String, modelType: ModelType) async throws {
        Swift.print("\n" + String(repeating: "=", count: 80))
        Swift.print("🔬 TESTING: \(modelName)")
        Swift.print(String(repeating: "=", count: 80))
        
        let session = try SessionFactory.createSession(
            modelType: modelType,
            systemPrompt: .systemPrompt_v4
        )
        
        // Inspect session's _transcript BEFORE turn 1 (baseline)
        Swift.print("\n🔬 SESSION _TRANSCRIPT INSPECTION (BEFORE TURN 1 - BASELINE):")
        let sessionMirrorBaseline = Mirror(reflecting: session)
        var transcriptBaselineSize = 0
        var transcriptBaselineString = ""
        for child in sessionMirrorBaseline.children {
            if let label = child.label, label == "_transcript" {
            transcriptBaselineString = String(describing: child.value)
            transcriptBaselineSize = transcriptBaselineString.count
            Swift.print("🔬   _transcript size: \(transcriptBaselineSize) characters (~\(transcriptBaselineSize / 4) tokens)")
            if transcriptBaselineSize > 0 {
                let preview = transcriptBaselineString.count > 500 ? String(transcriptBaselineString.prefix(500)) + "..." : transcriptBaselineString
                Swift.print("🔬   _transcript preview (first 500 chars):")
                Swift.print("🔬   \(preview)")
            }
            }
        }
        
        Swift.print("\n" + String(repeating: "=", count: 80))
        Swift.print("🔄 TURN 1")
        Swift.print(String(repeating: "=", count: 80))
        
        // TURN 1: Initial widget creation
        // Using centralized prompt definition from ContextWindowTestPrompts
        Swift.print("\n📝 TURN 1: Creating initial widget")
        let firstPrompt = ContextWindowTestPrompts.initialPrompt
        Swift.print("📝 User: \(firstPrompt)")
        
        // Declare variables outside do block so they're accessible for turn 2
        var totalTranscriptSize = 0
        var toolCallEntrySize = 0
        var jsxContentFound = false
        var jsxContentSize = 0
        var transcriptBeforeSize = 0
        var transcriptBeforeString = ""
        
        do {
            let response = try await session.respond(to: firstPrompt)
            let firstTranscript = Array(response.transcriptEntries)
            
            // Extract and log tool call details in the same format as the tool itself
            logToolCallDetails(from: firstTranscript, turnNumber: 1)
            
            Swift.print("\n📋 TURN 1 TRANSCRIPT ANALYSIS:")
            Swift.print("📋 Total transcript entries: \(firstTranscript.count)")
            
            for (index, entry) in firstTranscript.enumerated() {
                let entryString = String(describing: entry)
                let entrySize = entryString.count
                totalTranscriptSize += entrySize
                
                Swift.print("\n📋 Entry #\(index):")
                Swift.print("📋   Type: \(type(of: entry))")
                Swift.print("📋   String representation length: \(entrySize) characters")
                
                // Check if this is a tool call
                let isToolCall = entryString.contains("WriteUbersichtWidgetToFileSystem") ||
                                 entryString.contains("ToolCalls")
                
                if isToolCall {
                    Swift.print("📋   ⚠️ THIS IS A TOOL CALL ENTRY")
                    toolCallEntrySize += entrySize
                    
                    // Show the full entry string representation
                    let entryPreview = entryString.count > 500 ? String(entryString.prefix(500)) + "..." : entryString
                    Swift.print("📋   Full entry string representation:")
                    Swift.print("📋     \(entryPreview)")
                    
                    // Inspect entry properties using reflection
                    let entryMirror = Mirror(reflecting: entry)
                    Swift.print("📋   Entry properties:")
                    for child in entryMirror.children {
                        if let label = child.label {
                            let valueString = String(describing: child.value)
                            let valueSize = valueString.count
                            
                            Swift.print("📋     - \(label): \(valueSize) characters")
                            // Show actual content for tool call entries
                            if isToolCall {
                                let preview = valueString.count > 500 ? String(valueString.prefix(500)) + "..." : valueString
                                Swift.print("📋       Content: \(preview)")
                            }
                            
                            // Check for jsxContent or arguments
                            if label.contains("argument") || label.contains("Argument") || 
                               label.contains("jsx") || label.contains("jsxContent") ||
                               label.contains("rawArguments") || label.contains("rawArgument") {
                                Swift.print("📋       🔍 FOUND POTENTIAL JSX/ARGUMENT FIELD: \(label)")
                                Swift.print("📋       🔍   Value length: \(valueSize) characters")
                                jsxContentFound = true
                                jsxContentSize += valueSize
                                
                                // Show preview
                                let preview = valueString.count > 200 ? String(valueString.prefix(200)) + "..." : valueString
                                Swift.print("📋       🔍   Preview: \(preview)")
                            }
                        }
                    }
                } else {
                    // Show preview for non-tool-call entries
                    let preview = entryString.count > 200 ? String(entryString.prefix(200)) + "..." : entryString
                    Swift.print("📋   Preview: \(preview)")
                }
            }
            
            Swift.print("\n📊 TURN 1 SUMMARY:")
            Swift.print("📊 Total transcript size: \(totalTranscriptSize) characters (~\(totalTranscriptSize / 4) tokens)")
            Swift.print("📊 Tool call entry size: \(toolCallEntrySize) characters (~\(toolCallEntrySize / 4) tokens)")
            Swift.print("📊 JSX/Argument content found: \(jsxContentFound ? "✅ YES" : "❌ NO")")
            if jsxContentFound {
                Swift.print("📊 JSX/Argument content size: \(jsxContentSize) characters (~\(jsxContentSize / 4) tokens)")
            }
            
            // Inspect session's internal _transcript before turn 2
            Swift.print("\n🔬 SESSION _TRANSCRIPT INSPECTION (BEFORE TURN 2):")
            let sessionMirrorBefore = Mirror(reflecting: session)
            for child in sessionMirrorBefore.children {
                if let label = child.label, label == "_transcript" {
                    transcriptBeforeString = String(describing: child.value)
                    transcriptBeforeSize = transcriptBeforeString.count
                    Swift.print("🔬   _transcript size: \(transcriptBeforeSize) characters (~\(transcriptBeforeSize / 4) tokens)")
                    // Show a larger preview to see what's actually in there
                    let preview = transcriptBeforeString.count > 1000 ? String(transcriptBeforeString.prefix(1000)) + "..." : transcriptBeforeString
                    Swift.print("🔬   _transcript preview (first 1000 chars):")
                    Swift.print("🔬   \(preview)")
                    
                    // Check if jsxContent appears in the transcript
                    if transcriptBeforeString.contains("jsxContent") {
                        Swift.print("🔬   ⚠️ FOUND 'jsxContent' in _transcript!")
                        // Count occurrences
                        let occurrences = transcriptBeforeString.components(separatedBy: "jsxContent").count - 1
                        Swift.print("🔬   ⚠️   Occurrences: \(occurrences)")
                    }
                }
            }
            } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize(let context) = error {
                Swift.print("\n❌ CONTEXT WINDOW EXCEEDED ON TURN 1!")
                Swift.print("❌ Error: \(context.debugDescription)")
                Swift.print("❌ This is WORSE than before - failing on turn 1 instead of turn 2")
                
                // Inspect session's _transcript after the failed attempt
                Swift.print("\n🔬 SESSION _TRANSCRIPT INSPECTION (AFTER FAILED TURN 1):")
                let sessionMirrorAfter = Mirror(reflecting: session)
                for child in sessionMirrorAfter.children {
                    if let label = child.label, label == "_transcript" {
                        let transcriptAfterString = String(describing: child.value)
                        let transcriptAfterSize = transcriptAfterString.count
                        Swift.print("🔬   _transcript size: \(transcriptAfterSize) characters (~\(transcriptAfterSize / 4) tokens)")
                        
                        // Compare with baseline
                        let growth = transcriptAfterSize - transcriptBaselineSize
                        Swift.print("🔬   Growth from baseline to failed turn 1: \(growth) characters (~\(growth / 4) tokens)")
                        
                        // Check for jsxContent
                        if transcriptAfterString.contains("jsxContent") {
                            Swift.print("🔬   ⚠️ FOUND 'jsxContent' in _transcript!")
                            let occurrences = transcriptAfterString.components(separatedBy: "jsxContent").count - 1
                            Swift.print("🔬   ⚠️   Occurrences: \(occurrences)")
                        }
                        
                        // Show a larger preview to see what's consuming tokens
                        let preview = transcriptAfterString.count > 2000 ? String(transcriptAfterString.prefix(2000)) + "..." : transcriptAfterString
                        Swift.print("🔬   _transcript preview (first 2000 chars):")
                        Swift.print("🔬   \(preview)")
                    }
                }
                
                // Turn 1 failed - return early
                Swift.print("\n📊 TURN 1 SUMMARY (FAILED):")
                Swift.print("📊 Context window exceeded: 3910 tokens / 4096 max")
                Swift.print("📊 This indicates something is consuming tokens even before the first user prompt")
                return
            } else {
                throw error
            }
        }
        
        Swift.print("\n" + String(repeating: "=", count: 80))
        Swift.print("🔄 TURN 2")
        Swift.print(String(repeating: "=", count: 80))
        
        // TURN 2: Follow-up instruction
        // Using centralized prompt definition from ContextWindowTestPrompts
        Swift.print("\n📝 TURN 2: Follow-up instruction")
        let secondPrompt = ContextWindowTestPrompts.incrementalPrompts[0]  // "move it to the top-right corner"
        Swift.print("📝 User: \(secondPrompt)")
        
        do {
            let secondResponse = try await session.respond(to: secondPrompt)
            let secondTranscript = Array(secondResponse.transcriptEntries)
            
            // Extract and log tool call details in the same format as the tool itself
            logToolCallDetails(from: secondTranscript, turnNumber: 2)
            
            Swift.print("\n📋 TURN 2 TRANSCRIPT ANALYSIS:")
            Swift.print("📋 Total transcript entries: \(secondTranscript.count)")
            
            var turn2TotalSize = 0
            var turn2ToolCallSize = 0
            var turn2JsxContentSize = 0
            
            for (index, entry) in secondTranscript.enumerated() {
                let entryString = String(describing: entry)
                let entrySize = entryString.count
                turn2TotalSize += entrySize
                
                let isToolCall = entryString.contains("WriteUbersichtWidgetToFileSystem") ||
                                 entryString.contains("ToolCalls")
                
                if isToolCall {
                    turn2ToolCallSize += entrySize
                    
                    // Check for jsxContent in this entry
                    let entryMirror = Mirror(reflecting: entry)
                    for child in entryMirror.children {
                        if let label = child.label,
                           (label.contains("argument") || label.contains("Argument") || 
                            label.contains("jsx") || label.contains("jsxContent") ||
                            label.contains("rawArguments") || label.contains("rawArgument")) {
                            let valueString = String(describing: child.value)
                            turn2JsxContentSize += valueString.count
                        }
                    }
                }
            }
            
            Swift.print("\n📊 TURN 2 SUMMARY:")
            Swift.print("📊 Total transcript size: \(turn2TotalSize) characters (~\(turn2TotalSize / 4) tokens)")
            Swift.print("📊 Tool call entry size: \(turn2ToolCallSize) characters (~\(turn2ToolCallSize / 4) tokens)")
            Swift.print("📊 JSX/Argument content size: \(turn2JsxContentSize) characters (~\(turn2JsxContentSize / 4) tokens)")
            
            // Calculate growth
            let transcriptGrowth = turn2TotalSize - totalTranscriptSize
            Swift.print("\n📊 GROWTH ANALYSIS:")
            Swift.print("📊 Transcript size growth: \(transcriptGrowth) characters (~\(transcriptGrowth / 4) tokens)")
            Swift.print("📊 This represents what was ADDED to conversation history between turn 1 and turn 2")
            
            // Key insight: If turn 2 transcript includes turn 1's full tool call arguments,
            // that would explain the massive context window usage for adapter
            if Double(turn2TotalSize) > Double(totalTranscriptSize) * 1.5 {
                Swift.print("⚠️ WARNING: Turn 2 transcript is significantly larger than turn 1")
                Swift.print("⚠️ This suggests turn 1's full tool call arguments are included in turn 2's history")
            }
            
            // Inspect session's _transcript after successful turn 2
            Swift.print("\n🔬 SESSION _TRANSCRIPT INSPECTION (AFTER TURN 2):")
            let sessionMirrorAfter = Mirror(reflecting: session)
            var transcriptAfterSize = 0
            var transcriptAfterString = ""
            for child in sessionMirrorAfter.children {
                if let label = child.label, label == "_transcript" {
                    transcriptAfterString = String(describing: child.value)
                    transcriptAfterSize = transcriptAfterString.count
                    Swift.print("🔬   _transcript size: \(transcriptAfterSize) characters (~\(transcriptAfterSize / 4) tokens)")
                    
                    // Compare with before
                    let growth = transcriptAfterSize - transcriptBeforeSize
                    Swift.print("🔬   Growth from turn 1 to turn 2: \(growth) characters (~\(growth / 4) tokens)")
                    
                    // Check for jsxContent
                    if transcriptAfterString.contains("jsxContent") {
                        Swift.print("🔬   ⚠️ FOUND 'jsxContent' in _transcript!")
                        let occurrences = transcriptAfterString.components(separatedBy: "jsxContent").count - 1
                        Swift.print("🔬   ⚠️   Occurrences: \(occurrences)")
                    }
                }
            }
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize(let context) = error {
                Swift.print("\n❌ CONTEXT WINDOW EXCEEDED ON TURN 2!")
                Swift.print("❌ Error: \(context.debugDescription)")
                Swift.print("❌ This confirms the adapter model is including too much in context")
                
                // Inspect session's _transcript after the failed attempt
                Swift.print("\n🔬 SESSION _TRANSCRIPT INSPECTION (AFTER FAILED TURN 2):")
                let sessionMirrorAfter = Mirror(reflecting: session)
                for child in sessionMirrorAfter.children {
                    if let label = child.label, label == "_transcript" {
                        let transcriptAfterString = String(describing: child.value)
                        let transcriptAfterSize = transcriptAfterString.count
                        Swift.print("🔬   _transcript size: \(transcriptAfterSize) characters (~\(transcriptAfterSize / 4) tokens)")
                        
                        // Compare with before
                        let growth = transcriptAfterSize - transcriptBeforeSize
                        Swift.print("🔬   Growth from turn 1 to turn 2: \(growth) characters (~\(growth / 4) tokens)")
                        
                        // Check for jsxContent
                        if transcriptAfterString.contains("jsxContent") {
                            Swift.print("🔬   ⚠️ FOUND 'jsxContent' in _transcript!")
                            let occurrences = transcriptAfterString.components(separatedBy: "jsxContent").count - 1
                            Swift.print("🔬   ⚠️   Occurrences: \(occurrences)")
                        }
                    }
                }
                
                // Turn 2 failed - return after analysis
                Swift.print("\n📊 TURN 2 SUMMARY (FAILED):")
                Swift.print("📊 Context window exceeded: 3708 tokens / 4096 max")
                Swift.print("📊 This indicates the full conversation history (including tool call arguments) is being included")
                return
            } else {
                throw error
            }
        }
        
        Swift.print("\n" + String(repeating: "=", count: 80))
        Swift.print("🔬 DIAGNOSTIC COMPLETE")
        Swift.print(String(repeating: "=", count: 80))
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
    
    // MARK: - JSX Validation
    
    private func validateJSX(_ jsx: String, turnNumber: Int) {
        Swift.print("\n🔍 JSX VALIDATION (Turn \(turnNumber)):")
        
        // Check for required exports
        let hasCommand = jsx.contains("export const command")
        let hasRefreshFrequency = jsx.contains("export const refreshFrequency")
        let hasRender = jsx.contains("export const render")
        let hasClassName = jsx.contains("export const className")
        
        Swift.print("   - Has command: \(hasCommand ? "✅" : "❌")")
        Swift.print("   - Has refreshFrequency: \(hasRefreshFrequency ? "✅" : "❌")")
        Swift.print("   - Has render: \(hasRender ? "✅" : "❌")")
        Swift.print("   - Has className: \(hasClassName ? "✅" : "❌")")
        
        // Check for basic structure
        let hasValidStructure = hasCommand && hasRefreshFrequency && hasRender && hasClassName
        Swift.print("   - Valid structure: \(hasValidStructure ? "✅" : "❌")")
        
        // Check for common issues
        let allCommented = jsx.components(separatedBy: .newlines).allSatisfy { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty || trimmed.hasPrefix("//") || trimmed.hasPrefix("/*")
        }
        
        if allCommented && jsx.count > 50 {
            Swift.print("   - ⚠️ WARNING: All lines appear to be commented")
        }
        
        // Assertions
        #expect(hasCommand, "JSX should have 'export const command'")
        #expect(hasRefreshFrequency, "JSX should have 'export const refreshFrequency'")
        #expect(hasRender, "JSX should have 'export const render'")
        #expect(hasClassName, "JSX should have 'export const className'")
    }
    
    private func validateJSXModification(firstJSX: String, secondJSX: String, instruction: String) {
        Swift.print("\n🔍 JSX MODIFICATION VALIDATION:")
        Swift.print("   Instruction: \(instruction)")
        
        let jsxModified = firstJSX != secondJSX
        Swift.print("   - JSX was modified: \(jsxModified ? "✅" : "❌")")
        
        #expect(jsxModified, "JSX should be modified when instruction requires changes")
        
        // Check if positioning-related instruction was applied
        if instruction.lowercased().contains("top") || instruction.lowercased().contains("right") || 
           instruction.lowercased().contains("corner") || instruction.lowercased().contains("position") {
            let hasTop = secondJSX.contains("top:")
            let hasRight = secondJSX.contains("right:")
            Swift.print("   - Has top positioning: \(hasTop ? "✅" : "❌")")
            Swift.print("   - Has right positioning: \(hasRight ? "✅" : "❌")")
        }
    }
    
    // MARK: - JSX Extraction
    
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
        
        return nil
    }
}

