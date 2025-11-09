//
//  LanguageModelComparisonTests_v4.swift
//  Hello World ToolsTests
//
//  Version-specific tests for systemPrompt_v4
//

import Testing
import Foundation
@testable import Hello_World_Tools

struct LanguageModelComparisonTests_v4 {
    
    @Test("Compare base model vs adapter for systemPrompt_v4")
    func compareModelsForSystemPrompt_v4() async throws {
        try await SharedTestFunctions.compareModelsForSystemPrompt(
            systemPrompt: .systemPrompt_v4
        )
    }
    
    @Test("Test base model with systemPrompt_v4")
    func testBaseModel_v4() async throws {
        try await SharedTestFunctions.testBaseModel(
            systemPrompt: .systemPrompt_v4
        )
    }
    
    @Test("Test adapter model with systemPrompt_v4")
    func testAdapterModel_v4() async throws {
        try await SharedTestFunctions.testAdapterModel(
            systemPrompt: .systemPrompt_v4
        )
    }
}

