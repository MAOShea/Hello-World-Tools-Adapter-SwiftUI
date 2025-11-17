//
//  MultiTurnConversationTests.swift
//  Hello World ToolsTests
//
//  Technical tests for multi-turn conversations - verifies tool calls and context window usage
//  Quality tests (JSX correctness, context understanding) are in JSXQualityTests.swift
//
//  NOTE: v4-specific tests have been moved to LanguageModelComparisonTests_v4.swift
//

import Testing
import Foundation
import FoundationModels
import ChatCore
@testable import Hello_World_Tools

struct MultiTurnConversationTests {
    // This file is reserved for future version-agnostic multi-turn conversation tests
    // All v4-specific tests have been moved to LanguageModelComparisonTests_v4.swift
}

// MARK: - Note
// This test uses ModelType, SystemPromptVersion, and SessionFactory
// which are already defined in LanguageModelComparisonTests.swift
// Since all test files are in the same module, they can access these types directly
