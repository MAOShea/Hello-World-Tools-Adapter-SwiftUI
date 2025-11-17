# Compact Tool Calls: Implementation Guide

## What Are Compact Tool Calls?

**Compact tool calls** store only the tool name/ID in the training data, without including the full function arguments. This is similar to how the base model's function calling API works - it references tools by name, and the framework handles argument extraction separately.

**Full tool calls** (current format) include the complete arguments JSON string, which causes the adapter to store full jsxContent in the transcript, leading to context window exhaustion.

## Current Format (Full Arguments) ❌

This is what you're currently using, which causes the context window issue:

```json
{
  "role": "assistant",
  "content": "I'll create that widget for you.",
  "tool_calls": [
    {
      "id": "call_abc123",
      "type": "function",
      "function": {
        "name": "WriteUbersichtWidgetToFileSystem",
        "arguments": "{\"jsxContent\": \"export const command = \\\"echo hello\\\";\\nexport const refreshFrequency = 1000;\\nexport const render = ({output}) => {\\n  return <div>{output}</div>;\\n};\\nexport const className = \\\"top: 20px; left: 20px;\\\";\"}"
      }
    }
  ]
}
```

**Problem**: The complete `jsxContent` JSON string is included in the tool call, which:
- Gets stored in full in the transcript
- Is included in conversation history on subsequent turns
- Causes context window to exceed 4096 tokens on turn 2

**Size**: ~200-300 characters per tool call (with full JSX code)

## Compact Format (No Arguments) ✅

This is what you should use instead:

```json
{
  "role": "assistant",
  "content": "I'll create that widget for you.",
  "tool_calls": [
    {
      "id": "call_abc123",
      "type": "function",
      "function": {
        "name": "WriteUbersichtWidgetToFileSystem"
      }
    }
  ]
}
```

**Key Difference**: 
- **NO `"arguments"` field** - only the tool name
- The framework will extract arguments from the assistant's content or handle them separately
- Much smaller: ~50-100 characters per tool call

**Size**: ~50-100 characters per tool call (just tool name + metadata)

## Complete Training Example Comparison

### Full Format (Current) ❌

```json
[
  {
    "role": "system",
    "content": "[system prompt with tool definition]",
    "tools": [
      {
        "type": "function",
        "function": {
          "name": "WriteUbersichtWidgetToFileSystem",
          "description": "Writes an Übersicht Widget to the file system...",
          "parameters": {
            "type": "object",
            "properties": {
              "jsxContent": {
                "type": "string",
                "description": "Complete JSX code for an Übersicht widget..."
              }
            },
            "required": ["jsxContent"]
          }
        }
      }
    ]
  },
  {
    "role": "user",
    "content": "Create a widget that displays 'Hello World'"
  },
  {
    "role": "assistant",
    "content": "I'll create that widget for you.",
    "tool_calls": [
      {
        "id": "call_abc123",
        "type": "function",
        "function": {
          "name": "WriteUbersichtWidgetToFileSystem",
          "arguments": "{\"jsxContent\": \"export const command = \\\"echo Hello World\\\";\\nexport const refreshFrequency = 1000;\\nexport const render = ({output}) => {\\n  return <div>{output}</div>;\\n};\\nexport const className = \\\"top: 20px; left: 20px;\\\";\"}"
        }
      }
    ]
  },
  {
    "role": "tool",
    "tool_call_id": "call_abc123",
    "content": "Widget written successfully"
  },
  {
    "role": "assistant",
    "content": "I've created the widget for you. It displays 'Hello World'."
  }
]
```

### Compact Format (Recommended) ✅

```json
[
  {
    "role": "system",
    "content": "[system prompt with tool definition]",
    "tools": [
      {
        "type": "function",
        "function": {
          "name": "WriteUbersichtWidgetToFileSystem",
          "description": "Writes an Übersicht Widget to the file system...",
          "parameters": {
            "type": "object",
            "properties": {
              "jsxContent": {
                "type": "string",
                "description": "Complete JSX code for an Übersicht widget..."
              }
            },
            "required": ["jsxContent"]
          }
        }
      }
    ]
  },
  {
    "role": "user",
    "content": "Create a widget that displays 'Hello World'"
  },
  {
    "role": "assistant",
    "content": "I'll create that widget for you. Here's the code:\n\nexport const command = \"echo Hello World\";\nexport const refreshFrequency = 1000;\nexport const render = ({output}) => {\n  return <div>{output}</div>;\n};\nexport const className = \"top: 20px; left: 20px;\";",
    "tool_calls": [
      {
        "id": "call_abc123",
        "type": "function",
        "function": {
          "name": "WriteUbersichtWidgetToFileSystem"
        }
      }
    ]
  },
  {
    "role": "tool",
    "tool_call_id": "call_abc123",
    "content": "{\"jsxContent\": \"export const command = \\\"echo Hello World\\\";\\nexport const refreshFrequency = 1000;\\nexport const render = ({output}) => {\\n  return <div>{output}</div>;\\n};\\nexport const className = \\\"top: 20px; left: 20px;\\\";\"}"
  },
  {
    "role": "assistant",
    "content": "I've created the widget for you. It displays 'Hello World'."
  }
]
```

