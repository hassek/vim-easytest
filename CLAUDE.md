# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

vim-easytest is a Vim plugin that simplifies running unit tests by automatically detecting test names, classes, and files at the cursor position. It integrates with vim-dispatch to run tests asynchronously or in the terminal.

## Architecture

### Core Components

**plugin/easy_test.vim**: Single-file plugin containing all functionality. The plugin uses a VimScript wrapper around Python code executed via `pythonx`. The architecture is:

1. **VimScript layer** (lines 1-21): Plugin initialization, guards, and syntax configuration variables
2. **Python layer** (lines 22-168): All test detection and command generation logic

### Test Detection Flow

The `run_test()` function implements the core logic:

1. **Syntax detection** (lines 132-137): Checks `g:easytest_*_syntax` variables to determine which test framework to use (defaults to Django)
2. **AST navigation** (lines 139-148): Uses Vim's search commands to find test function and class definitions by searching backwards for `def`, `fn`, `func` (functions) and `class`, `mod` (classes/modules)
3. **Command generation**: Delegates to framework-specific functions (lines 56-126) that construct test runner commands
4. **Execution** (lines 164-167): Runs via vim-dispatch (`Start` for async, `Dispatch` for terminal)

### Supported Test Frameworks

Each framework has a dedicated function that generates test commands:

- **easytest_django_syntax** (lines 56-70): Converts file paths to dotted module notation
- **easytest_django_nose_syntax** (lines 72-79): Uses django-nose's `:` separator
- **easytest_pytest_syntax** (lines 81-87): Uses pytest's `::` separator
- **easytest_ruby_syntax** (lines 89-98): Uses ruby's `-I`, `-t`, and `-n` flags
- **easytest_rust_syntax** (lines 100-114): Constructs `cargo test` commands with `--nocapture`
- **easytest_go_syntax** (lines 116-126): Constructs `go test` commands with `-run` for specific tests

### Test Granularity Levels

The plugin supports 5 test execution levels (controlled by the `level` parameter):

- `test`: Run single test function at cursor
- `class`: Run all tests in the class at cursor
- `file`: Run all tests in current file
- `package`: Run all tests in the package/module
- `all`: Run entire test suite

## Key Implementation Details

### Regex Pattern Matching

The plugin searches for function/class definitions using Vim regex (lines 140, 145):
- Function pattern: `?\<def\>\|\<fn\>\|\<func\>` - matches Python `def`, Rust `fn`, Go `func`
- Class pattern: `?\<class\>\|\<mod\>` - matches Python/Ruby `class`, Rust `mod`

After finding a match, it extracts the name by:
1. Stripping `async` prefix (line 141)
2. Splitting on space and taking second token (function/class name)
3. Splitting on `(` to remove parameters
4. Stripping trailing `:`, `{`, and whitespace

### Django Test Path Resolution

Django tests require dotted module notation (lines 61-70). The plugin:
1. Gets file path from `@%` register (current buffer)
2. Removes `.py` extension and replaces `/` with `.`
3. For package-level tests, removes the last component using `rpartition('.')`

### Terminal vs Async Execution

- `Start`: Runs command asynchronously via vim-dispatch (line 167)
- `Dispatch`: Opens terminal for interactive debugging like pdb (line 165)

### Cursor Position Management

Lines 129-161 preserve cursor position:
1. Stores original position (line 130)
2. Performs backward searches (lines 140, 145)
3. Restores position after extracting names (line 161)
4. Clears search highlights (line 163)

## Configuration

Syntax selection is controlled by global Vim variables (check one per filetype):
```vim
let g:easytest_django_syntax = 1
let g:easytest_django_nose_syntax = 1
let g:easytest_pytest_syntax = 1
let g:easytest_ruby_syntax = 1
let g:easytest_rust_syntax = 1
let g:easytest_go_syntax = 1
```

Per-project configuration can use `.vimrc` in the project directory (requires `set exrc` and `set secure` in `~/.vimrc`).

## Dependencies

- **vim-dispatch**: Required for async test execution and terminal integration
- **Python support**: Vim must be compiled with Python (pythonx support)

## Testing the Plugin

There is no automated test suite. Manual testing workflow:

1. Open a test file in Vim
2. Position cursor inside a test function
3. Call `:py run_current_test()` or other API functions
4. Verify the command in the output (line 162 prints the command)
5. Check test results in quickfix window (async) or terminal

## Extending with New Languages

To add support for a new test framework:

1. Add a new `easytest_{framework}_syntax()` function following the pattern of existing implementations
2. Add the function name to the detection loop (line 132)
3. Consider language-specific patterns for finding functions/classes if needed
4. Test with all granularity levels (test, class, file, package, all)

The function receives `cls_name` and `def_name` as parameters (may be None) and should return the complete shell command to run tests.
