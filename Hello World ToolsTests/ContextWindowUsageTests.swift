//
//  ContextWindowUsageTests.swift
//  Hello World ToolsTests
//
//  Tests context window usage across multiple incremental conversation turns
//

import Testing
import Foundation
import FoundationModels
import ChatCore
@testable import Hello_World_Tools

struct ContextWindowUsageTests {
    
    /// Test context window usage with base model across 11 turns (1 initial + 10 incremental)
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
        print(String(repeating: "=", count: 80))
        
        var turnNumber = 0
        var totalResponseLength = 0
        var cumulativeToolCalls = 0
        var contextWindowErrors = 0
        
        // TURN 1: Initial widget creation
        turnNumber += 1
        print("\n🔄 TURN \(turnNumber): Initial Widget Creation")
        print("📝 User: create a widget that displays \"Hello World\"")
        
        do {
            let response = try await session.respond(to: "create a widget that displays \"Hello World\"")
            let responseLength = response.content.count
            totalResponseLength += responseLength
            let transcript = Array(response.transcriptEntries)
            let toolCalled = transcript.contains { entry in
                String(describing: entry).contains("WriteUbersichtWidgetToFileSystem")
            }
            if toolCalled { cumulativeToolCalls += 1 }
            
            print("✅ Response received")
            print("📏 Response length: \(responseLength) characters")
            print("📏 Cumulative response length: \(totalResponseLength) characters")
            print("🔧 Tool called: \(toolCalled)")
            print("📊 Estimated tokens (rough): ~\(responseLength / 4) (using 4 chars/token estimate)")
            print("📊 Status: ✅ Success")
            
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize(let context) = error {
                contextWindowErrors += 1
                print("❌ Context window exceeded!")
                print("❌ Error: \(context.debugDescription)")
                print("📊 Status: ❌ FAILED - Context window limit reached")
            } else {
                throw error
            }
        }
        
        // TURNS 2-11: Incremental modifications
        let incrementalPrompts = [
            "align it with the right edge",
            "make the font bold",
            "make the text red",
            "add a border around it",
            "increase the font size to 24px",
            "center it vertically on the screen",
            "add a shadow effect",
            "change the background color to light gray",
            "make it semi-transparent with 80% opacity",
            "add padding of 20 pixels"
        ]
        
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
                let toolCalled = transcript.contains { entry in
                    String(describing: entry).contains("WriteUbersichtWidgetToFileSystem")
                }
                if toolCalled { cumulativeToolCalls += 1 }
                
                // Estimate tokens (rough approximation: ~4 characters per token)
                let estimatedTokens = totalResponseLength / 4
                let tokensRemaining = max(0, 4096 - estimatedTokens)
                let usagePercent = min(100, (estimatedTokens * 100) / 4096)
                
                print("✅ Response received")
                print("📏 Response length: \(responseLength) characters")
                print("📏 Cumulative response length: \(totalResponseLength) characters")
                print("🔧 Tool called: \(toolCalled)")
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
                    throw error
                }
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
            print("✅ This shows the base model has plenty of headroom for multi-turn conversations")
            #expect(turnNumber == 11, "Should complete all 11 turns")
        } else {
            print("⚠️ PARTIAL SUCCESS: Completed \(turnNumber) turns before hitting context limit")
            print("⚠️ This shows the context window fills up over multiple turns")
        }
        
        // Note: Tool calls may not happen if the model responds with descriptions instead
        // The important metric is context window usage, not tool calls
        if cumulativeToolCalls == 0 {
            print("ℹ️ NOTE: No tool calls were made - model responded with text descriptions")
            print("ℹ️ This is still valid for testing context window usage")
        } else {
            print("✅ Tool calls made: \(cumulativeToolCalls)")
        }
        
        // The main test is about context window usage, not tool calls
        // Context window test passed if we completed all turns without errors
        #expect(contextWindowErrors == 0, "Should not hit context window limit")
    }
}

// MARK: - Note
// This test uses ModelType, SystemPromptVersion, and SessionFactory
// which are already defined in LanguageModelComparisonTests.swift
// Since all test files are in the same module, they can access these types directly

