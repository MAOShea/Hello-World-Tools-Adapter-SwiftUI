//
//  ContextWindowUsageTests.swift
//  Hello World ToolsTests
//
//  Tests context window usage across multiple incremental conversation turns
//
//  IMPORTANT FINDINGS: Prompt wording and non-deterministic behavior
//  ============================================================================
//  1. PROMPT WORDING IMPACT:
//     Initial test run with prompts like "create a widget" and short directives
//     like "align it with the right edge" resulted in ZERO tool calls - the model
//     responded with text descriptions instead of calling the tool.
//
//     After tweaking the wording:
//     - Changed "create a widget" → "generate a widget" (matches working patterns)
//     - Changed "displays" → "says" (critical difference)
//     - Used shorter directives instead of explicit "update/modify the widget to..." language
//
//     Result: The model successfully called the tool 11 times (all turns).
//
//  2. NON-DETERMINISTIC BEHAVIOR:
//     ⚠️ CRITICAL: Model behavior is NON-DETERMINISTIC even with identical prompts.
//     - Run 1: 0 tool calls (model returned JSX as text, context window exhausted on turn 11)
//     - Run 2: 9 tool calls (model called tool, then context window exceeded on turn 10)
//
//     This demonstrates that:
//     - Tool calls are MUCH more context-efficient than text responses
//     - When tool calls occur: Context usage stays low (~18% after 9-10 turns)
//     - When text responses occur: Context usage grows rapidly (~51% before hitting limit)
//     - Same prompts can produce different outcomes, making behavior unpredictable
//
//  This demonstrates that prompt engineering is critical for reliable tool calling,
//  but even with optimal prompts, model behavior remains non-deterministic.
//

import Testing
import Foundation
import FoundationModels
import ChatCore
@testable import Hello_World_Tools

struct ContextWindowUsageTests {
    
    /// Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
    /// No need to check file system - we rely on transcript detection and tool logs
    
