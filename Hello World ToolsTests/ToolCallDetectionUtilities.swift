//
//  ToolCallDetectionUtilities.swift
//  Hello World ToolsTests
//
//  Utility functions for detecting tool calls in transcript entries
//  Centralized to follow DRY principles
//

import Foundation
import FoundationModels
import ChatCore

struct ToolCallDetectionUtilities {
    
    /// Check if a tool was called in transcript entries
    /// This checks for actual tool call entries, not just tool name appearing in response text
    /// 
    /// - Parameters:
    ///   - transcriptEntries: Array of transcript entries to check
    ///   - toolName: Name of the tool to look for (default: "WriteUbersichtWidgetToFileSystem")
    /// - Returns: `true` if tool was actually called, `false` otherwise
    static func wasToolCalled(
        in transcriptEntries: [Any],
        toolName: String = "WriteUbersichtWidgetToFileSystem"
    ) -> Bool {
        return transcriptEntries.contains { entry in
            let entryString = String(describing: entry)
            let entryType = String(describing: type(of: entry))
            
            // Must be an actual tool call entry, not just text containing the tool name
            let isToolCallEntry = entryType.contains("Tool") && entryType.contains("Call")
            let hasToolCallsKeyword = entryString.contains("ToolCalls") || entryString.contains("tool_calls")
            let hasToolName = entryString.contains(toolName)
            
            // Only count if it's a tool call entry AND has the tool name
            return (isToolCallEntry || hasToolCallsKeyword) && hasToolName
        }
    }
    
    /// Count the number of tool calls detected in transcript entries
    /// 
    /// - Parameters:
    ///   - transcriptEntries: Array of transcript entries to check
    ///   - toolName: Name of the tool to look for (default: "WriteUbersichtWidgetToFileSystem")
    /// - Returns: Number of tool calls detected
    static func countToolCalls(
        in transcriptEntries: [Any],
        toolName: String = "WriteUbersichtWidgetToFileSystem"
    ) -> Int {
        var count = 0
        for entry in transcriptEntries {
            let entryString = String(describing: entry)
            let entryType = String(describing: type(of: entry))
            
            let isToolCallEntry = entryType.contains("Tool") && entryType.contains("Call")
            let hasToolCallsKeyword = entryString.contains("ToolCalls") || entryString.contains("tool_calls")
            let hasToolName = entryString.contains(toolName)
            
            if (isToolCallEntry || hasToolCallsKeyword) && hasToolName {
                count += 1
            }
        }
        return count
    }
}

