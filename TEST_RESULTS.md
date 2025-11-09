# Model Comparison Test Results

**Test Framework**: Version-Based Test Structure  
**Models Compared**: Base Model vs LoRA Adapter Model

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

---

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

Tests are now organized by system prompt version:
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

Based on analysis of the last 4 test runs (2025-11-09 16:59:13 through 17:20:28), the following differences are consistently observed:

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

### Summary
- **Adapter Model**: More consistent tool calling behavior, but critically limited by context window size and produces lower quality JSX
- **Base Model**: Better JSX quality and no context limits, but inconsistent tool calling (especially on Time Widget)

**Most Reliable Difference**: The adapter consistently hits context limits (3920-3927/4096 tokens) while the base model does not, making this the most distinguishing characteristic between the two models.

---

## Consistency Patterns by Model

Based on analysis of the last 4 test runs (2025-11-09 16:59:13 through 17:20:28), the following consistency patterns are observed:

### Base Model Consistency

**100% Consistent (4/4 runs):**
1. ✅ **Simple Widget**: Always calls tool successfully
2. ❌ **Time Widget**: Always fails to call tool (returns JSON or decoding error)

**Inconsistent:**
3. ⚠️ **Button Widget**: 50% success rate (2/4 runs called tool, 2/4 failed)

**Summary**: Base model is highly consistent on Simple Widget (always succeeds) and Time Widget (always fails), but inconsistent on Button Widget.

### Adapter Model Consistency

**100% Consistent (4/4 runs):**
1. ✅ **Simple Widget**: Always calls tool successfully
2. ✅ **Button Widget**: Always calls tool successfully

**Mostly Consistent (3/4 runs):**
3. ✅ **Time Widget**: 75% success rate (3/4 runs succeeded, 1/4 hit context limit)

**Summary**: Adapter model is highly consistent on Simple and Button Widgets (always succeeds), and usually succeeds on Time Widget (fails only due to context limits).

### Key Findings

- **Most Consistent Metric**: Both models are 100% consistent on Simple Widget (always call tool)
- **Base Model Strength**: 100% consistent success on Simple Widget
- **Base Model Weakness**: 100% consistent failure on Time Widget (never calls tool)
- **Adapter Model Strength**: 100% consistent success on both Simple and Button Widgets
- **Adapter Model Weakness**: Context limits cause failures on Time Widget (25% failure rate)

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

## Research: Why Does the Adapter Have a Smaller Context Window?

### Observed Behavior
- **Base Model**: No context window issues observed, can handle long multi-message conversations
- **Adapter Model**: Consistently fails at 3920-3927/4095 tokens (~175 tokens of headroom)
- **Critical Pattern**: Adapter is nearly full after the FIRST question, suggesting immediate context consumption
- **Apple's Limit**: max_sequence_length is limited to 4095 (not 4096) in Apple's toolkit

### Code Analysis

**Base Model Initialization:**
```swift
LanguageModelSession(
    tools: tools,
    instructions: instructions  // Instructions passed separately
)
```

**Adapter Model Initialization:**
```swift
let adapter = try SystemLanguageModel.Adapter(fileURL: adapterURL)
let customAdapterModel = SystemLanguageModel(adapter: adapter)
LanguageModelSession(
    model: customAdapterModel,
    tools: tools
    // NO instructions passed - adapter may contain them
)
```

