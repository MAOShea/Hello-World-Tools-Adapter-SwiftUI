//
//  LanguageModelComparisonTestUtilities.swift
//  Hello World ToolsTests
//
//  Shared test utilities for version-specific test files
//

import Testing
import Foundation
import FoundationModels
import ChatCore
@testable import Hello_World_Tools

// MARK: - Shared Test Cases

struct SharedTestCases {
    static let testCases: [TestCase] = [
        TestCase(
            name: "Simple Widget Request",
            userPrompt: "generate a widget that says \"abc as easy as 123\"",
            expectedBehavior: .shouldCallTool
        ),
        TestCase(
            name: "Time Widget Request",
            userPrompt: "create a widget that shows the current time",
            expectedBehavior: .shouldCallTool
        ),
        TestCase(
            name: "Button Widget Request",
            userPrompt: "generate a widget with a button labelled \"I love you.\"",
            expectedBehavior: .shouldCallTool
        ),
        // Add more test cases as needed
    ]
}

// MARK: - 11-Turn Context Window Test Prompts

/// Centralized definition of the 11-turn prompts used for context window testing.
/// These are the WORKING prompts that successfully trigger tool calls.
/// 
/// Source of truth: Based on working patterns from `baseModel_MultiTurn`:
/// - Turn 1: Uses "says" instead of "displays" (works better)
/// - Turns 2-11: Uses shorter directives instead of explicit "update/modify the widget to..." language
struct ContextWindowTestPrompts {
    /// Turn 1: Initial widget creation prompt
    /// EXACTLY matches the working prompt from baseModel_MultiTurn
    static let initialPrompt = "generate a widget that says \"abc as easy as 123\""
    
    /// Turns 2-11: Incremental modification prompts
    /// EXACTLY matches the working prompt from baseModel_MultiTurn (Turn 2)
    /// Note: baseModel_MultiTurn only has 2 turns, so we use the working Turn 2 pattern
    /// and extend it with similar shorter directives for the remaining turns
    static let incrementalPrompts: [String] = [
        "move it to the top-right corner",  // EXACT match from baseModel_MultiTurn Turn 2
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
    
    /// All 11 prompts in order (Turn 1 + Turns 2-11)
    static var allPrompts: [String] {
        [initialPrompt] + incrementalPrompts
    }
}

// MARK: - Shared Test Functions

struct SharedTestFunctions {
    
    /// Compare base model vs adapter model for a specific system prompt version
    static func compareModelsForSystemPrompt(
        systemPrompt: SystemPromptVersion,
        testCases: [TestCase] = SharedTestCases.testCases
    ) async throws {
        // Log timestamp for test run tracking
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let timestamp = dateFormatter.string(from: Date())
        print("\n🕐 TEST RUN TIMESTAMP: \(timestamp)")
        
        let runner = TestRunner()
        
        for testCase in testCases {
            // Run with base model
            let baseResult = await runner.runTest(
                testCase: testCase,
                modelType: .base,
                systemPrompt: systemPrompt
            )
            
            // Run with adapter model
            let adapterResult = await runner.runTest(
                testCase: testCase,
                modelType: .adapter(runner.adapterURL),
                systemPrompt: systemPrompt
            )
            
            // Generate comparison
            let comparison = ResultComparison(
                baseResult: baseResult,
                adapterResult: adapterResult
            )
            
            // Print report
            print("\n" + comparison.generateReport())
            
            // Log results with tool call status
            let baseToolStatus = baseResult.toolWasCalled ? "✅ Tool" : "❌ No Tool"
            let adapterToolStatus = adapterResult.toolWasCalled ? "✅ Tool" : "❌ No Tool"
            
            if baseResult.succeeded && adapterResult.succeeded {
                print("✅ Both models succeeded for \(testCase.name) with \(systemPrompt.rawValue)")
                print("   Base: \(baseToolStatus), Adapter: \(adapterToolStatus)")
            } else if baseResult.succeeded {
                print("⚠️ Only base model succeeded for \(testCase.name) with \(systemPrompt.rawValue)")
                print("   Base: \(baseToolStatus), Adapter: \(adapterToolStatus)")
            } else if adapterResult.succeeded {
                print("⚠️ Only adapter model succeeded for \(testCase.name) with \(systemPrompt.rawValue)")
                print("   Base: \(baseToolStatus), Adapter: \(adapterToolStatus)")
            } else {
                print("❌ BOTH MODELS FAILED for \(testCase.name) with \(systemPrompt.rawValue)")
                print("   Base: \(baseToolStatus), Adapter: \(adapterToolStatus)")
                print("❌ Base model error: \(baseResult.error?.localizedDescription ?? "Unknown error")")
                print("❌ Adapter model error: \(adapterResult.error?.localizedDescription ?? "Unknown error")")
            }
            
            // Assertions: Both models must succeed
            // If either model fails, the test should fail
            if !baseResult.succeeded {
                let baseError = baseResult.error?.localizedDescription ?? "Unknown error"
                #expect(
                    baseResult.succeeded,
                    "Base model failed for \(testCase.name) with \(systemPrompt.rawValue). Error: \(baseError)"
                )
            }
            
            if !adapterResult.succeeded {
                let adapterError = adapterResult.error?.localizedDescription ?? "Unknown error"
                #expect(
                    adapterResult.succeeded,
                    "Adapter model failed for \(testCase.name) with \(systemPrompt.rawValue). Error: \(adapterError)"
                )
            }
        }
    }
    
    /// Test base model with a specific system prompt version
    static func testBaseModel(
        systemPrompt: SystemPromptVersion,
        userPrompt: String = "generate a widget that says \"abc as easy as 123\""
    ) async throws {
        let runner = TestRunner()
        let testCase = TestCase(
            name: "Base Model Test",
            userPrompt: userPrompt,
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .base,
            systemPrompt: systemPrompt
        )
        
        #expect(result.succeeded, "Base model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
        
        if let response = result.response {
            print("Base model response: \(response)")
        }
    }
    
    /// Test adapter model with a specific system prompt version
    static func testAdapterModel(
        systemPrompt: SystemPromptVersion,
        userPrompt: String = "generate a widget that says \"abc as easy as 123\""
    ) async throws {
        let runner = TestRunner()
        let testCase = TestCase(
            name: "Adapter Model Test",
            userPrompt: userPrompt,
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .adapter(runner.adapterURL),
            systemPrompt: systemPrompt
        )
        
        #expect(result.succeeded, "Adapter model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
        
        if let response = result.response {
            print("Adapter model response: \(response)")
        }
    }
}

