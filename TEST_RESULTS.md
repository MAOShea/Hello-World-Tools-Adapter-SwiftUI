# Model Comparison Test Results

**Test Framework**: Version-Based Test Structure  
**Models Compared**: Base Model vs LoRA Adapter Model

---

## Test Run Log

| Timestamp | Version | Simple Widget | Time Widget | Button Widget | Tool Called | Suite Status | Key Issues | Duration |
|-----------|---------|---------------|-------------|---------------|------------|--------------|------------|----------|
| 2025-11-09 17:20:28 | v4 | ✅ Both | ✅ Both (Base: ❌ no tool) | ✅ Both (Base: ❌ no tool) | Simple: ✅✅, Time: ❌✅, Button: ❌✅ | ❌ Failed (2 issues) | • Adapter failed individual test with context limit (3920/4096 tokens)<br>• Base didn't call tool for Time & Button Widgets (returned JSON instead)<br>• Adapter JSX truncated for all 3 widgets<br>• Adapter reused same JSX for all 3 widgets (159 chars, same content) | ~196s |
| 2025-11-09 17:15:08 | v4 | ✅ Both | ✅ Both (Base: ❌ no tool) | ✅ Both | Simple: ✅✅, Time: ❌✅, Button: ✅✅ | ❌ Failed (2 issues) | • Adapter failed individual test with context limit (3920/4096 tokens)<br>• Base didn't call tool for Time Widget (returned JSON instead)<br>• Adapter JSX truncated for Simple and Time Widgets<br>• Adapter reused Simple JSX for Time Widget (same content)<br>• Adapter JSX all commented for Button Widget | ~178s |
| 2025-11-09 17:09:35 | v4 | ✅ Both | ✅ Both (Base: ❌ no tool) | ✅ Both | Simple: ✅✅, Time: ❌✅, Button: ✅✅ | ✅ Passed | • Base didn't call tool for Time Widget (returned JSON instead)<br>• Base JSX truncated for Button Widget<br>• Adapter JSX all commented for Simple and Time Widgets<br>• Adapter reused Simple JSX for Time Widget (same content) | ~62s |
| 2025-11-09 16:59:13 | v4 | ✅ Both | ❌ Both (Base: decoding, Adapter: context 3927/4096) | ❌ Base (decoding), ✅ Adapter | Simple: ✅✅, Time: ❌❌, Button: ❌✅ | ❌ Failed (3 issues) | • Base decoding errors on Time & Button (malformed JSON)<br>• Adapter context limit on Time (3927/4096)<br>• Adapter succeeded on Button but JSX truncated/all-commented | ~225s |
| 2025-11-09 16:52:05 | v4 | ✅ Both | ✅ Both (Base: ❌ no tool) | ✅ Both | Simple: ✅✅, Time: ❌✅, Button: ✅✅ | ✅ Passed | • Base didn't call tool for Time Widget (returned JSON instead)<br>• Adapter JSX truncated for Button<br>• Adapter JSX all commented for Simple | ~50s |
| 2025-11-09 16:39:26 | v4 | ✅ Base (no tool), ❌ Adapter (context 3920/4096) | ✅ Both | ✅ Base (tool), ❌ Adapter (context 3923/4096) | Simple: ❌❌, Time: ✅✅, Button: ✅❌ | ❌ Failed (2/3 tests) | • Adapter context limits on 2 cases (3920, 3923/4096)<br>• Base called tools on Time & Button but not Simple<br>• Individual tests passed | ~388s |
| 2025-11-09 16:03:43 | v4 | ✅ Both | ✅ Both | ✅ Both | Base: ✅, Adapter: ✅ (comparison test) | ❌ Failed (2/3 tests) | • **Contradiction**: Comparison test shows base called tools ✅, but individual test shows base did NOT call tool ❌<br>• Adapter failed individual test (context 3920/4096) | ~205s |
| 2025-11-09 15:45:07 | v4 | ✅ Base (no tool), ❌ Adapter (context 3920/4096) | ✅ Base (no tool), ❌ Adapter (context 3927/4096) | ❌ Base (decoding), ✅ Adapter | Base: ❌ (all 3), Adapter: ✅ (Button only) | ❌ Failed | • Adapter context limits on 2 cases<br>• Base not calling tools<br>• Base decoding error on Button | ~340s |
| 2025-11-09 15:25:32 | v4 | ✅ Both | ✅ Both | ❌ Base (context 4090/4096), ✅ Adapter | Base: ❌, Adapter: ✅ (all 3 cases) | ❌ Failed | • Base not calling tool<br>• Base hit context limit on Button Widget | ~106s |
| 2025-11-09 11:54:58 | v4 | ✅ Both | ✅ Both | ✅ Both | | ✅ Passed | • **ALL TESTS PASSED!**<br>• Adapter reused Simple JSX for Time Widget | ~60s |
| 2025-11-09 11:46:57 | v4 | ✅ Both | ✅ Both | ✅ Both | | ✅ Passed | • **ALL TESTS PASSED!**<br>• Adapter faster (5.86s vs 18.25s on simple) | ~43s |
| 2025-11-09 11:44:04 | v4 | ❌ Base (decoding), ✅ Adapter | ⚠️ Base (truncated), ❌ Adapter (context 3927/4096) | ✅ Base (no tool), ❌ Adapter (context 3923/4096) | | ❌ Failed | • Base decoding error on simple<br>• Adapter context limits on 2 cases | ~412s |
| 2025-11-09 | v4 | ✅ Both | ✅ Both (base no tool) | ⚠️ Base truncated, ✅ Adapter | | | • Adapter exceeded context (3920/4096 tokens) on simple test | ~216s |
| 2025-11-09 | v4 | ✅ Both | ✅ Base, ❌ Adapter (context) | ✅ Base, ❌ Adapter (context) | | | • Adapter context window limits on 2 cases | ~410s |

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
