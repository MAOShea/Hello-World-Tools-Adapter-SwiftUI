//
//  LanguageModelComparisonTests_v3.swift
//  Hello World ToolsTests
//
//  Version-specific tests for systemPrompt_v3
//

import Testing
import Foundation
@testable import Hello_World_Tools

struct LanguageModelComparisonTests_v3 {
    
    @Test("Compare base model vs adapter for systemPrompt_v3")
    func compareModelsForSystemPrompt_v3() async throws {
        try await SharedTestFunctions.compareModelsForSystemPrompt(
            systemPrompt: .systemPrompt_v3
        )
    }
    
    @Test("Test base model with systemPrompt_v3")
    func testBaseModel_v3() async throws {
        try await SharedTestFunctions.testBaseModel(
            systemPrompt: .systemPrompt_v3
        )
    }
    
    @Test("Test adapter model with systemPrompt_v3")
    func testAdapterModel_v3() async throws {
        try await SharedTestFunctions.testAdapterModel(
            systemPrompt: .systemPrompt_v3
        )
    }
}

