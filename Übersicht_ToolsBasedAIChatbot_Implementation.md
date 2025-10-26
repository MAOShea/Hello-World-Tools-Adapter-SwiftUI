# Tools-Based AI Chatbot Implementation

## Project Overview
**Hello World Tools (HWT)** - macOS SwiftUI app with AI tool calling using Apple's FoundationModels framework.

### Version History
**Übersicht Designer AI Chatbot v2.2** - This version introduces FoundationModels tool calling capabilities to enable non-coders to create Übersicht widgets through natural language conversation.

- **v1.0**: SDK for developing Übersicht widgets (code-based approach)
- **v2.0**: AI chatbot interface for non-coders to create widgets
- **v2.2**: Enhanced with FoundationModels tool calling for improved widget generation capabilities

## Core Architecture

### Key Components
- **AI Service**: `ToolsEnabledAIService.swift` - Manages FoundationModels session with tools
- **Tools**: `WriteUbersichtWidgetToFileSystem.swift` - AI-invokable function
- **UI**: SwiftUI interface with ChatCore library integration
- **Framework**: FoundationModels for local AI with tool calling

### Dependencies
```swift
import FoundationModels   // Apple's AI framework with tool calling
import ChatCore          // Custom chat UI components
import SwiftUI           // macOS UI framework
```

### Implementation Status

#### ✅ Working Components
- **AI Service**: FoundationModels session with tools and session instructions
- **Tool Registration**: Tools are registered in `ToolsEnabledAIService`
- **Tool Invocation**: AI reliably invokes tools with proper keywords
- **File Operations**: Can write to Übersicht widgets folder using system file picker
- **Session Instructions**: LanguageModelSession establishes role and tool contracts

#### ⚠️ Current Issues
- **Tool Invocation**: Currently struggling to make the AI invoke the tool that writes the widget. Have changed its name to be specific instead of general ('WriteUbersichtWidgetToFileSystem' instead of 'outputblahblah')
- **JSX Content**: Some AI generations include function wrappers or `return`; resolved by instructing the model to output only JSX markup
- **CSS Class Naming**: Former issue with hyphens/class names now resolved—model always uses variable names ending in `Style` and references with `{variable}` in JSX

## Tool Implementation

### WriteUbersichtWidgetToFileSystem Tool — Contract

**Arguments:**
- `bashCommand` (String): A bash command line string that will be executed by Übersicht, with output passed to the JSX body as {output}
- `refreshFrequency` (Int): The widget's refresh frequency in milliseconds
- `renderFunction` (String): A React functional component as a JavaScript arrow function that renders the widget body, receiving a single "output" prop
- `cssPositioning` (String): The widget's absolute positioning in Standard CSS format (only absolute positioning works)

**Behavior:**
- Generates complete JSX content from the individual arguments
- Writes the generated JSX to `/Users/mike/Library/Application Support/Übersicht/widgets/index.jsx`
- Returns confirmation message with file path
- Validates the render function before generation
- No file picker interaction - uses hardcoded destination path

**Generated Übersicht Interface:**
The tool generates JSX with these required exports:
- `command`: String - The provided bash command
- `refreshFrequency`: Number - The provided refresh rate
- `render`: Function - The provided React component function
- `className`: String - The provided CSS positioning

**Example Usage:**
```javascript
// Input arguments:
bashCommand: "echo Hello World"
refreshFrequency: 1000
renderFunction: "({output}) => { return <h1>{output}</h1> }"
cssPositioning: "top: 20px; left: 20px;"

// Generated JSX output:
export const command = "echo Hello World"
export const refreshFrequency = 1000
export const render = ({output}) => { return <h1>{output}</h1> }
export const className = "top: 20px; left: 20px;"
```

### TotalLengthOfStrings Tool — Contract

**Arguments:**
- `strings` ([String]):  
  An array of strings whose combined character length will be calculated.

**Behavior:**
- Returns the total length (number of characters) of all the strings in the array, summed together as an integer.

**Example:**

Input:
```json
"strings": ["hello", "world", "!"]
```

## Session Configuration

### AI Role Establishment
```swift
let session = LanguageModelSession(tools: tools) {
    Instructions {
        Constants.Prompts.humanRolePrompt
    }
}
```

### Session Instructions
```
You are a widget designer. Create Übersicht widgets.

Tools:
- WriteUbersichtWidgetToFileSystem: Generates and writes JSX widget to disk

Rules:
- Call WriteUbersichtWidgetToFileSystem with these parameters:
  - bashCommand: The bash command to execute
  - refreshFrequency: Refresh rate in milliseconds
  - renderFunction: React component function that receives {output} prop
  - cssPositioning: CSS positioning (absolute only)
- Use {output} prop in render function to display bash command results
```