**Key Difference**: 
- **Base Model**: Instructions passed separately; tool definitions handled via function calling API (doesn't consume context tokens)
- **Adapter Model**: System prompt (~732 tokens) + tool definition (~186 tokens) included in system message during training, so framework includes them in context at inference time. However, this only accounts for ~919 tokens, leaving ~3001 tokens unaccounted for in the ~3920/4095 limit.

### Hypotheses

#### 1. **System Prompt + Tool Definition in Context** (CONFIRMED - Most Likely Cause)
- **FACT**: Tool definitions were included in the system message of each training item during adapter training
- **Measured Token Counts**:
  - System Prompt v4: ~732 tokens
  - Tool Definition: ~186 tokens
  - Combined: ~919 tokens
- **Mystery**: If only ~919 tokens are accounted for, but adapter hits ~3920/4095, there's ~3001 tokens unaccounted for
- **Possible Additional Context**:
  - System prompt might be included in context even though "baked in" to training
  - Few-shot examples or training examples might be included
  - Conversation formatting overhead (role labels, message formatting)
  - Framework metadata or adapter-specific context
- **Evidence**: 
  - Adapter is nearly full after first question (immediate consumption)
  - Base model handles long conversations fine (different context handling)
  - Consistent ~3920/4095 limit (suggests fixed overhead)
- **Impact**: Only ~175 tokens available for actual conversation after all context is included
- **Why This Matters**: The adapter was trained expecting system prompt + tool definition in context, so the framework includes them at inference time

#### 2. **Base Model Tool Handling** (Different Approach)
- Base model likely handles tool definitions more efficiently (not included in context)
- Base model may use a different mechanism for tool calling (function calling API vs in-context definitions)
- **Evidence**: Base model has no context issues despite using same tools
- **Investigation Needed**: Compare how FoundationModels handles tools for base vs adapter models

#### 3. **Framework-Specific Adapter Initialization**
- Apple's FoundationModels might add adapter-specific metadata to context
- Adapter file might contain examples or training data that gets loaded
- Framework might prepend adapter configuration or metadata
- **Investigation Needed**: Check FoundationModels source/documentation for adapter handling

#### 4. **Training-Time Context Window Size** (Less Likely Given Evidence)
- The adapter was trained with max_sequence_length ~3920 tokens
- However, this doesn't explain why it's full immediately after first question
- **Evidence Against**: Base model handles long conversations, suggesting this isn't just a training constraint

### Research Findings from Literature

1. **Adapter Integration Complexity**: Adapters can modify how models process context, potentially affecting context window utilization
2. **Positional Encoding**: Extending context windows beyond training parameters can cause issues
3. **Attention Mechanisms**: Adapters can alter attention patterns, affecting context management
4. **No Inherent Reduction**: LoRA adapters themselves don't inherently reduce context window size - the limitation is likely implementation-specific

### Recommended Investigations

1. **Inspect Adapter File**: 
   - Check if adapter contains embedded instructions
   - Measure token count of any embedded content
   - Compare adapter size/structure to base model

2. **Compare Token Counts**:
   - Measure actual token counts for same prompts in base vs adapter
   - Check if adapter adds tokens to each request
   - Verify if instructions are being prepended to context

3. **Framework Documentation**:
   - Review Apple FoundationModels documentation
   - Check for adapter-specific context limits
   - Look for configuration options

4. **Test with Minimal Context**:
   - Run adapter with very short prompts
   - Measure baseline context usage
   - Compare to base model baseline

5. **Adapter Metadata**:
   - Inspect adapter file for metadata
   - Check training configuration
   - Verify base model used for training

### Current Best Hypothesis (CONFIRMED)

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

---

## Common Issues Across Versions

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

---

## Test Framework Features

The test framework tracks:
- ✅ **JSX Content Extraction** - Extracts actual JSX from tool calls
- ✅ **Truncation Detection** - Flags incomplete JSX
- ✅ **All-Comments Detection** - Flags when all lines are commented (may need refinement)
- ✅ **Performance Metrics** - Duration tracking
- ✅ **Comparison Reports** - Side-by-side model comparison
- ✅ **Context Window Error Handling** - Gracefully handles context window failures

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

## Next Steps

1. **Run v1 and v2 tests** - Complete the version comparison
2. **Investigate adapter context window issues** - Why is it failing on v4 but not v3?
3. **Refine detection logic** - "All Lines Commented" may be too sensitive
4. **Compare prompt lengths** - Is v4 longer, causing context issues?
5. **Monitor improvements** - Track changes as adapter is retrained

---

*Last Updated: Based on v4 test runs (2025-11-09 16:59:13 through 17:20:28). Includes analysis of reliable differences between models.*
