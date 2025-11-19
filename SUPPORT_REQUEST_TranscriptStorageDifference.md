# Support Request: Context Window Exhaustion in Adapter Model Multi-Turn Conversations

## Issue Summary

The adapter model hits context window limits (3776 tokens exceeds 4096) on Turn 2 of multi-turn conversations, while the base model successfully completes multiple turns. Investigation reveals both models store full JSX content in transcript entries, but the adapter model's system prompt handling differs, causing context window exhaustion.

---

## 1. Common Test Base

Both diagnostic tests use identical configuration:

### System Prompt
- **Version**: `systemPrompt_v4`
- **Source**: `Constants.Prompts.systemPrompt_v4`
- **Full Text**:
```
A conversation between a user and a helpful assistant. You are an Übersicht widget designer. Create Übersicht widgets when requested by the user.

IMPORTANT: You have access to a tool called WriteUbersichtWidgetToFileSystem. You MUST call this tool whenever:
- Creating a new widget
- Modifying or updating an existing widget
- Making any changes to widget code requested by the user

### Tool Usage:
Call WriteUbersichtWidgetToFileSystem with complete JSX code that implements the Übersicht Widget API. 
- For new widgets: Generate custom JSX based on the user's specific request
- For modifications: Generate the updated/complete widget code incorporating the requested changes
Always provide the complete, final widget code - do not copy the example below.

### Übersicht Widget API:
Übersicht widgets should export at least one of these properties (all are optional, but most widgets use them):
- export const command: The bash command to execute (string or function). Optional - if refreshFrequency is false, command is not needed.
- export const refreshFrequency: Refresh rate in milliseconds (number). Optional - defaults to 1000ms if not provided. Can be set to false to disable auto-refresh.
- export const render: React component function that receives props (function). Optional - defaults to returning output if not provided.
- export const className: CSS positioning for absolute placement (string or object). Optional - used for positioning/styling the widget.

IMPORTANT: Use "export const" syntax, NOT comments. Each export must be on its own line with proper syntax.

Example format (customize for each request):
WriteUbersichtWidgetToFileSystem({"jsxContent": "export const command = \"echo hello\";\nexport const refreshFrequency = 1000;\nexport const render = ({output}) => {\n  return <div>{output}</div>;\n};\nexport const className = \"top: 20px; left: 20px;\";"})

### Rules:
- The terms "ubersicht widget", "widget", "a widget", "the widget" must all be interpreted as "Übersicht widget"
- Generate complete, valid JSX code that follows the Übersicht widget API
- When you create OR modify a widget, you MUST call the WriteUbersichtWidgetToFileSystem tool with the complete updated code
- For modifications: Generate the full widget code with all changes incorporated, then call the tool
- Report the results to the user after calling the tool

### Examples:
- "Generate a Übersicht widget" → Use WriteUbersichtWidgetToFileSystem tool
- "Can you add a widget that shows the time" → Use WriteUbersichtWidgetToFileSystem tool
- "Create a widget with a button" → Use WriteUbersichtWidgetToFileSystem tool
- "Make the font bigger" → Generate updated widget code → Use WriteUbersichtWidgetToFileSystem tool
- "Change the color to blue" → Generate updated widget code → Use WriteUbersichtWidgetToFileSystem tool
- "Add a border to the widget" → Generate updated widget code → Use WriteUbersichtWidgetToFileSystem tool
```

### User Prompts
Both tests use the centralized prompt sequence from `ContextWindowTestPrompts`:

**Turn 1:**
- Prompt: `"generate a widget that says \"abc as easy as 123\""`
- Source: `ContextWindowTestPrompts.initialPrompt`

**Turn 2:**
- Prompt: `"move it to the top-right corner"`
- Source: `ContextWindowTestPrompts.incrementalPrompts[0]`

### Test Configuration
- **Test Function**: `runDiagnosticForModel()` in `LanguageModelComparisonTests_v4.swift`
- **Base Model Test**: `baseModel_DiagnosticInspectTranscriptEntries`
- **Adapter Model Test**: `adapterModel_DiagnosticInspectTranscriptEntries`
- **Both tests**: Inspect transcript entries before Turn 1, after Turn 1, and after Turn 2

---

## 2. Log Files Setup

