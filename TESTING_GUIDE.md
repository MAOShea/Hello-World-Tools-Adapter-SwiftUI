# How to Run the Test Framework

## Quick Start

### Option 1: Run All Tests (Recommended)
1. Open Xcode
2. Press `⌘ + U` (Command + U) to run all tests
3. Or go to **Product → Test** from the menu

### Option 2: Run Individual Tests
1. Open `LanguageModelComparisonTests.swift` in Xcode
2. Click the diamond icon (◊) next to any test function name
3. Or right-click on a test and select "Run"

### Option 3: Run from Test Navigator
1. Press `⌘ + 6` to open the Test Navigator
2. You'll see all available tests listed
3. Click the play button (▶) next to any test or test suite

## Available Tests

### 1. `compareModelsForAllPrompts`
**What it does**: Runs all test cases with all system prompts, comparing base model vs adapter model outputs.

**How to run**: 
- Look for the test in the Test Navigator
- Click the play button next to it
- This will take a while as it runs many combinations

### 2. `testBaseModel`
**What it does**: Quick test of the base model with a simple prompt.

**How to run**: 
- Click the diamond (◊) next to the function name
- Or run from Test Navigator

### 3. `testAdapterModel`
**What it does**: Quick test of the adapter model with a simple prompt.

**How to run**: 
- Click the diamond (◊) next to the function name
- Or run from Test Navigator

### 4. `compareSystemPromptsBaseModel`
**What it does**: Compares all 4 system prompt versions using the base model.

**How to run**: 
- Click the diamond (◊) next to the function name
- Check the console output for detailed comparisons

### 5. `compareSystemPromptsAdapterModel`
**What it does**: Compares all 4 system prompt versions using the adapter model.

**How to run**: 
- Click the diamond (◊) next to the function name
- Check the console output for detailed comparisons

## Viewing Test Results

### Console Output
- Open the **Debug Area** (View → Debug Area → Show Debug Area, or `⌘ + Shift + Y`)
- Test results and comparison reports will be printed to the console
- Look for reports starting with `=== COMPARISON REPORT ===`

### Test Results Panel
- After tests complete, Xcode shows a summary
- Green checkmarks = passed
- Red X = failed
- Yellow warning = issues (but test may still pass)

## Understanding the Output

Each test generates detailed reports showing:
- **Response Length**: Character count of AI responses
- **Duration**: How long each test took
- **Tool Called**: Whether the tool was invoked
- **Errors**: Any errors that occurred
- **Differences**: Comparison between base and adapter models

## Troubleshooting

### Test Fails to Compile
- Make sure the adapter file exists at: `/Users/mike/Downloads/uebersicht_widgets.fmadapter`
- If your adapter is in a different location, update the `adapterURL` in `TestRunner.init()`

### Tests Take Too Long
- Start with individual tests (`testBaseModel` or `testAdapterModel`)
- Avoid running `compareModelsForAllPrompts` initially as it runs many combinations

### No Console Output
- Make sure the Debug Area is visible (`⌘ + Shift + Y`)
- Check that you're looking at the "All Output" tab in the console

### Adapter Model Not Found
- Update the `adapterURL` path in the test file if your adapter is elsewhere
- Or modify `TestRunner.init()` to use a different default path

## Tips

1. **Start Small**: Run `testBaseModel` first to verify everything works
2. **Check Console**: Most useful information is in the console output, not just pass/fail
3. **Run Individually**: For debugging, run tests one at a time
4. **Add Test Cases**: Edit the `testCases` array to add your own test scenarios

## Example: Running Your First Test

1. Open Xcode
2. Open `LanguageModelComparisonTests.swift`
3. Find the `testBaseModel` function
4. Click the diamond (◊) icon next to it
5. Watch the console for output
6. Check the test results panel for pass/fail status

That's it! 🎉