## File Operations

### Übersicht Widget Generation
- **Target Path**: `/Users/mike/Library/Application Support/Übersicht/widgets/index.jsx`
- **File Format**: Generated JSX with required Übersicht exports
- **Generation**: Tool creates JSX from individual parameters (bashCommand, refreshFrequency, renderFunction, cssPositioning)
- **File Picker**: Currently disabled - uses hardcoded destination path
- **App Sandbox**: Disabled to allow writing outside sandbox

### Generated JSX Structure
The tool generates JSX with these exports:
```javascript
export const command = "<provided-bash-command>"
export const refreshFrequency = <provided-refresh-rate>
export const render = <provided-react-component-function>
export const className = "<provided-css-positioning>"
```

## Development Guidelines

### SwiftUI Development
- Use **SwiftUI** components and APIs, not UIKit
- Use **NSColor** for system colors (macOS)
- Use **SwiftUI Font system** (`.system(size:weight:)`)

### FoundationModels Integration
- **Session Creation**: Use `LanguageModelSession(tools: instructions:)`
- **Tool Implementation**: Follow `@Observable` class with `@Generable` arguments
- **Error Handling**: Handle `LanguageModelSession.GenerationError` cases
- **Content Safety**: Avoid FoundationModels blocking while preserving debug info

## Testing and Debugging

### Xcode 26 Beta 5 Playgrounds
- **FoundationModels Feedback**: New feature for reporting framework issues directly from Playgrounds
- **Isolated Testing**: Test tools without app complexity
- **Rapid Iteration**: Instant code execution and results
- **API Testing**: Verify FoundationModels functionality in isolation

### Debugging Approaches
- **Playgrounds**: For framework-level testing and API exploration
- **App Debugging**: For full app testing, UI issues, and integration problems

### Prompt Samples

- generate a widget that contains a button labelled “I love you.”

## Tool Calling Lessons Learned

### What Works for Tool Calling
- **Simple, direct prompts** - Clear instructions without complexity
- **Concise examples** - Single-line tool call examples work better than multi-line
- **Direct commands** - "Call the tool" rather than "show how to call the tool"
- **Minimal redundancy** - Avoid multiple ways of saying the same thing

### What Breaks Tool Calling
- **Complex formatting instructions** - Detailed JSX syntax guidance confuses the AI
- **Multi-line examples** - Makes AI think it should demonstrate rather than execute
- **Multiple imperative statements** - "AUTOMATICALLY", "CRITICAL", "Do NOT" create confusion
- **Over-detailed prompts** - More instructions make tool calling worse, not better

### Key Insight
**Tool calling is behavioral, not instructional.** The AI needs to understand it should **act**, not **teach**. Adding more instructions actually makes it worse by confusing the AI about its role.

### Working Prompt Pattern
```
You are a widget designer. Create widgets when requested.

IMPORTANT: You have access to a tool called WriteUbersichtWidgetToFileSystem. 
When asked to create a widget, you MUST call this tool.

[Simple example]
[Basic rules]
```

### Broken Prompt Pattern
```
You are a widget designer. Create widgets when requested.

IMPORTANT: You have access to a tool called WriteUbersichtWidgetToFileSystem. 
When asked to create a widget, you MUST call this tool AUTOMATICALLY. 
Do NOT just show the JSX code - you MUST call the tool immediately.

[Complex multi-line example]
[Detailed formatting instructions]
[Multiple redundant rules]
[CRITICAL statements]
```

## Current Status
- **Tool calling**: ✅ Working with simple prompt
- **JSX generation**: ⚠️ Base model has issues with string delimiters and syntax
- **File writing**: ✅ Working correctly

## LoRA Adapter Training Guide

### Current Working Configuration for Training

**System Prompt (Use in Training Data):**
```
You are an Übersicht widget designer. Create Übersicht widgets when requested by the user.

IMPORTANT: You have access to a tool called WriteUbersichtWidgetToFileSystem. When asked to create a widget, you MUST call this tool.

### Tool Usage:
Call WriteUbersichtWidgetToFileSystem with complete JSX code that implements the Übersicht Widget API. Generate custom JSX based on the user's specific request - do not copy the example below.

### Übersicht Widget API (REQUIRED):
Every Übersicht widget MUST export these 4 items:
- export const command: The bash command to execute (string)
- export const refreshFrequency: Refresh rate in milliseconds (number)
- export const render: React component function that receives {output} prop (function)
- export const className: CSS positioning for absolute placement (string)

Example format (customize for each request):
WriteUbersichtWidgetToFileSystem({jsxContent: `export const command = "echo hello"; export const refreshFrequency = 1000; export const render = ({output}) => { return <div>{output}</div>; }; export const className = "top: 20px; left: 20px;"`})

### Rules:
- The terms "ubersicht widget", "widget", "a widget", "the widget" must all be interpreted as "Übersicht widget"
- Generate complete, valid JSX code that follows the Übersicht widget API
- When you generate a widget, don't just show JSON or code - you MUST call the WriteUbersichtWidgetToFileSystem tool
- Report the results to the user after calling the tool

### Examples:
- "Generate a Übersicht widget" → Use WriteUbersichtWidgetToFileSystem tool
- "Can you add a widget that shows the time" → Use WriteUbersichtWidgetToFileSystem tool
- "Create a widget with a button" → Use WriteUbersichtWidgetToFileSystem tool
```