Full diagnostic logs are provided separately:
- `baseModel_DiagnosticInspectTranscriptEntries.log` - Base model diagnostic output
- `adapterModel_DiagnosticInspectTranscriptEntries.log` - Adapter model diagnostic output

### Log Structure
Both logs contain:
1. **Baseline Inspection**: Session `_transcript` inspection before Turn 1
2. **Turn 1 Section**: User prompt, tool call execution, transcript entry analysis
3. **Before Turn 2 Inspection**: Session `_transcript` inspection after Turn 1
4. **Turn 2 Section**: User prompt, tool call execution (or failure), transcript entry analysis
5. **After Turn 2 Inspection**: Final session `_transcript` inspection

Sections are separated by horizontal lines (`================================================================================`) for clarity.

---

## 3. Test Execution Summary

### Base Model Test (`baseModel_DiagnosticInspectTranscriptEntries.log`)

#### Baseline (Before Turn 1)
- **Line 16**: `_transcript size: 2965 characters (~741 tokens)` (line 16: `_transcript size: 2965 characters (~741 tokens)`)
- **Lines 18-26**: Contains full `systemPrompt_v4` constant in transcript (lines 18-26: preview shows system prompt text starting with "A conversation between a user and a helpful assistant...")
- **Observation**: System prompt is stored in the transcript from the start

#### Turn 1 Execution
- **Line 33**: User prompt sent: `"generate a widget that says \"abc as easy as 123\""` (line 33: `📝 User: generate a widget that says "abc as easy as 123"`)
- **Line 75**: Tool call entry shows full JSX content: `(ToolCalls) WriteUbersichtWidgetToFileSystem: {"jsxContent": "export const command = null;\nexport const refreshFrequency = 1000;\nexport const render = ({output}) => { \n  return <div>{output}</div>;\n};\nexport const className = \"top: 20px;\";\n"}` (line 75: Full entry string representation shows complete JSON with jsxContent)
- **Line 100**: Total transcript size: 719 characters (~179 tokens) (line 100: `📊 Total transcript size: 719 characters (~179 tokens)`)
- **Line 102**: `JSX/Argument content found: ❌ NO` - Diagnostic check didn't find JSX in entry properties (line 102: `JSX/Argument content found: ❌ NO`)

#### Before Turn 2 Inspection
- **Line 105**: `_transcript size: 3772 characters (~943 tokens)` (line 105: `_transcript size: 3772 characters (~943 tokens)`)
- **Lines 107-122**: Preview shows system prompt text in transcript (lines 107-122: preview shows full system prompt starting with "A conversation between a user and a helpful assistant...")
- **Line 123**: `jsxContent` occurrences: 2 (line 123: `⚠️   Occurrences: 2`)
- **Observation**: System prompt (2965 chars) + Turn 1 entries (719 chars) = ~3684 chars, actual transcript is 3772 chars

#### Turn 2 Execution
- **Line 131**: User prompt sent: `"move it to the top-right corner"` (line 131: `📝 User: move it to the top-right corner`)
- **Line 169**: Tool call entry size: 448 characters (~112 tokens) (line 169: `📊 Tool call entry size: 448 characters (~112 tokens)`)
- **Line 174**: Transcript growth: 115 characters (~28 tokens) added between turns (line 174: `📊 Transcript size growth: 115 characters (~28 tokens)`)
- **Line 178**: After Turn 2: `_transcript size: 4677 characters (~1169 tokens)` (line 178: `_transcript size: 4677 characters (~1169 tokens)`)
- **Result**: ✅ Success - Both turns completed successfully

---

### Adapter Model Test (`adapterModel_DiagnosticInspectTranscriptEntries.log`)

#### Baseline (Before Turn 1)
- **Line 16**: `_transcript size: 38 characters (~9 tokens)` (line 16: `_transcript size: 38 characters (~9 tokens)`)
- **Line 18**: `Transcript(entries: [(Instructions) ])` - Almost empty (line 18: `Transcript(entries: [(Instructions) ])`)
- **Observation**: System prompt is NOT stored in transcript (likely embedded in adapter weights or handled separately)