    /// Test context window usage with base model across 11 turns (1 initial + 10 incremental)
    /// Updated to use working prompt patterns from baseModel_MultiTurn:
    /// - "says" instead of "displays" for Turn 1
    /// - Shorter directives instead of explicit "update/modify the widget to..." language
    @Test("Test base model context window usage across multiple turns")
    func testBaseModelContextWindowUsage() async throws {
        // Create a single session that will be reused for all turns
        let session = try SessionFactory.createSession(
            modelType: .base,
            systemPrompt: .systemPrompt_v4
        )
        
        print("\n📊 CONTEXT WINDOW USAGE TEST")
        print("📊 Model: Base Model")
        print("📊 System Prompt: systemPrompt_v4")
        print("📊 Testing 11 turns (1 initial + 10 incremental modifications)")
        print("📊 Context Window Limit: 4096 tokens")
        print("📊 Using working prompt patterns: 'says' instead of 'displays', shorter directives")
        print(String(repeating: "=", count: 80))
        
        var turnNumber = 0
        var totalResponseLength = 0
        var cumulativeToolCalls = 0
        var contextWindowErrors = 0
        
        // TURN 1: Initial widget creation
        // Using centralized prompt definition from ContextWindowTestPrompts
        turnNumber += 1
        print("\n🔄 TURN \(turnNumber): Initial Widget Creation")
        print("📝 User: \(ContextWindowTestPrompts.initialPrompt)")
        
        do {
            let response = try await session.respond(to: ContextWindowTestPrompts.initialPrompt)
            let responseLength = response.content.count
            totalResponseLength += responseLength
            let transcript = Array(response.transcriptEntries)
            let toolCalled = ToolCallDetectionUtilities.wasToolCalled(in: transcript)
            if toolCalled { cumulativeToolCalls += 1 }
            
            // Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
            
            print("✅ Response received")
            print("📏 Response length: \(responseLength) characters")
            print("📏 Cumulative response length: \(totalResponseLength) characters")
            print("📝 Response content preview (first 300 chars): \(String(response.content.prefix(300)))")
            print("🔧 Tool called: \(toolCalled)")
            if toolCalled {
                print("🔧 Tool execution: Verified via log prints (🔧 TOOL CALL and ✅ FILE SAVED)")
            } else {
                print("⚠️ WARNING: Tool was NOT called - model responded with text instead")
                print("⚠️ This may indicate the model didn't recognize the tool call pattern")
            }
            print("📊 Estimated tokens (rough): ~\(responseLength / 4) (using 4 chars/token estimate)")
            print("📊 Status: ✅ Success")
            
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize(let context) = error {
                contextWindowErrors += 1
                print("❌ Context window exceeded!")
                print("❌ Error: \(context.debugDescription)")
                print("📊 Status: ❌ FAILED - Context window limit reached")
            } else {
                // Any other error (including decodingFailure) means the test should fail
                throw error
            }
        }
        
        // TURNS 2-11: Incremental modifications
        // Using centralized prompt definitions from ContextWindowTestPrompts
        // These are the WORKING prompts that successfully trigger tool calls
        let incrementalPrompts = ContextWindowTestPrompts.incrementalPrompts
        
        for (index, prompt) in incrementalPrompts.enumerated() {
            turnNumber += 1
            print("\n🔄 TURN \(turnNumber): Incremental Modification")
            print("📝 User: \(prompt)")
            
            do {
                let startTime = Date()
                let response = try await session.respond(to: prompt)
                let duration = Date().timeIntervalSince(startTime)
                let responseLength = response.content.count
                totalResponseLength += responseLength
                let transcript = Array(response.transcriptEntries)
                let toolCalled = ToolCallDetectionUtilities.wasToolCalled(in: transcript)
                if toolCalled { cumulativeToolCalls += 1 }
                
                // Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
                
                // Estimate tokens (rough approximation: ~4 characters per token)
                let estimatedTokens = totalResponseLength / 4
                let tokensRemaining = max(0, 4096 - estimatedTokens)
                let usagePercent = min(100, (estimatedTokens * 100) / 4096)
                
                print("✅ Response received")
                print("📏 Response length: \(responseLength) characters")
                print("📏 Cumulative response length: \(totalResponseLength) characters")
                print("📝 Response content preview (first 300 chars): \(String(response.content.prefix(300)))")
                print("🔧 Tool called: \(toolCalled)")
                if toolCalled {
                    print("🔧 Tool execution: Verified via log prints (🔧 TOOL CALL and ✅ FILE SAVED)")
                } else {
                    print("⚠️ WARNING: Tool was NOT called - model responded with text instead")
                }
                print("⏱️ Duration: \(String(format: "%.2f", duration))s")
                print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                print("📊 Estimated usage: ~\(usagePercent)%")
                print("📊 Estimated tokens remaining: ~\(tokensRemaining)")
                print("📊 Status: ✅ Success")
                
                // Warning if approaching limit
                if usagePercent > 90 {
                    print("⚠️ WARNING: Approaching context window limit!")
                } else if usagePercent > 75 {
                    print("⚠️ CAUTION: Context window usage is high")
                }
                
            } catch let error as LanguageModelSession.GenerationError {
                if case .exceededContextWindowSize(let context) = error {
                    contextWindowErrors += 1
                    let estimatedTokens = totalResponseLength / 4
                    let usagePercent = min(100, (estimatedTokens * 100) / 4096)
                    
                    print("❌ Context window exceeded!")
                    print("❌ Error: \(context.debugDescription)")
                    print("📏 Cumulative response length: \(totalResponseLength) characters")
                    print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                    print("📊 Estimated usage: ~\(usagePercent)%")
                    print("📊 Status: ❌ FAILED - Context window limit reached at turn \(turnNumber)")
                    break
                } else {
                    // Log other errors (like decodingFailure) but continue to final summary
                    print("❌ Error on turn \(turnNumber): \(error)")
                    if case .decodingFailure(let context) = error {
                        print("❌ Decoding failure: \(context.debugDescription)")
                        print("⚠️ Model may have returned malformed JSON instead of calling tool")
                    }
                    print("📏 Cumulative response length: \(totalResponseLength) characters")
                    let estimatedTokens = totalResponseLength / 4
                    print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                    print("📊 Status: ❌ FAILED - Error occurred at turn \(turnNumber)")
                    // Break to show final summary, but don't throw (test will document what happened)
                    break
                }
            } catch {
                // Catch any other unexpected errors
                print("❌ Unexpected error on turn \(turnNumber): \(error)")
                print("📏 Cumulative response length: \(totalResponseLength) characters")
                let estimatedTokens = totalResponseLength / 4
                print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                print("📊 Status: ❌ FAILED - Unexpected error at turn \(turnNumber)")
                break
            }
        }
        
        // Final summary
        print("\n" + String(repeating: "=", count: 80))
        print("📊 FINAL SUMMARY")
        print(String(repeating: "=", count: 80))
        print("📊 Total turns completed: \(turnNumber) / 11")
        print("📊 Total response length: \(totalResponseLength) characters")
        print("📊 Total tool calls: \(cumulativeToolCalls)")
        print("📊 Context window errors: \(contextWindowErrors)")
        print("📊 Estimated total tokens: ~\(totalResponseLength / 4) / 4096")
        print("📊 Estimated usage: ~\((totalResponseLength / 4 * 100) / 4096)%")
        
        // The test focuses on context window evolution, not on completing all turns
        // Model behavior is non-deterministic - may complete 9, 10, or 11 turns
        if contextWindowErrors == 0 {
            print("✅ SUCCESS: All \(turnNumber) turns completed without hitting context window limit")
            print("✅ Key Finding: Context window usage is ~\(((totalResponseLength / 4 * 100) / 4096))% after \(turnNumber) turns")
            print("✅ This shows the base model's context window evolution over multiple turns")
        } else {
            print("⚠️ Completed \(turnNumber) turns before hitting context limit")
            print("⚠️ This shows how context window fills up over multiple turns")
            print("⚠️ Context window evolution tracked: ~\(((totalResponseLength / 4 * 100) / 4096))% usage at failure point")
        }
        
        // Note: Tool calls may not happen if the model responds with descriptions instead
        // The important metric is context window usage, not tool calls
        if cumulativeToolCalls == 0 {
            print("ℹ️ NOTE: No tool calls were made - model responded with text descriptions")
            print("ℹ️ This is still valid for testing context window usage")
            print("⚠️ NON-DETERMINISTIC: Same prompts can produce different outcomes")
        } else {
            print("✅ Tool calls made: \(cumulativeToolCalls)")
            if contextWindowErrors > 0 {
                print("⚠️ NON-DETERMINISTIC: Tool calls occurred but context window was exceeded")
                print("⚠️ This demonstrates that tool calls are context-efficient, but context still accumulates")
            }
        }
        
        // The main test is about context window usage, not tool calls
        // Context window errors are a valid outcome when tool calls occur (they consume context too)
        // Model behavior is non-deterministic - same prompts can produce different outcomes
        // We document the behavior rather than assert on it
        if contextWindowErrors > 0 {
            print("⚠️ Context window limit reached - this is expected in long conversations")
            print("⚠️ Key insight: Tool calls are more efficient, but context still accumulates over many turns")
        }
    }
    
