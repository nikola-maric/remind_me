# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`remind_me` is a Ruby gem that provides a non-invasive code reminder system. It scans Ruby files for special `REMIND_ME:` comments (written as Ruby hash syntax) and checks whether specified conditions are met (gem versions, Ruby versions, missing gems). Designed to run in CI pipelines so developers revisit code when conditions are satisfied. Comments don't affect runtime behavior.

## Common Commands

```bash
bundle exec rake spec      # Run tests
bundle exec rake rubocop   # Run linter only
bundle exec rspec spec/remind_me/runner_spec.rb           # Single test file
bundle exec rspec spec/remind_me/runner_spec.rb:42        # Single test by line
bundle exec rake compile   # Compile Rust native extension
bundle exec rake install   # Install gem locally
cargo test --manifest-path ext/remind_me/Cargo.toml       # Run Rust unit tests
```

Note: On Ruby 2.7 with bundler version conflicts, use `bundle _2.4.22_` prefix.

## Architecture

**Entry point:** `lib/remind_me.rb` → loads `Runner` and optional `Railtie`

**Core flow:** `Runner.check_reminders()` → scans for `REMIND_ME:` comments → `Generator.generate()` creates reminder objects → `ResultPrinter.print_results()` reports or exits with error.

**Native Rust extension (optional):** When compiled (`rake compile`), a Rust extension (`ext/remind_me/`) using `ignore` (parallel dir walking) and `memchr` (fast string search) replaces the Ruby file scanning. Exposed as `RemindMe::Native.scan_for_remind_me_comments(path)` via Magnus. Falls back to pure Ruby (`parser` gem) if the extension isn't available (JRuby, no Rust toolchain). The data contract between scanning and processing is `[source_location_string, comment_text_string]` tuples.

**Plugin system with self-registration:** `BaseReminder` subclasses auto-register via `inherited` hook into `Generator`'s registry. New reminder types are added by subclassing `BaseReminder` and using the hash AST DSL (`apply_to_hash_with`, `validate_hash_ast`).

**Built-in reminder types:**
- `GemVersionReminder` — `{ gem: 'rails', version: '6', condition: :gte, message: '...' }`
- `RubyVersionReminder` — `{ ruby_version: '3', condition: :gte, message: '...' }`
- `MissingGemReminder` — `{ missing_gem: 'thor', message: '...' }`

**Key modules:**
- `HashAstManipulations` — DSL for declaring/validating hash keys in parsed AST nodes; generates accessor and validation methods dynamically
- `BailOut` — error handling mixin used across reminder classes
- `Utils::Versions` — version comparison logic supporting operators: `lt`, `lte`, `gt`, `gte`, `eq`

**Parallel processing:** Uses `parallel` gem for concurrent reminder processing. Handles older parallel gem API differences. File scanning parallelism is handled by the Rust extension (or `parallel` in fallback mode).

**Rails integration:** `Railtie` auto-loads `remind_me:check_reminders` rake task when Rails is present.

## Test Structure

Tests use RSpec with SimpleCov (90% overall minimum, 80% per-file). Fixture files live in `spec/testing_grounds/` organized by `single_line/` and `multi_line/` comment styles. The `runner_spec.rb` is the main integration test; unit tests are organized by reminder type under `spec/remind_me/reminder/`.

## Style

RuboCop config: single quotes (double for interpolation), 120-char line limit, 14 method length limit. Documentation cop disabled for specs.

## CI

GitHub Actions has two jobs: `build` (pure Ruby, all Ruby versions 2.3.7–3.2.2 + JRuby 9.2–9.4) and `build-native` (with Rust extension, Ruby 2.7.4–3.2.2).