#### Turn 1 Execution
- **Line 25**: User prompt sent: `"generate a widget that says \"abc as easy as 123\""` (line 25: `📝 User: generate a widget that says "abc as easy as 123"`)
- **Line 55**: Tool call entry shows full JSX content: `(ToolCalls) WriteUbersichtWidgetToFileSystem: {"jsxContent": "// {command} {refreshFrequency} {render} {className}"}` (line 55: Full entry string representation shows complete JSON with jsxContent)
- **⚠️ CRITICAL QUALITY ISSUE**: The adapter model generated **invalid JSX code** - just a comment with placeholders: `"// {command} {refreshFrequency} {render} {className}"`. This is not valid widget code and would not work. Compare to base model which generated proper JSX with actual exports (line 75 in base model log).
- **Line 76**: Total transcript size: 382 characters (~95 tokens) (line 76: `📊 Total transcript size: 382 characters (~95 tokens)`)
- **Line 78**: `JSX/Argument content found: ❌ NO` - Diagnostic check didn't find JSX in entry properties (line 78: `JSX/Argument content found: ❌ NO`)

#### Before Turn 2 Inspection
- **Line 81**: `_transcript size: 508 characters (~127 tokens)` (line 81: `_transcript size: 508 characters (~127 tokens)`)
- **Lines 83-84**: Preview shows transcript entries including full JSX in tool call: `Transcript(entries: [(Instructions) , (Prompt) generate a widget that says "abc as easy as 123" Response Format: <nil>, (ToolCalls) WriteUbersichtWidgetToFileSystem: {"jsxContent": "// {command} {refreshFrequency} {render} {className}"}, ...]` (lines 83-84: preview shows full transcript structure with tool call containing jsxContent)
- **Line 86**: `jsxContent` occurrences: 1 (in the actual tool call entry) (line 86: `⚠️   Occurrences: 1`)
- **Observation**: Transcript only contains Turn 1 entries (382 chars) + some overhead = 508 chars. System prompt is NOT in transcript.

#### Turn 2 Execution
- **Line 93**: User prompt sent: `"move it to the top-right corner"` (line 93: `📝 User: move it to the top-right corner`)
- **Line 96**: Context window exceeded: `Content contains 3776 tokens, which exceeds the maximum allowed context size of 4096` (line 96: `❌ Error: Content contains 3776 tokens, which exceeds the maximum allowed context size of 4096.`)
- **Line 106**: Context window exceeded: 3708 tokens / 4096 max (line 106: `📊 Context window exceeded: 3708 tokens / 4096 max`)
- **Result**: ❌ Failure - Context window exceeded before Turn 2 could complete

---

## 4. Analysis of the Difference

### Key Finding

**Both models store full JSX content in transcript entries. The difference is in system prompt handling: the base model stores the system prompt in the transcript, while the adapter model does not, but the adapter model still includes the system prompt when building context for API calls, causing context window exhaustion.**

### Evidence

#### Tool Call Storage (Both Models)
- **Both models store full JSX**: 
  - Base model (line 75): `(ToolCalls) WriteUbersichtWidgetToFileSystem: {"jsxContent": "export const command = null;\nexport const refreshFrequency = 1000;..."}`
  - Adapter model (line 55): `(ToolCalls) WriteUbersichtWidgetToFileSystem: {"jsxContent": "// {command} {refreshFrequency} {render} {className}"}`
- **No "compact" storage difference**: Both models store the complete JSON with `jsxContent` in transcript entries
- **Same storage format**: Both use identical `{"jsxContent": "..."}` format in tool call entries

#### System Prompt Handling (Critical Difference)

**Base Model:**
- **System prompt stored in transcript**: Baseline shows 2965 characters (~741 tokens) which is the full system prompt (line 16)
- **Visible in transcript preview**: Lines 107-122 show the full system prompt text in the transcript
- **Before Turn 2 transcript**: 3772 characters (~943 tokens) = system prompt (2965) + Turn 1 entries (719) + overhead
- **System prompt counted in transcript size**: The transcript inspection accurately reflects what's sent to the API

**Adapter Model:**
- **System prompt NOT stored in transcript**: Baseline shows only 38 characters (~9 tokens) - just empty `(Instructions)` entry (line 16)
- **NOT visible in transcript preview**: Lines 83-84 show transcript entries but no system prompt text
- **Before Turn 2 transcript**: 508 characters (~127 tokens) = only Turn 1 entries (382) + overhead
- **System prompt NOT counted in transcript size**: The transcript inspection does NOT show the system prompt, but it's still included when building context for language model API calls (requests to the model service, not tool calls)

