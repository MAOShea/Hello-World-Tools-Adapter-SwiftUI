//
//  LanguageModelComparisonTests_v2.swift
//  Hello World ToolsTests
//
//  Version-specific tests for systemPrompt_v2
//

import Testing
import Foundation
@testable import Hello_World_Tools

struct LanguageModelComparisonTests_v2 {
    
    @Test("Compare base model vs adapter for systemPrompt_v2")
    func compareModelsForSystemPrompt_v2() async throws {
        try await SharedTestFunctions.compareModelsForSystemPrompt(
            systemPrompt: .systemPrompt_v2
        )
    }
    
    @Test("Test base model with systemPrompt_v2")
    func testBaseModel_v2() async throws {
        try await SharedTestFunctions.testBaseModel(
            systemPrompt: .systemPrompt_v2
        )
    }
    
    @Test("Test adapter model with systemPrompt_v2")
    func testAdapterModel_v2() async throws {
        try await SharedTestFunctions.testAdapterModel(
            systemPrompt: .systemPrompt_v2
        )
    }
}

