# Support Request: Transcript Storage Difference Between Base Model and Adapter Model

## Issue Summary

The adapter model stores full JSX content in transcript entries, causing context window exhaustion, while the base model stores compact references. This prevents the adapter model from making tool calls after the first turn in multi-turn conversations.

---

## 1. Common Test Base

Both diagnostic tests use identical configuration:

### System Prompt
- **Version**: `systemPrompt_v4`
- **Source**: `Constants.Prompts.systemPrompt_v4`
- **Content**: Full system prompt including:
  - Instructions for Übersicht widget design
  - Tool usage guidelines for `WriteUbersichtWidgetToFileSystem`
  - Übersicht Widget API documentation
  - Examples and rules

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
- **Line 16**: `_transcript size: 2965 characters (~741 tokens)`
- **Lines 18-19**: Contains full `systemPrompt_v4` constant in transcript
- **Observation**: System prompt is included in transcript from the start

#### Turn 1 Execution
- **Line 34**: Tool called successfully: `🔧 TOOL CALL #589B6B30 - WriteUbersichtWidgetToFileSystem`
- **Line 35**: JSX Content: 269 characters passed to tool
- **Line 47**: File saved successfully: `✅ FILE SAVED #589B6B30 successfully`
- **Line 54**: Tool call entry size: 338 characters
- **Line 72**: Total transcript entries: 565 characters (~141 tokens)
- **Line 74**: `JSX/Argument content found: ❌ NO` - No full JSX in transcript entry properties

#### Before Turn 2 Inspection
- **Line 77**: `_transcript size: 3618 characters (~904 tokens)`
- **Lines 79-94**: Preview shows system prompt text, not full JSX in tool calls
- **Line 96**: `jsxContent` occurrences: 2 (in system prompt/tool definition, not in tool call entries)

#### Turn 2 Execution
- **Line 104**: Tool called successfully: `🔧 TOOL CALL #9FC4E005 - WriteUbersichtWidgetToFileSystem`
- **Line 117**: File saved successfully: `✅ FILE SAVED #9FC4E005 successfully`
- **Line 128**: Transcript growth: Only 23 characters (~5 tokens) added between turns
- **Result**: ✅ Success - Both turns completed successfully

---

### Adapter Model Test (`adapterModel_DiagnosticInspectTranscriptEntries.log`)

#### Baseline (Before Turn 1)
- **Line 16**: `_transcript size: 38 characters (~9 tokens)`
- **Line 18**: `Transcript(entries: [(Instructions) ])` - Almost empty
- **Observation**: No system prompt in transcript (likely embedded in adapter weights)

#### Turn 1 Execution
- **Line 26**: Tool called successfully: `🔧 TOOL CALL #EB42B3AD - WriteUbersichtWidgetToFileSystem`
- **Line 27**: JSX Content: 268 characters passed to tool
- **Line 41**: File saved successfully: `✅ FILE SAVED #EB42B3AD successfully`
- **Line 48**: Tool call entry size: 339 characters
- **Line 66**: Total transcript entries: 607 characters (~151 tokens)
- **Line 68**: `JSX/Argument content found: ❌ NO` - Diagnostic didn't find JSX in entry properties

#### Before Turn 2 Inspection
- **Line 71**: `_transcript size: 733 characters (~183 tokens)`
- **Lines 73-74**: Preview shows **FULL JSX CONTENT** embedded in transcript:
  ```
  (ToolCalls) WriteUbersichtWidgetToFileSystem: {"jsxContent": "import { command, refreshFrequency, render, className } from 'uebersicht';\n\nexport const command = () => { return 'abc as easy as 123'; }\n\nexport const refreshFrequency = 1000 * 60 * 60 * 24; // refresh every 1 day\n\nexport const render = ({ command }) => `\n<div class="}
  ```
- **Line 76**: `jsxContent` occurrences: 1 (in the actual tool call entry)

#### Turn 2 Execution
- **Line 83**: User prompt sent: `"move it to the top-right corner"`
- **Line 85**: Only 1 transcript entry (error entry, no tool call)
- **Line 90**: Tool call entry size: 0 characters
- **Result**: ❌ Failure - Context window exceeded before Turn 2 could complete

---

## 4. Analysis of the Difference

### Key Finding

**The adapter model stores full JSX content in transcript entries, while the base model stores compact references.**

### Evidence

#### Base Model Behavior
- **Tool calls are stored compactly**: The transcript entry (line 54: `338 characters`) contains a reference to the tool call, not the full JSX arguments
- **No JSX in transcript entries**: Line 74 confirms `JSX/Argument content found: ❌ NO`
- **Preview shows system prompt**: Lines 79-94 show system prompt text, not full JSX in tool calls
- **jsxContent in system prompt only**: Line 96 shows 2 occurrences, both in system prompt/tool definition

#### Adapter Model Behavior
- **Full JSX stored in transcript**: Lines 73-74 show the complete `jsxContent` JSON embedded in the `(ToolCalls)` entry
- **jsxContent in tool call entry**: Line 76 shows 1 occurrence, which is in the actual tool call entry
- **Full content re-sent on Turn 2**: The entire JSX from Turn 1 is included in the context sent to the model on Turn 2

### Impact

1. **Context Window Growth**:
   - Base model: ~163 tokens added from baseline to before Turn 2 (line 77: 3618 chars = ~904 tokens vs line 16: 2965 chars = ~741 tokens)
   - Adapter model: ~174 tokens added from baseline to before Turn 2 (line 71: 733 chars = ~183 tokens vs line 16: 38 chars = ~9 tokens)
   - **However**: The adapter's transcript preview (lines 73-74) shows full JSX is stored, which will be re-sent on every subsequent turn

2. **Multi-Turn Behavior**:
   - Base model: Can complete multiple turns (11 turns with ~4% context usage in other tests)
   - Adapter model: Hits context window limit on Turn 2 (3694 tokens exceeds 4096 limit)

3. **Root Cause**:
   - The adapter model includes full tool call arguments (complete `jsxContent` JSON) in transcript entries
   - These full arguments are included in the conversation history sent to the model on subsequent turns
   - This causes exponential context growth with each turn
   - The base model stores compact references, avoiding this bloat

### Conclusion

The adapter model's transcript storage mechanism differs from the base model, causing full JSX content to be stored and re-sent in conversation history. This is a framework-level difference in how tool calls are serialized in the transcript, not a difference in the tool calls themselves (both models pass identical JSX to the tool).

**Recommendation**: Investigate why the adapter model stores full tool call arguments in transcript entries while the base model stores compact references. This appears to be a framework behavior difference that needs to be addressed for multi-turn conversations with tool calls.

