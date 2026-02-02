//
//  LanguageModelComparisonTests_v6.swift
//  Hello World ToolsTests
//
//  Version-specific tests for systemPrompt_v6
//

import Testing
import Foundation
@testable import Hello_World_Tools

struct LanguageModelComparisonTests_v6 {
    
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
            systemPrompt: .systemPrompt_v6
        )
        
        #expect(result.succeeded, "Base model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    @Test("adapterModel_SimpleWidgetRequest")
    func adapterModel_SimpleWidgetRequest() async throws {
        let runner = TestRunner(adapterURL: URL(filePath: "/Users/mike/Documents/TrainUSAdapter/trained_adapter/adapter_systemPrompt_v6.fmadapter"))
        let testCase = TestCase(
            name: "Simple Widget Request",
            userPrompt: "generate a widget that says \"abc as easy as 123\"",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .adapter(runner.adapterURL),
            systemPrompt: .systemPrompt_v6
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
            systemPrompt: .systemPrompt_v6
        )
        
        #expect(result.succeeded, "Base model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    @Test("adapterModel_TimeWidgetRequest")
    func adapterModel_TimeWidgetRequest() async throws {
        let runner = TestRunner(adapterURL: URL(filePath: "/Users/mike/Documents/TrainUSAdapter/trained_adapter/adapter_systemPrompt_v6.fmadapter"))
        let testCase = TestCase(
            name: "Time Widget Request",
            userPrompt: "create a widget that shows the current time",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .adapter(runner.adapterURL),
            systemPrompt: .systemPrompt_v6
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
            systemPrompt: .systemPrompt_v6
        )
        
        #expect(result.succeeded, "Base model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
    
    @Test("adapterModel_ButtonWidgetRequest")
    func adapterModel_ButtonWidgetRequest() async throws {
        let runner = TestRunner(adapterURL: URL(filePath: "/Users/mike/Documents/TrainUSAdapter/trained_adapter/adapter_systemPrompt_v6.fmadapter"))
        let testCase = TestCase(
            name: "Button Widget Request",
            userPrompt: "generate a widget with a button labelled \"I love you.\"",
            expectedBehavior: .shouldCallTool
        )
        
        let result = await runner.runTest(
            testCase: testCase,
            modelType: .adapter(runner.adapterURL),
            systemPrompt: .systemPrompt_v6
        )
        
        #expect(result.succeeded, "Adapter model should succeed")
        #expect(result.toolWasCalled, "Tool should be called")
    }
}