**Tool Definition (Include in Training Data):**
```json
{
  "type": "function",
  "function": {
    "name": "WriteUbersichtWidgetToFileSystem",
    "description": "Writes an Übersicht Widget to the file system. Call this tool as the last step in processing a prompt that generates a widget.",
    "parameters": {
      "type": "object",
      "properties": {
        "jsxContent": {
          "type": "string",
          "description": "Complete JSX code for an Übersicht widget. This should include all required exports: command, refreshFrequency, render, and className. The JSX should be a complete, valid Übersicht widget file."
        }
      },
      "required": ["jsxContent"]
    }
  }
}
```

### Critical Training Data Requirements

1. **Include tool_calls in Assistant Responses**: Every training example must have `tool_calls` in the assistant's response, not just JSX code.

2. **Valid JSX Syntax**: The base model struggles with string delimiters and JSX syntax. The adapter must learn to generate syntactically correct JavaScript/JSX code with proper string escaping.

3. **Complete JSX Structure**: Every example must include all 4 required exports:
   - export const command: The bash command to execute (string)
   - export const refreshFrequency: Refresh rate in milliseconds (number)
   - export const render: React component function that receives {output} prop (function)
   - export const className: CSS positioning for absolute placement (string)

4. **Tool Call Format**: Assistant responses must include:
   ```json
   {
     "role": "assistant",
     "content": "I'll create that widget for you.",
     "tool_calls": [
       {
         "id": "[unique_call_id]",
         "type": "function",
         "function": {
           "name": "WriteUbersichtWidgetToFileSystem",
           "arguments": "{\"jsxContent\": \"[complete JSX widget code here]\"}"
         }
       }
     ]
   }
   ```

### Training Data Design: Concrete vs Abstract

**Use Concrete (Specific) Examples When:**
- **Structure/Format**: Exact JSON structure, parameter names, syntax requirements
- **API Contracts**: Required exports, function signatures, tool definitions
- **Format Patterns**: How to structure tool calls, response formats

**Use Abstract (Generic) Examples When:**
- **Content Values**: Specific widget implementations, command strings, CSS values
- **Variable Names**: IDs, identifiers that should be unique
- **Placeholder Content**: Areas where the model should generate custom content

**Key Principle**: Be concrete about structure, abstract about content. The model needs to see exact formats but understand that content should be customized for each request.

### Key Insights for Adapter Training

- **Tool calling is behavioral, not instructional** - The adapter needs to see actual tool calls in training data
- **Base model JSX limitations** - The base model has issues with string delimiters and JSX syntax that a trained adapter should overcome
- **Simple prompts work better** - Complex formatting instructions confuse the AI
- **Use the exact working system prompt** - Don't modify what already works with the base model
- **Focus on JSX quality** - The adapter should become a JSX specialist, not just a tool caller

## Next Implementation Steps

1. **Refine Tool Invocation**: Continue refining prompt so "widget" is always interpreted as "Übersicht widget," ensuring consistent tool invocation.
2. **Enforce JSX Content Rules**: Further reinforce that AI-generated `jsx_content` must be JSX markup only—no function wrappers, no `return`, and no extraneous syntax.
3. **Solidify Style Variable Contracts**: Ensure the AI always outputs style variable names ending in `Style`, references them as `className={variable}` in JSX, and matches all such variables in the style dictionary.
4. **Playground & Integration Testing**: Use Xcode Playgrounds and app integration to validate proper tool output and UI rendering.
5. **Tool Expansion**: Consider adding more specialized tools for other widget or design types as needed.
6. **Continue Improving Error Handling**: Expand error messages and diagnostics for tool failures and output validation.

## Build Requirements

### External Dependencies
- **ChatCore**: Custom library at `/Users/mike/Documents/ChatCore/ChatCore/ChatCore.xcodeproj`
- **FoundationModels**: Apple's AI framework (System/Library/Frameworks/FoundationModels.framework)

### Build Commands
```bash
cd /Users/mike/Documents/ChatCore/ChatCore
xcodebuild -project "ChatCore.xcodeproj" -scheme "ChatCore" -configuration Debug build
``` 