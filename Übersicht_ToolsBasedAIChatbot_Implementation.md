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
- **JSX generation**: ✅ Working correctly
- **File writing**: ✅ Working correctly

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