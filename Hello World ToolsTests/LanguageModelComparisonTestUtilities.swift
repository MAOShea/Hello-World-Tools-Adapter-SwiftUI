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

