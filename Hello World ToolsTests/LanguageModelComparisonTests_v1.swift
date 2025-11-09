//
//  LanguageModelComparisonTests_v1.swift
//  Hello World ToolsTests
//
//  Version-specific tests for systemPrompt_v1
//

import Testing
import Foundation
@testable import Hello_World_Tools

struct LanguageModelComparisonTests_v1 {
    
    @Test("Compare base model vs adapter for systemPrompt_v1")
    func compareModelsForSystemPrompt_v1() async throws {
        try await SharedTestFunctions.compareModelsForSystemPrompt(
            systemPrompt: .systemPrompt_v1
        )
    }
    
    @Test("Test base model with systemPrompt_v1")
    func testBaseModel_v1() async throws {
        try await SharedTestFunctions.testBaseModel(
            systemPrompt: .systemPrompt_v1
        )
    }
    
    @Test("Test adapter model with systemPrompt_v1")
    func testAdapterModel_v1() async throws {
        try await SharedTestFunctions.testAdapterModel(
            systemPrompt: .systemPrompt_v1
        )
    }
}