### The Problem

When the adapter model builds the context for Turn 2 language model API call (the request sent to the model service to generate a response):
1. **Transcript shows**: 508 characters (~127 tokens)
2. **Actual context sent to model API**: 3776 tokens (exceeds 4096 limit)
3. **Difference**: ~3649 tokens unaccounted for in transcript inspection

This suggests the adapter model's framework is:
- Including the system prompt (~741 tokens) when building context for language model API requests
- Including additional overhead or serialization
- Not reflecting this in the `_transcript` property that's being inspected

The base model, in contrast:
- Stores system prompt in transcript (visible in inspection)
- Transcript size accurately reflects what's sent to the language model API
- No hidden context additions

**Note**: "API calls" here refers to calls to the language model's API (FoundationModels framework → model service), not calls to the custom tool (`WriteUbersichtWidgetToFileSystem`). Tool calls are made BY the model in response to API requests.

### Impact

1. **Context Window Calculation**:
   - Base model: Transcript inspection (3772 chars = ~943 tokens) accurately reflects language model API context size
   - Adapter model: Transcript inspection (508 chars = ~127 tokens) does NOT reflect actual language model API context size (3776 tokens)
   - **The adapter model includes ~3649 tokens that are not visible in the transcript inspection when building context for language model API requests**

2. **Multi-Turn Behavior**:
   - Base model: Can complete multiple turns (11 turns with ~4% context usage in other tests)
   - Adapter model: Hits context window limit on Turn 2 (3776 tokens exceeds 4096 limit)

3. **Root Cause**:
   - The adapter model's framework includes the system prompt when building API context, even though it's not stored in the `_transcript` property
   - This hidden inclusion causes the context to exceed the 4096 token limit on Turn 2
   - The base model stores the system prompt in the transcript, making it visible and accurately counted

### Additional Finding: JSX Code Quality Issue

**Critical Quality Problem**: The adapter model generated **invalid JSX code** in the diagnostic test:
- **Adapter model output**: `"// {command} {refreshFrequency} {render} {className}"` - Just a comment with placeholders, not executable code
- **Base model output**: `"export const command = null;\nexport const refreshFrequency = 1000;\nexport const render = ({output}) => { \n  return <div>{output}</div>;\n};\nexport const className = \"top: 20px;\";\n"` - Valid, executable widget code

This is particularly concerning because the adapter model was fine-tuned specifically for this task, yet it's producing worse output than the base model. This suggests either:
1. The fine-tuning data contained poor examples
2. The adapter model is not properly following the system prompt instructions
3. There's an issue with how the adapter model generates tool call arguments

**Note**: This quality issue is separate from the context window problem but indicates a fundamental problem with the adapter model's performance on this task.

### Conclusion

The issue is not in how tool calls are stored (both models store full JSX content identically), but in how the system prompt is handled:

- **Base model**: System prompt is stored in `_transcript`, making it visible and accurately counted. Also generates valid JSX code.
- **Adapter model**: System prompt is NOT stored in `_transcript`, but is still included when building context for API calls, causing hidden context bloat. Additionally generates invalid JSX code (placeholder comments instead of actual widget code).

**Recommendations**: 

1. **Context Window Issue**: Investigate why the adapter model's framework includes the system prompt in language model API context (the context sent when making requests to the model service) even though it's not stored in the `_transcript` property. The framework should either:
   - Store the system prompt in `_transcript` (like the base model), OR
   - Exclude the system prompt from language model API context calculations if it's truly embedded in adapter weights

2. **Code Quality Issue**: Investigate why the adapter model generates invalid JSX code (placeholder comments) instead of proper widget code. This suggests the fine-tuning may not have been effective or the adapter model is not properly following instructions.

This framework-level difference in system prompt handling needs to be addressed for multi-turn conversations with tool calls.

**Clarification**: "API calls" in this document refers to calls to the language model's API (FoundationModels framework → model service), not calls to custom tools like `WriteUbersichtWidgetToFileSystem`. Tool calls are made by the model in response to language model API requests.