// MARK: - System Prompt Library

struct SystemPromptEntry: Decodable {
    let name: String
    let content: String
    let length: Int?
    let hasTools: Bool?
    let toolCount: Int?
    let date: String?
    let id: Double?
    let source: String?
}

enum SystemPromptLibraryError: Error {
    case fileNotFound(String)
    case invalidData(String)
    case promptNotFound(String)
}

struct SystemPromptLibrary {
    private static let systemPromptsPath = "/Users/mike/Documents/TrainUSAdapter/system_prompts.json"
    private static var cachedPrompts: [SystemPromptEntry]?
    
    static func loadSystemPrompts() throws -> [SystemPromptEntry] {
        if let cachedPrompts {
            return cachedPrompts
        }
        
        let fileURL = URL(fileURLWithPath: systemPromptsPath)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw SystemPromptLibraryError.fileNotFound(systemPromptsPath)
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        
        struct SystemPromptPayload: Decodable {
            let content: String
            let length: Int?
            let hasTools: Bool?
            let toolCount: Int?
            let date: String?
            let id: Double?
            let source: String?
            
            enum CodingKeys: String, CodingKey {
                case content
                case length
                case hasTools = "has_tools"
                case toolCount = "tool_count"
                case date
                case id
                case source
            }
        }
        
        let raw = try decoder.decode([String: SystemPromptPayload].self, from: data)
        let prompts = raw.map { key, payload in
            SystemPromptEntry(
                name: key,
                content: payload.content,
                length: payload.length,
                hasTools: payload.hasTools,
                toolCount: payload.toolCount,
                date: payload.date,
                id: payload.id,
                source: payload.source
            )
        }
        
        cachedPrompts = prompts
        return prompts
    }
    
    static func GetFromName(string name: String) throws -> SystemPromptEntry {
        let prompts = try loadSystemPrompts()
        if let match = prompts.first(where: { $0.name == name }) {
            return match
        }
        throw SystemPromptLibraryError.promptNotFound(name)
    }
    
    static func GetFromId(string id: String) throws -> SystemPromptEntry {
        let prompts = try loadSystemPrompts()
        if let idValue = Double(id) {
            if let match = prompts.first(where: { $0.id == idValue }) {
                return match
            }
        }
        
        if let match = prompts.first(where: { entry in
            guard let entryId = entry.id else { return false }
            return String(entryId) == id || String(format: "%.1f", entryId) == id
        }) {
            return match
        }
        
        throw SystemPromptLibraryError.promptNotFound(id)
    }
}