**Key Changes**:
1. **Assistant's `tool_calls`**: Removed `"arguments"` field, only includes `"name"`
2. **JSX Code Location**: The JSX code is now in the assistant's `"content"` field (as plain text), not in the tool call arguments
3. **Tool Response**: The tool response includes the full arguments JSON (this is how the framework receives the actual data)

## How to Modify Your Training Data Generation Script

### Step 1: Identify Where Tool Calls Are Generated

Find the code that creates assistant messages with `tool_calls`. It likely looks something like:

```python
assistant_message = {
    "role": "assistant",
    "content": "I'll create that widget for you.",
    "tool_calls": [
        {
            "id": f"call_{generate_id()}",
            "type": "function",
            "function": {
                "name": "WriteUbersichtWidgetToFileSystem",
                "arguments": json.dumps({"jsxContent": jsx_code})  # ❌ REMOVE THIS
            }
        }
    ]
}
```

### Step 2: Modify to Use Compact Format

Change it to:

```python
# Put the JSX code in the assistant's content instead
assistant_content = f"I'll create that widget for you. Here's the code:\n\n{jsx_code}"

assistant_message = {
    "role": "assistant",
    "content": assistant_content,
    "tool_calls": [
        {
            "id": f"call_{generate_id()}",
            "type": "function",
            "function": {
                "name": "WriteUbersichtWidgetToFileSystem"
                # ✅ NO "arguments" field
            }
        }
    ]
}
```

### Step 3: Ensure Tool Response Includes Arguments

The tool response should still include the full arguments (this is how the framework receives the actual data):

```python
tool_response = {
    "role": "tool",
    "tool_call_id": assistant_message["tool_calls"][0]["id"],
    "content": json.dumps({"jsxContent": jsx_code})  # ✅ Keep this in tool response
}
```

## Why This *Might* Work (Uncertain)

**Hypothesis**: By removing arguments from tool calls, FoundationModels might:
1. Store tool calls more compactly (just metadata, not full arguments)
2. Extract arguments from tool responses instead of storing them in tool call entries
3. Match the base model's function calling API behavior

**However**, this is unproven. The key question is: **Where does the JSX code go, and how does it get stored?**

**Alternative Hypothesis**: Maybe the JSX code shouldn't be in the training data at all in a way that gets stored in the transcript. Perhaps:
- Tool calls reference tools by name only
- Arguments are provided separately (in tool responses?)
- The framework handles argument extraction differently

**We need to verify** what the base model actually does before assuming this approach will work.

## ⚠️ CRITICAL UNCERTAINTY

**Important Question**: If we put JSX code in the assistant's `content` field instead of tool call arguments, it will still be in the conversation history and will still consume context window tokens. So how does this actually help?

**The Real Question**: How does the base model handle this? The evidence shows:
- Base model turn 2 transcript entry: ~586 chars (~146 tokens)
- Adapter model turn 2 transcript entry: 2300 chars (~575 tokens)

The base model stores tool calls more compactly, but we don't know exactly HOW. Possible explanations:

1. **Framework Behavior**: FoundationModels might handle tool calls differently for base model (function calling API) vs adapter (training format matching)
2. **Argument Extraction**: The framework might extract arguments from tool responses rather than storing them in tool call entries
3. **Transcript Structure**: Tool calls might be stored separately from message content, and only tool call metadata (not arguments) is included in transcript entries

**We Need to Investigate**:
- What does the base model actually generate? Does it put JSX in content, in tool call arguments, or somewhere else?
- How does FoundationModels store base model tool calls vs adapter tool calls?
- Is there a way to make the adapter use the same storage mechanism as the base model?

## Important Notes

1. **JSX Code Location**: ⚠️ **UNCERTAIN** - Putting JSX in assistant's `content` will still consume tokens. We need to verify how the base model actually handles this.
2. **Tool Response**: The tool response should still include the full arguments JSON - this is how the framework receives the actual data to execute
3. **System Message**: Keep the tool definition in the system message (the patch you showed extracts this separately, which is good)
4. **Training Consistency**: All training examples should use the compact format consistently
5. **Investigation Needed**: Before retraining, we should verify what format the base model actually uses in practice

## Expected Impact

After retraining with compact tool calls:
- **Turn 1 transcript entry**: ~100-150 chars (instead of ~200-300 chars)
- **Turn 2 transcript entry**: ~100-150 chars (instead of ~2300 chars)
- **Context window usage**: Should stay well under 4096 tokens for multi-turn conversations
- **Storage efficiency**: 3-4x reduction in transcript size per tool call

## Verification

After retraining, run the diagnostic test (`diagnosticInspectTranscriptEntries`) to verify:
- `_transcript` entries should be ~100-150 chars per tool call
- No `jsxContent` should appear in tool call transcript entries
- Context window should remain under 4096 tokens for multiple turns