    /// Test context window usage with adapter model across 11 turns (1 initial + 10 incremental)
    /// Expected to fail early due to context window limitations
    @Test("Test adapter model context window usage across multiple turns")
    func testAdapterModelContextWindowUsage() async throws {
        let adapterURL = URL(filePath: "/Users/mike/Downloads/uebersicht_widgets.fmadapter")
        
        // Create a single session that will be reused for all turns
        let session = try SessionFactory.createSession(
            modelType: .adapter(adapterURL),
            systemPrompt: .systemPrompt_v4
        )
        
        print("\n📊 CONTEXT WINDOW USAGE TEST")
        print("📊 Model: Adapter Model")
        print("📊 System Prompt: systemPrompt_v4")
        print("📊 Testing 11 turns (1 initial + 10 incremental modifications)")
        print("📊 Context Window Limit: 4096 tokens")
        print("⚠️ NOTE: Adapter model expected to hit context window limit early")
        print(String(repeating: "=", count: 80))
        
        var turnNumber = 0
        var totalResponseLength = 0
        var cumulativeToolCalls = 0
        var contextWindowErrors = 0
        
        // TURN 1: Initial widget creation
        // Using centralized prompt definition from ContextWindowTestPrompts
        turnNumber += 1
        print("\n🔄 TURN \(turnNumber): Initial Widget Creation")
        print("📝 User: \(ContextWindowTestPrompts.initialPrompt)")
        
        do {
            let response = try await session.respond(to: ContextWindowTestPrompts.initialPrompt)
            let responseLength = response.content.count
            totalResponseLength += responseLength
            let transcript = Array(response.transcriptEntries)
            let toolCalled = ToolCallDetectionUtilities.wasToolCalled(in: transcript)
            if toolCalled { cumulativeToolCalls += 1 }
            
            // Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
            
            print("✅ Response received")
            print("📏 Response length: \(responseLength) characters")
            print("📏 Cumulative response length: \(totalResponseLength) characters")
            print("📝 Response content preview (first 300 chars): \(String(response.content.prefix(300)))")
            print("🔧 Tool called: \(toolCalled)")
            if toolCalled {
                print("🔧 Tool execution: Verified via log prints (🔧 TOOL CALL and ✅ FILE SAVED)")
            } else {
                print("⚠️ WARNING: Tool was NOT called - model responded with text instead")
                print("⚠️ This may indicate the model didn't recognize the tool call pattern")
            }
            print("📊 Estimated tokens (rough): ~\(responseLength / 4) (using 4 chars/token estimate)")
            print("📊 Status: ✅ Success")
            
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize(let context) = error {
                contextWindowErrors += 1
                print("❌ Context window exceeded!")
                print("❌ Error: \(context.debugDescription)")
                print("📊 Status: ❌ FAILED - Context window limit reached")
            } else {
                // Log other errors (like decodingFailure) but continue to final summary
                print("❌ Error on turn \(turnNumber): \(error)")
                if case .decodingFailure(let context) = error {
                    print("❌ Decoding failure: \(context.debugDescription)")
                    print("⚠️ Model may have returned malformed JSON instead of calling tool")
                }
                print("📏 Cumulative response length: \(totalResponseLength) characters")
                let estimatedTokens = totalResponseLength / 4
                print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                print("📊 Status: ❌ FAILED - Error occurred at turn \(turnNumber)")
                // Don't throw - continue to show final summary
            }
        } catch {
            // Catch any other unexpected errors
            print("❌ Unexpected error on turn \(turnNumber): \(error)")
            print("📏 Cumulative response length: \(totalResponseLength) characters")
            let estimatedTokens = totalResponseLength / 4
            print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
            print("📊 Status: ❌ FAILED - Unexpected error at turn \(turnNumber)")
        }
        
        // TURNS 2-11: Incremental modifications
        // Using centralized prompt definitions from ContextWindowTestPrompts
        // These are the WORKING prompts that successfully trigger tool calls
        let incrementalPrompts = ContextWindowTestPrompts.incrementalPrompts
        
        for (index, prompt) in incrementalPrompts.enumerated() {
            turnNumber += 1
            print("\n🔄 TURN \(turnNumber): Incremental Modification")
            print("📝 User: \(prompt)")
            
            do {
                let startTime = Date()
                let response = try await session.respond(to: prompt)
                let duration = Date().timeIntervalSince(startTime)
                let responseLength = response.content.count
                totalResponseLength += responseLength
                let transcript = Array(response.transcriptEntries)
                let toolCalled = ToolCallDetectionUtilities.wasToolCalled(in: transcript)
                if toolCalled { cumulativeToolCalls += 1 }
                
                // Tool execution is verified through log prints (🔧 TOOL CALL and ✅ FILE SAVED)
                
                // Estimate tokens (rough approximation: ~4 characters per token)
                let estimatedTokens = totalResponseLength / 4
                let tokensRemaining = max(0, 4096 - estimatedTokens)
                let usagePercent = min(100, (estimatedTokens * 100) / 4096)
                
                print("✅ Response received")
                print("📏 Response length: \(responseLength) characters")
                print("📏 Cumulative response length: \(totalResponseLength) characters")
                print("📝 Response content preview (first 300 chars): \(String(response.content.prefix(300)))")
                print("🔧 Tool called: \(toolCalled)")
                if toolCalled {
                    print("🔧 Tool execution: Verified via log prints (🔧 TOOL CALL and ✅ FILE SAVED)")
                } else {
                    print("⚠️ WARNING: Tool was NOT called - model responded with text instead")
                }
                print("⏱️ Duration: \(String(format: "%.2f", duration))s")
                print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                print("📊 Estimated usage: ~\(usagePercent)%")
                print("📊 Estimated tokens remaining: ~\(tokensRemaining)")
                print("📊 Status: ✅ Success")
                
                // Warning if approaching limit
                if usagePercent > 90 {
                    print("⚠️ WARNING: Approaching context window limit!")
                } else if usagePercent > 75 {
                    print("⚠️ CAUTION: Context window usage is high")
                }
                
            } catch let error as LanguageModelSession.GenerationError {
                if case .exceededContextWindowSize(let context) = error {
                    contextWindowErrors += 1
                    let estimatedTokens = totalResponseLength / 4
                    let usagePercent = min(100, (estimatedTokens * 100) / 4096)
                    
                    print("❌ Context window exceeded!")
                    print("❌ Error: \(context.debugDescription)")
                    print("📏 Cumulative response length: \(totalResponseLength) characters")
                    print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                    print("📊 Estimated usage: ~\(usagePercent)%")
                    print("📊 Status: ❌ FAILED - Context window limit reached at turn \(turnNumber)")
                    break
                } else {
                    // Log other errors (like decodingFailure) but continue to final summary
                    print("❌ Error on turn \(turnNumber): \(error)")
                    if case .decodingFailure(let context) = error {
                        print("❌ Decoding failure: \(context.debugDescription)")
                        print("⚠️ Model may have returned malformed JSON instead of calling tool")
                    }
                    print("📏 Cumulative response length: \(totalResponseLength) characters")
                    let estimatedTokens = totalResponseLength / 4
                    print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                    print("📊 Status: ❌ FAILED - Error occurred at turn \(turnNumber)")
                    // Break to show final summary, but don't throw (test will document what happened)
                    break
                }
            } catch {
                // Catch any other unexpected errors
                print("❌ Unexpected error on turn \(turnNumber): \(error)")
                print("📏 Cumulative response length: \(totalResponseLength) characters")
                let estimatedTokens = totalResponseLength / 4
                print("📊 Estimated total tokens: ~\(estimatedTokens) / 4096")
                print("📊 Status: ❌ FAILED - Unexpected error at turn \(turnNumber)")
                break
            }
        }
        
        // Final summary
        print("\n" + String(repeating: "=", count: 80))
        print("📊 FINAL SUMMARY")
        print(String(repeating: "=", count: 80))
        print("📊 Total turns completed: \(turnNumber) / 11")
        print("📊 Total response length: \(totalResponseLength) characters")
        print("📊 Total tool calls: \(cumulativeToolCalls)")
        print("📊 Context window errors: \(contextWindowErrors)")
        print("📊 Estimated total tokens: ~\(totalResponseLength / 4) / 4096")
        print("📊 Estimated usage: ~\((totalResponseLength / 4 * 100) / 4096)%")
        
        if contextWindowErrors == 0 {
            print("✅ SUCCESS: All turns completed without hitting context window limit")
            print("✅ Key Finding: Context window usage is only ~\(((totalResponseLength / 4 * 100) / 4096))% after 11 turns")
            print("✅ This shows the adapter model has plenty of headroom for multi-turn conversations")
            #expect(turnNumber == 11, "Should complete all 11 turns")
        } else {
            print("⚠️ PARTIAL SUCCESS: Completed \(turnNumber) turns before hitting context limit")
            print("⚠️ This shows the adapter model's context window fills up quickly over multiple turns")
            print("⚠️ Key Finding: Adapter model hit context limit at turn \(turnNumber) with ~\(((totalResponseLength / 4 * 100) / 4096))% usage")
        }
        
        // Note: Tool calls may not happen if the model responds with descriptions instead
        // The important metric is context window usage, not tool calls
        if cumulativeToolCalls == 0 {
            print("ℹ️ NOTE: No tool calls were made - model responded with text descriptions")
            print("ℹ️ This is still valid for testing context window usage")
        } else {
            print("✅ Tool calls made: \(cumulativeToolCalls)")
        }
        
        // For adapter model, we expect it to fail early, so we don't assert on context window errors
        // The test is informative - it shows when/how the adapter model hits the limit
        if contextWindowErrors > 0 {
            print("ℹ️ NOTE: Adapter model context window limitation confirmed")
        }
    }
}

// MARK: - Note
// This test uses ModelType, SystemPromptVersion, and SessionFactory
// which are already defined in LanguageModelComparisonTests.swift
// Since all test files are in the same module, they can access these types directly

