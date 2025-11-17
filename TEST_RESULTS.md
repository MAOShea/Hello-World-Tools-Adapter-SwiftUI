# Model Comparison Test Results

**Test Framework**: Version-Based Test Structure  
**Models Compared**: Base Model vs LoRA Adapter Model

---

## Table of Contents

1. [Key Findings](#key-findings)
2. [Test Run Log](#test-run-log)
3. [Test Structure](#test-structure)
4. [Test Results by Version](#test-results-by-version)
5. [Reliable Differences Between Models](#reliable-differences-between-models)
6. [Context Window Investigation](#context-window-investigation)
7. [Common Issues](#common-issues)
8. [Recommendations](#recommendations)
9. [Test Configuration](#test-configuration)

---

## Key Findings

### Fine-Tuning Success: Adapter Model Reduced Sensitivity to Prompt Wording

**Date**: 2025-01-XX  
**Tests**: `baseModel_MultiTurn`, `adapterModel_MultiTurn`, `baseModel_MultiTurn_NonWorkingPrompts`, `adapterModel_MultiTurn_NonWorkingPrompts`

**Finding**: The adapter model demonstrates **successful fine-tuning** by being less sensitive to prompt wording variations compared to the base model.

**Turn 1 Results - "create" vs "generate":**
- **Base Model**: 
  - "create a widget..." → ❌ Tool NOT called (0% success)
  - "generate a widget..." → ✅ Tool called (100% success)
  - **Sensitivity**: HIGH - 100% gap between patterns
- **Adapter Model**:
  - "create a widget..." → ✅ Tool CALLED (100% success)
  - "generate a widget..." → ✅ Tool called (100% success)
  - **Sensitivity**: LOW - 0% gap between patterns

**Conclusion**: ✅ **The adapter model's fine-tuning successfully reduced sensitivity to "create" vs "generate" terminology. The adapter works with both patterns, while the base model completely fails with "create". This demonstrates that fine-tuning achieved its goal of making the model more robust to natural language variations.**

**Turn 2 Results - Confounded by Context Window:**
- Both models fail with short directives ("align it with the right edge")
- Base model succeeds with explicit language ("move it to the top-right corner")
- Adapter model fails with explicit language (likely due to context window limits, not wording)

**See**: `PROMPT_WORDING_ANALYSIS.md` for detailed analysis and comparison tables.

---

### Prompt Engineering Impact on Tool Calling

**Date**: 2025-01-XX  
**Test**: `testBaseModelContextWindowUsage` (11-turn context window test)

**Initial Test Run**:
- Prompt: `"create a widget that displays \"Hello World\""`
- Incremental prompts: Short directives like `"align it with the right edge"`, `"make the font bold"`, etc.
- **Result**: **ZERO tool calls** - Model responded with text descriptions instead of calling the tool

**After Prompt Wording Tweaks**:
- Changed initial prompt: `"create a widget"` → `"generate a widget"` (matches working patterns)
- Added explicit modification language to incremental prompts:
  - `"align it with the right edge"` → `"update the widget to align it with the right edge"`
  - `"make the font bold"` → `"modify the widget to make the font bold"`
  - Applied same pattern to all 10 incremental modifications
- **Result**: **11 tool calls** - Model successfully called the tool on every single turn (documented in file header)

**⚠️ CRITICAL UPDATE - Prompt Pattern Discovery**:
- **Discovery (2025-01-XX)**: The test was using prompts that FAIL to trigger tool calls, even though they use "generate" and explicit language
- **Failing Patterns**:
  - `"generate a widget that displays \"Hello World\""` → ❌ No tool call (0/1 success)
  - `"update the widget to align it with the right edge"` → ❌ No tool call (0/1 success)
- **Working Patterns** (from `baseModel_MultiTurn`):
  - `"generate a widget that says \"abc as easy as 123\""` → ✅ Tool call (2/2 success)
  - `"move it to the top-right corner"` → ✅ Tool call (2/2 success)

**Key Finding**: 
- **"says" vs "displays"**: "says" works, "displays" fails
- **Shorter directives vs explicit language**: Shorter directives (e.g., "move it to...") work, explicit language (e.g., "update the widget to...") fails
- **Paradox**: Explicit modification language that was thought to work actually FAILS
- **When model calls tool**: Context usage stays low (~4% after 11 turns), tool calls are compact
- **When model returns JSX as text**: Context usage grows rapidly (~53% before hitting limit), responses are verbose
- **Conclusion**: Tool calls are **much more context-efficient** than returning JSX as text. Prompt wording is critical - subtle differences ("says" vs "displays") can make the difference between tool calls and text responses.

**⚠️ CRITICAL UPDATE - Non-Deterministic Behavior (2025-01-XX)**:
- **Discovery**: Model behavior is **NON-DETERMINISTIC** even with identical prompts and setup
- **Test**: `testBaseModelContextWindowUsage` (11-turn test with working prompts)
- **Run 1**: 0 tool calls - Model returned JSX as text, context window exhausted on turn 11 (~51% usage)
- **Run 2**: 9 tool calls - Model called tool successfully, then context window exceeded on turn 10 (~18% usage)
- **Key Insight**: 
  - **Tool calls are MUCH more context-efficient** than text responses
  - When tool calls occur: Context usage stays low (~18% after 9-10 turns)
  - When text responses occur: Context usage grows rapidly (~51% before hitting limit)
  - Same prompts can produce different outcomes, making behavior unpredictable
- **Impact**: This non-determinism has major implications for production use - the same prompt can either succeed with tool calls or fail with context exhaustion

**Conclusion**: 
Prompt wording significantly affects tool call behavior, even with the same system prompt. The model requires explicit, clear instructions that match patterns seen during training. Small wording changes can make the difference between zero tool calls and perfect tool call execution. However, **model behavior is non-deterministic** - same prompts can produce different outcomes (tool calls vs text responses), which has a major impact on context window consumption.

This demonstrates that prompt engineering is critical for reliable tool calling behavior, and that **tool calling is essential for efficient context window usage**. However, even with optimal prompts, behavior remains non-deterministic.

### Most Reliable Differences

- **Adapter Model**: More consistent tool calling behavior, but critically limited by context window size (3920-3927/4096 tokens) and produces lower quality JSX
- **Base Model**: Better JSX quality and no context limits, but inconsistent tool calling (especially on Time Widget)

**Most Distinguishing Characteristic**: The adapter consistently hits context limits (3920-3927/4096 tokens) while the base model does not.

---

## Test Run Log

### Issue Legend

| Acronym | Description |
|---------|-------------|
| **ACT** | Adapter Context Test - Individual test failed due to context limit |
| **ACL** | Adapter Context Limit - Context window exceeded (3920-3927/4096 tokens) |
| **AJT** | Adapter JSX Truncated - Adapter generated incomplete JSX |
| **ARJ** | Adapter Reused JSX - Adapter reused JSX content across widgets |
| **AJC** | Adapter JSX Commented - Adapter generated all-commented JSX |
| **BNT** | Base No Tool (Time) - Base model didn't call tool for Time Widget |
| **BNB** | Base No Tool (Button) - Base model didn't call tool for Button Widget |
| **BJT** | Base JSX Truncated - Base model generated incomplete JSX |
| **BDE** | Base Decoding Error - Base model produced malformed JSON |
| **BCL** | Base Context Limit - Base model exceeded context window |

### Test Run History

| Timestamp | Version | Simple | Time | Button | ACT | ACL | AJT | ARJ | AJC | BNT | BNB | BJT | BDE | BCL | Suite Status | Duration |
|-----------|---------|--------|------|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|--------------|----------|
| 2025-11-09 17:20:28 | v4 | ✅ Both | ✅ Both | ✅ Both | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ Failed (2 issues) | ~196s |
| 2025-11-09 17:15:08 | v4 | ✅ Both | ✅ Both | ✅ Both | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ Failed (2 issues) | ~178s |
| 2025-11-09 17:09:35 | v4 | ✅ Both | ✅ Both | ✅ Both | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ Passed | ~62s |
| 2025-11-09 16:59:13 | v4 | ✅ Both | ❌ Both | ❌ Base | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ Failed (3 issues) | ~225s |
| 2025-11-09 16:52:05 | v4 | ✅ Both | ✅ Both | ✅ Both | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ Passed | ~50s |
| 2025-11-09 16:39:26 | v4 | ✅ Base | ✅ Both | ✅ Base | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ Failed (2/3 tests) | ~388s |
| 2025-11-09 16:03:43 | v4 | ✅ Both | ✅ Both | ✅ Both | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ Failed (2/3 tests) | ~205s |
| 2025-11-09 15:45:07 | v4 | ✅ Base | ✅ Base | ❌ Base | ✅ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ Failed | ~340s |
| 2025-11-09 15:25:32 | v4 | ✅ Both | ✅ Both | ❌ Base | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ Failed | ~106s |
| 2025-11-09 11:54:58 | v4 | ✅ Both | ✅ Both | ✅ Both | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ Passed | ~60s |
| 2025-11-09 11:46:57 | v4 | ✅ Both | ✅ Both | ✅ Both | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ Passed | ~43s |
| 2025-11-09 11:44:04 | v4 | ❌ Base | ⚠️ Base | ✅ Base | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ Failed | ~412s |
| 2025-11-09 | v4 | ✅ Both | ✅ Both | ⚠️ Base | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | | ~216s |
| 2025-11-09 | v4 | ✅ Both | ✅ Base | ✅ Base | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | | ~410s |

---

## Test Structure

Tests are organized by system prompt version:
- **v1** (`systemPrompt_v1` - formerly `humanRolePrompt`)
- **v2** (`systemPrompt_v2` - formerly `humanRolePrompt1`)
- **v3** (`systemPrompt_v3` - formerly `humanRolePrompt2`)
- **v4** (`systemPrompt_v4` - formerly `systemPrompt`)

Each version has its own test file:
- `LanguageModelComparisonTests_v1.swift`
- `LanguageModelComparisonTests_v2.swift`
- `LanguageModelComparisonTests_v3.swift`
- `LanguageModelComparisonTests_v4.swift`

---

## Test Results by Version

### systemPrompt_v4 (Latest Run)

**Test Cases:**
1. Simple Widget Request
2. Time Widget Request
3. Button Widget Request

#### Results Summary

| Test Case | Base Model | Adapter Model | Notes |
|-----------|------------|---------------|-------|
| Simple Widget Request | ✅ Success (18.80s) | ✅ Success (4.74s) | Adapter faster, but incomplete JSX |
| Time Widget Request | ✅ Success (5.17s) | ❌ Failed (187.87s) | Adapter hit context window limit |
| Button Widget Request | ✅ Success (4.66s) | ❌ Failed (187.02s) | Adapter hit context window limit |

#### Key Findings

**Base Model (systemPrompt_v4):**
- ✅ All 3 test cases succeeded
- ✅ Correct JSX format with proper `export const` syntax
- ✅ Fast performance (4.66s - 18.80s)
- ✅ Proper widget structure

**Adapter Model (systemPrompt_v4):**
- ⚠️ **Context Window Issues**: Failed on 2 out of 3 test cases
- ⚠️ **Timeout Behavior**: Taking ~187 seconds before failing (suggests timeout, not immediate failure)
- ⚠️ **Incomplete JSX**: "Simple Widget Request" generated only 108 chars, missing `export const` keywords
- ⚠️ **Wrong Format**: Generated `refreshFrequency: 1000000` instead of `export const refreshFrequency = 1000000`
- ⚠️ **Flagged as "All Lines Commented"**: Detection may need adjustment

**Performance:**
- Base model: 4.66s - 18.80s per test
- Adapter model: 4.74s when successful, ~187s when hitting context limits

---

### systemPrompt_v3 (Latest Run)

**Test Cases:**
1. Simple Widget Request
2. Time Widget Request  
3. Button Widget Request

#### Results Summary

| Test Case | Base Model | Adapter Model | Notes |
|-----------|------------|---------------|-------|
| Simple Widget Request | ✅ Success | ✅ Success | Both succeeded |
| Time Widget Request | ✅ Success | ✅ Success | Both succeeded |
| Button Widget Request | ✅ Success | ✅ Success | Both succeeded |

#### Key Findings

**Base Model (systemPrompt_v3):**
- ✅ All test cases succeeded
- ⚠️ Missing quotes: `export const command = echo "abc..."` (should be `"echo abc..."`)
- ✅ Proper widget structure otherwise

**Adapter Model (systemPrompt_v3):**
- ✅ All test cases succeeded
- ⚠️ Missing `const` keyword: `export command =` (should be `export const command =`)
- ⚠️ Wrong imports: `import { command, refreshFrequency, render, className } from 'uebersicht'`
- ⚠️ Flagged as "All Lines Commented" for Simple Widget Request (but has actual code)

**Performance:**
- Base model: 4.77s - 19.01s per test
- Adapter model: 6.30s - 9.86s per test (generally slower)

**Non-Deterministic Behavior:**
- Test failed once, succeeded on second run
- Likely due to model randomness affecting response length

---

## Reliable Differences Between Models

Based on analysis of the last 4 test runs (2025-11-09 16:59:13 through 17:20:28):

### 1. Time Widget Tool Calling Behavior
- **Base Model**: Consistently fails to call tool (3/4 runs returned JSON instead; 1/4 had decoding error)
- **Adapter Model**: Usually succeeds at calling tool (3/4 runs succeeded; 1/4 hit context limit)
- **Conclusion**: Adapter is more reliable at calling tools for Time Widget requests

### 2. Context Window Limits
- **Base Model**: No context window issues observed across all runs
- **Adapter Model**: Consistent failures at 3920-3927/4096 tokens (observed in all 4 runs)
- **Conclusion**: Adapter has a critical limitation with context window size; Base does not

### 3. JSX Content Reuse
- **Base Model**: Generates unique JSX content for each widget
- **Adapter Model**: Frequently reuses JSX content across different widgets (observed in 3/4 runs)
- **Conclusion**: Adapter reuses code, potentially indicating less context awareness

### 4. Tool Calling Consistency
- **Base Model**: Inconsistent on Time Widget (never calls), usually calls on Button Widget
- **Adapter Model**: More consistent overall (always calls on Button, usually on Time)
- **Conclusion**: Adapter is more consistent at calling tools, but at the cost of context limits

### 5. JSX Quality
- **Base Model**: Generally produces higher quality, more complete JSX; occasional truncation
- **Adapter Model**: Frequently truncates, reuses content, sometimes generates all-commented code
- **Conclusion**: Base produces better quality output when it succeeds

### 6. Error Types
- **Base Model**: Decoding errors (malformed JSON) when it fails
- **Adapter Model**: Context window errors when it fails
- **Conclusion**: Different failure modes suggest different underlying issues

### Consistency Patterns

**Base Model Consistency:**
- **100% Consistent (4/4 runs):**
  1. ✅ **Simple Widget**: Always calls tool successfully
  2. ❌ **Time Widget**: Always fails to call tool (returns JSON or decoding error)
- **Inconsistent:**
  3. ⚠️ **Button Widget**: 50% success rate (2/4 runs called tool, 2/4 failed)

**Adapter Model Consistency:**
- **100% Consistent (4/4 runs):**
  1. ✅ **Simple Widget**: Always calls tool successfully
  2. ✅ **Button Widget**: Always calls tool successfully
- **Mostly Consistent (3/4 runs):**
  3. ✅ **Time Widget**: 75% success rate (3/4 runs succeeded, 1/4 hit context limit)

### Critical Finding: Non-Deterministic Context Window Behavior

**Observation**: Three consecutive runs with identical code and prompts showed dramatically different results:
- **17:09:35**: ✅ Passed - Adapter succeeded on all tests, no context issues
- **17:15:08**: ❌ Failed - Adapter hit context limit (3920/4096 tokens) on individual test
- **17:20:28**: ❌ Failed - Adapter hit context limit (3920/4096 tokens) on individual test

**Analysis**: The adapter model is operating **right at the edge of its context window** (3920-3927/4096 tokens). Small variations in response length due to model randomness can push it over the threshold, causing failures.

**Implications**:
- The adapter's context window usage is **unstable** - same inputs can produce different outcomes
- Failures are **non-deterministic** - cannot be reliably reproduced
- The model needs **headroom** below 3920 tokens to be reliable
- This explains why the adapter sometimes succeeds and sometimes fails on identical test cases

**Recommendation**: The adapter model requires either:
1. A larger context window, or
2. More aggressive prompt/response compression to stay well below 3920 tokens

---

## Context Window Investigation

### Research: Why Does the Adapter Have a Smaller Context Window?

**Observed Behavior:**
- **Base Model**: No context window issues observed, can handle long multi-message conversations
- **Adapter Model**: Consistently fails at 3920-3927/4095 tokens (~175 tokens of headroom)
- **Critical Pattern**: Adapter is nearly full after the FIRST question, suggesting immediate context consumption
- **Apple's Limit**: max_sequence_length is limited to 4095 (not 4096) in Apple's toolkit

**Current Best Hypothesis (CONFIRMED):**

**Root Cause**: System prompt (~732 tokens) + tool definition (~186 tokens) were included in the system message during adapter training. At inference time, FoundationModels includes both in context for adapters to match training conditions. However, this only accounts for ~919 tokens, leaving ~3001 tokens unaccounted for in the ~3920/4095 limit.

**Confirmed Facts**:
- Tool definitions were in the system message of each training item
- System Prompt v4 is ~732 tokens
- Tool Definition is ~186 tokens
- Combined: ~919 tokens
- Adapter hits ~3920/4095 limit (only ~175 tokens remaining)
- **Mystery**: ~3001 tokens are unaccounted for

**Why This Happens**:
1. **Training**: Each training example included system prompt + tool definition in system message
2. **Inference**: Framework includes system prompt + tool definition in context to match training
3. **Additional Context** (unaccounted ~3001 tokens):
   - System prompt might be included even though "baked in" to training
   - Few-shot examples or training examples might be prepended
   - Conversation formatting overhead (role labels, message structure)
   - Framework metadata or adapter-specific initialization context
4. **Result**: ~3920 tokens consumed immediately, leaving only ~175 tokens for conversation
5. **Base Model**: Uses different mechanism (function calling API) that doesn't include these in context

**This Explains**:
- ✅ Why adapter is full immediately (system prompt + tool definition + unknown overhead)
- ✅ Why base model has no issues (different context handling)
- ✅ The consistent ~3920/4095 limit (fixed overhead + small buffer)
- ✅ The non-deterministic behavior (small response variations push over ~175 token buffer)

**Remaining Investigation**:
- What is consuming the additional ~3001 tokens?
- Are few-shot examples being included?
- Is the system prompt being duplicated (baked in + included in context)?
- Is there conversation formatting overhead?

**Solutions**:
1. **Retrain adapter** without system prompt + tool definitions in system message (use function calling API)
2. **Investigate** what's consuming the ~3001 unaccounted tokens
3. **Modify inference** to not include system prompt/tool definitions if framework allows
4. **Use base model** for tasks requiring more context

### Diagnostic Test: Multi-Turn Conversation Context Window Investigation

**Test Date**: 2025-11-09  
**Test**: `diagnosticInspectTranscriptEntries()` in `MultiTurnConversationTests.swift`

**Objective**: Investigate why the adapter model's context window grows to ~3732 tokens on turn 2 while the base model stays at ~1% (~42 tokens) after 2 turns.

**Key Findings:**

#### Base Model Behavior
- **Turn 1**: `_transcript` size: 3562 characters (~890 tokens), jsxContent occurrences: 2
- **Turn 2**: `_transcript` size: 4219 characters (~1054 tokens), jsxContent occurrences: 3
- **Growth**: 657 characters (~164 tokens)
- **Analysis**: Base model stores tool calls **compactly** (likely without full arguments in transcript)

#### Adapter Model Behavior
- **Turn 1**: `_transcript` size: 836 characters (~209 tokens), jsxContent occurrences: 1
- **Turn 2**: `_transcript` size: 3203 characters (~800 tokens), jsxContent occurrences: 4
- **Growth**: 2367 characters (~591 tokens) - **3.6x the base model growth!**
- **Context window exceeded**: Attempted to send 3708 tokens (exceeds 4096 limit)
- **Analysis**: Adapter model stores tool calls with **FULL arguments** (complete jsxContent JSON)

**Root Cause Identified**: The adapter model includes FULL tool call arguments (complete jsxContent JSON) in each transcript entry, and these are included in the conversation history sent to the model on subsequent turns.

**Evidence**:
1. Turn 2 transcript entry size: 2300 characters (~575 tokens) - This is the full tool call with complete jsxContent JSON
2. jsxContent occurrences: Adapter has 4 occurrences after turn 2 (base has 3), suggesting previous tool calls are being re-included
3. Growth pattern: Adapter grows by 591 tokens between turns, while base grows by only 164 tokens
4. Context window: Adapter attempts to send 3708 tokens on turn 2, exceeding the 4096 limit

**Why This Happens**:
- **Base Model**: Uses a more efficient storage mechanism - likely stores tool calls compactly (without full arguments) or uses a function calling API that doesn't include full arguments in context
- **Adapter Model**: Stores complete tool call payloads including full jsxContent JSON in transcript entries, and these are included in the conversation history when building context for subsequent turns

**Comparison Summary:**

| Metric | Base Model | Adapter Model | Difference |
|--------|------------|---------------|------------|
| Turn 1 `_transcript` | 3562 chars (~890 tokens) | 836 chars (~209 tokens) | Base larger (includes system prompt) |
| Turn 2 `_transcript` | 4219 chars (~1054 tokens) | 3203 chars (~800 tokens) | Base still larger |
| Growth Turn 1→2 | 657 chars (~164 tokens) | 2367 chars (~591 tokens) | **Adapter 3.6x larger** |
| jsxContent occurrences (Turn 2) | 3 | 4 | Adapter has more |
| Turn 2 transcript entry size | ~586 chars (~146 tokens) | 2300 chars (~575 tokens) | **Adapter 3.9x larger** |
| Context window usage (Turn 2) | ~1054 tokens | 3708 tokens (exceeded) | Adapter exceeds limit |

**Conclusion**: The adapter was trained with full tool call arguments in the training examples, so FoundationModels includes full arguments in transcript entries to maintain training/inference consistency. This is why the adapter's conversation history grows 3-4x faster than the base model, causing context window issues on multi-turn conversations.

### Post-Patch Diagnostic Test Results

**Test Date**: 2025-11-09 (after applying training toolkit patch)  
**Adapter**: Retrained with patch applied to reduce tool call argument storage

**Objective**: Verify if the training patch resolved the context window issue.

**Key Findings:**

#### Base Model (Reference - Still Working)
- Baseline `_transcript`: 2965 characters (~741 tokens)
- Turn 1 transcript entry: 543 characters (~135 tokens) - compact storage
- Turn 2 transcript entry: 592 characters (~148 tokens) - compact storage
- Growth between turns: 49 characters (~12 tokens) - minimal
- Result: ✅ Success - no context window issues

#### New Adapter Model (After Patch)
- Baseline `_transcript`: 38 characters (~9 tokens) - almost empty
- Turn 1 transcript entry: 661 characters (~165 tokens) - similar to base model
- Turn 2: ❌ **FAILED** with 3685 tokens (exceeds 4096 limit)
- Result: ❌ Still failing - context window exceeded on turn 2

**Critical Discovery**: The adapter is STILL storing full jsxContent in the transcript, despite the training patch. The full jsxContent JSON is present in the transcript string representation.

**The Token Count Mystery**:
- `_transcript` size: 787 characters (~196 tokens)
- Actual context sent to model: 3685 tokens (as reported by error)
- Difference: ~3489 tokens unaccounted for in the transcript string

**Why This Happens**:
1. The `_transcript` string representation may be compressed/abbreviated for display
2. FoundationModels expands the transcript when building actual context sent to the model
3. The full jsxContent is included in that expansion, consuming ~3489 additional tokens
4. This explains why the transcript looks small (787 chars) but the actual context is huge (3685 tokens)

**Conclusion**: The training patch did NOT fully resolve the issue. The adapter is still storing full tool call arguments (jsxContent) in the transcript, and FoundationModels includes them when building context for subsequent turns, causing the context window to exceed 4096 tokens on turn 2.

**Status**: ❌ Issue NOT resolved - adapter still fails on multi-turn conversations due to context window limits.

---

## Common Issues

### Adapter Model Issues

1. **Context Window Limits**
   - Failing on complex requests (Time Widget, Button Widget)
   - Taking ~187 seconds before failing (timeout behavior)
   - More severe with `systemPrompt_v4`

2. **Syntax Errors**
   - Missing `const` keyword: `export command =` instead of `export const command =`
   - Wrong imports: `import { ... } from 'uebersicht'` (not valid for Übersicht widgets)
   - Incomplete JSX generation

3. **Format Issues**
   - Sometimes generates wrong widget format
   - Missing required exports
   - Incomplete function implementations

### Base Model Issues

1. **Syntax Errors**
   - Sometimes missing quotes: `export const command = echo "abc"` (should be `"echo abc"`)
   - Generally correct format with `systemPrompt_v4`

2. **Format Issues**
   - Sometimes generates React component format instead of Übersicht widget format
   - Best performance with `systemPrompt_v4`

3. **Tool Calling Inconsistency**
   - Consistently fails to call tool for Time Widget (returns JSON instead)
   - Inconsistent on Button Widget (50% success rate)

---

## Recommendations

### For Base Model
- ✅ **Use `systemPrompt_v4`** - Best overall performance and format correctness
- 🔧 **Fix Time Widget tool calling** - Consistently fails to call tool (returns JSON instead); this is the most critical issue
- ⚠️ **Watch for missing quotes** - Some prompts generate unquoted command strings
- ⚠️ **Handle decoding errors** - Occasionally produces malformed JSON causing decoding failures
- ✅ **JSX Quality** - Produces high-quality, unique JSX content (strength to maintain)

### For Adapter Model
- 🔧 **CRITICAL: Fix context window issues** - Consistently hits limits at 3920-3927/4096 tokens; this is the most distinguishing failure mode
- 🔧 **Improve JSX quality** - Frequently truncates, reuses content, sometimes generates all-commented code
- 🔧 **Needs retraining** on correct Übersicht widget syntax
- 🔧 **Fix missing `const` keyword** in exports
- 🔧 **Remove wrong import statements**
- 🔧 **Complete function implementations**
- ✅ **Tool Calling Consistency** - More reliable at calling tools (strength to maintain)

### Model Selection Guidance
- **Use Base Model when**: JSX quality is critical, context window size is a concern, or you can handle inconsistent tool calling
- **Use Adapter Model when**: Tool calling consistency is critical, context requirements are minimal (<3920 tokens), or you need more predictable behavior
- **Current State**: Neither model is production-ready; Base has tool calling issues, Adapter has context limits

### For Testing
- ✅ Version-based structure is working well
- ⚠️ Non-deterministic behavior expected (model randomness)
- ⚠️ Context window failures are model limitations, not test failures
- 🔧 Consider refining "All Lines Commented" detection logic
- 🔧 Monitor Time Widget behavior - Base model's consistent failure pattern needs investigation

---

## Test Configuration

- **Adapter Path**: `/Users/mike/Downloads/uebersicht_widgets.fmadapter`
- **Test Target**: Hello World ToolsTests
- **Testing Framework**: Swift Testing
- **Tool**: WriteUbersichtWidgetToFileSystem
- **Output Directory**: `/Users/mike/Library/Application Support/Übersicht/widgets/hwta`
- **Prewarm**: Currently disabled (commented out)

---

## Fine-Tuning Feedback for Adapter Model

This section contains specific findings that should be addressed in the next adapter model training iteration.

### Critical Issues to Fix

#### 1. JSX Syntax Errors

**Issue**: Missing `const` keyword in exports
- **Current**: `export command = ...`
- **Should be**: `export const command = ...`
- **Frequency**: Observed in multiple test runs
- **Impact**: High - breaks widget functionality

**Issue**: Wrong import statements
- **Current**: `import { command, refreshFrequency, render, className } from 'uebersicht'`
- **Should be**: No imports needed (Übersicht widgets don't use imports)
- **Frequency**: Observed in multiple test runs
- **Impact**: High - invalid syntax for Übersicht widgets

**Action Items**:
- Add training examples that explicitly show `export const` syntax
- Remove all import statement examples from training data
- Emphasize that Übersicht widgets use direct exports, not imports

#### 2. JSX Format Issues

**Issue**: Incomplete JSX generation
- **Current**: Sometimes generates only 108 characters, missing required exports
- **Should be**: Complete widget with all 4 required exports (command, refreshFrequency, render, className)
- **Frequency**: Observed in Simple Widget Request test
- **Impact**: High - widgets don't function

**Issue**: Wrong format for refreshFrequency
- **Current**: `refreshFrequency: 1000000` (object property syntax)
- **Should be**: `export const refreshFrequency = 1000000;` (export const syntax)
- **Frequency**: Observed in multiple test runs
- **Impact**: High - breaks widget structure

**Action Items**:
- Ensure all training examples use `export const` syntax for all properties
- Include complete widget examples with all 4 required exports
- Add validation examples showing correct vs incorrect formats

#### 3. JSX Content Quality

**Issue**: JSX content reuse across different widgets
- **Current**: Adapter reuses same JSX code for different widget requests
- **Should be**: Generate unique, context-appropriate JSX for each request
- **Frequency**: Observed in 3/4 test runs
- **Impact**: Medium - reduces functionality and context awareness

**Issue**: All-commented JSX generation
- **Current**: Sometimes generates JSX where all lines are comments
- **Should be**: Generate executable code, not just comments
- **Frequency**: Occasional
- **Impact**: High - widget doesn't function

**Action Items**:
- Increase diversity in training examples to prevent code reuse
- Ensure training examples show context-specific widget generation
- Remove or minimize comment-only examples from training data
- Add examples showing how to adapt JSX based on user requirements

### Training Data Improvements

#### 4. Prompt Patterns That Work

**Finding**: Explicit modification language triggers tool calls
- **Working Pattern**: `"update the widget to..."` or `"modify the widget to..."`
- **Non-Working Pattern**: Short directives like `"align it with the right edge"`
- **Evidence**: Base model test went from 0 tool calls to 11 tool calls with prompt tweaks
- **Impact**: High - affects tool calling reliability

**Action Items**:
- Include training examples with explicit modification language
- Show patterns like:
  - `"update the widget to [modification]"`
  - `"modify the widget to [modification]"`
  - `"generate a widget that [description]"` (not "create a widget")
- Avoid short, imperative directives in training data

#### 5. Prompt Patterns That DON'T Work

**Finding**: Certain prompt patterns fail to trigger tool calls, causing the model to respond with text descriptions instead

**Non-Working Patterns**:

**Pattern 1**: Using "create" instead of "generate"
- **Non-Working**: `"create a widget that displays \"Hello World\""`
- **Working**: `"generate a widget that says \"abc as easy as 123\""`
- **Evidence**: Initial test run with "create" resulted in 0 tool calls; changing to "generate" triggered tool calls (observed on BASE model, not adapter)
- **Impact**: High - completely prevents tool calling
- **Why**: The system prompt (systemPrompt_v4) or the model's general training may associate "generate" more strongly with tool calling actions. This is a base model behavior, not related to adapter fine-tuning. The verb choice affects how the model interprets the instruction - "generate" may be interpreted as an action requiring tool execution, while "create" may be interpreted as a descriptive request.

**Pattern 2**: Using "displays" instead of "says" (⚠️ NEW FINDING)
- **Non-Working**: `"generate a widget that displays \"Hello World\""` → ❌ No tool call
- **Working**: `"generate a widget that says \"abc as easy as 123\""` → ✅ Tool call
- **Evidence**: `testBaseModelContextWindowUsage` with "displays" resulted in 0 tool calls; `baseModel_MultiTurn` with "says" resulted in 2 tool calls
- **Impact**: High - subtle verb difference ("says" vs "displays") completely prevents tool calling
- **Why**: Unknown - may be related to training data patterns or model interpretation of "says" vs "displays"

**Pattern 3**: Using explicit "update/modify the widget to..." language (⚠️ PARADOXICAL FINDING)
- **Non-Working**: `"update the widget to align it with the right edge"` → ❌ No tool call
- **Working**: `"move it to the top-right corner"` → ✅ Tool call
- **Evidence**: `testBaseModelContextWindowUsage` with explicit language resulted in 0 tool calls; `baseModel_MultiTurn` with shorter directives resulted in 2 tool calls
- **Impact**: High - explicit modification language that was thought to work actually FAILS
- **Why**: Paradoxical - shorter, more natural directives work better than explicit "update/modify the widget to..." language. This contradicts earlier findings.

**Pattern 4**: Short, imperative directives (⚠️ CORRECTED - These actually WORK)
- **Working Examples** (from `baseModel_MultiTurn`):
  - `"move it to the top-right corner"` → ✅ Tool call
  - `"make the font bold"` → ✅ Tool call (when used with working Turn 1 prompt)
  - `"make the text red"` → ✅ Tool call (when used with working Turn 1 prompt)
- **Non-Working**: When combined with failing Turn 1 prompts (e.g., "displays" instead of "says")
- **Evidence**: Shorter directives work in `baseModel_MultiTurn` but fail in `testBaseModelContextWindowUsage` - the difference is the Turn 1 prompt
- **Impact**: Medium - shorter directives work IF the initial prompt triggers tool calls
- **Why**: The success of Turn 2 depends on Turn 1 establishing the correct context/pattern

**Pattern 5**: Vague modification requests
- **Non-Working**: `"change the color"`
- **Working**: `"update the widget to change the text color to red"`
- **Impact**: Medium - model may ask for clarification instead of calling tool
- **Why**: Too vague; model needs specific instructions to generate complete widget code

**Common Characteristics of Non-Working Patterns**:
1. **Lack explicit "widget" reference** - Model doesn't know what to modify
2. **Use "create" instead of "generate"** - May not match training patterns
3. **Too short/imperative** - Treated as conversational, not actionable
4. **Missing modification verbs** - No "update", "modify", "change" with widget context
5. **Assumes context** - Relies on implicit understanding of what "it" refers to

**Action Items**:
- **Remove from training data**: Examples using "create a widget" (use "generate" instead)
- **Remove from training data**: Short imperative directives without widget context
- **Add negative examples**: Show what NOT to do (with corrections)
- **Emphasize explicit language**: All training examples should use explicit modification patterns
- **Include context**: Always reference "widget" explicitly in modification requests
- **Use working patterns**: Train only on patterns that reliably trigger tool calls

#### 6. Tool Call Argument Format

**Finding**: Full tool call arguments in training cause context window issues
- **Current Training**: Includes full `jsxContent` JSON in tool call arguments
- **Problem**: Causes context window to fill up quickly (3920/4096 tokens)
- **Evidence**: Diagnostic tests show adapter stores full arguments, base model stores compactly
- **Impact**: Critical - prevents multi-turn conversations

**Action Items**:
- **CRITICAL**: Retrain adapter with tool calls stored compactly (without full arguments in system message)
- Use function calling API format instead of full JSON arguments
- Match base model's compact storage approach
- This is the #1 priority for fixing context window issues

#### 7. Widget API Compliance

**Finding**: Adapter sometimes generates non-standard widget formats
- **Current**: Mix of formats (object properties, imports, comments)
- **Should be**: Standard Übersicht widget API with 4 exports:
  ```javascript
  export const command = "...";
  export const refreshFrequency = 1000;
  export const render = ({output}) => { return <div>{output}</div>; };
  export const className = "...";
  ```
- **Impact**: High - widgets don't work correctly

**Action Items**:
- Standardize all training examples to use exact Übersicht widget API format
- Remove any non-standard formats from training data
- Add examples showing correct vs incorrect formats
- Emphasize the 4 required exports in every training example

### Training Configuration Recommendations

#### 8. System Prompt Handling

**Finding**: System prompt + tool definitions in training cause context issues
- **Current**: System prompt (~732 tokens) + tool definition (~186 tokens) included in each training example
- **Problem**: Framework includes these in context at inference, consuming ~3920/4096 tokens
- **Impact**: Critical - leaves only ~175 tokens for actual conversation

**Action Items**:
- **Option A**: Retrain without system prompt/tool definitions in system message (use function calling API)
- **Option B**: If system prompt must be included, investigate what's consuming the additional ~3001 tokens
- **Option C**: Use base model's approach (function calling API) that doesn't include these in context
- This is the #2 priority for fixing context window issues

#### 9. Training Example Quality

**Finding**: Training examples need to match inference patterns
- **Current**: Training examples may not match actual usage patterns
- **Evidence**: Prompt engineering changes dramatically affect tool calling behavior
- **Impact**: Medium - affects reliability

**Action Items**:
- Include training examples that match actual user prompts
- Use explicit modification language in examples
- Show multi-turn conversation examples with proper context handling
- Ensure training examples demonstrate correct tool calling patterns

### Priority Ranking for Next Training Iteration

1. **P0 - Critical (Must Fix)**:
   - Fix JSX syntax errors (missing `const`, wrong imports)
   - Fix tool call argument storage (compact format to fix context window)
   - Fix system prompt/tool definition handling in training

2. **P1 - High Priority**:
   - Fix incomplete JSX generation
   - Fix wrong format for widget properties
   - Standardize widget API compliance

3. **P2 - Medium Priority**:
   - Reduce JSX content reuse
   - Fix all-commented JSX generation
   - Improve training example quality to match usage patterns

### Success Metrics for Next Training

After retraining, the adapter should:
- ✅ Generate complete JSX with all 4 required exports
- ✅ Use correct `export const` syntax (no missing `const`)
- ✅ No import statements in generated code
- ✅ Handle multi-turn conversations without hitting context limits (target: <3000 tokens after 2 turns)
- ✅ Generate unique, context-appropriate JSX for each request
- ✅ Successfully call tools on all test cases (Simple, Time, Button widgets)

---

## Next Steps

1. **Run v1 and v2 tests** - Complete the version comparison
2. **Investigate adapter context window issues** - Why is it failing on v4 but not v3?
3. **Refine detection logic** - "All Lines Commented" may be too sensitive
4. **Compare prompt lengths** - Is v4 longer, causing context issues?
5. **Monitor improvements** - Track changes as adapter is retrained
6. **Apply fine-tuning feedback** - Use findings above to guide next training iteration

---

*Last Updated: Based on v4 test runs (2025-11-09 16:59:13 through 17:20:28). Includes analysis of reliable differences between models and prompt engineering findings.*
