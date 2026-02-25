# SkipPlayground Android Test Failure Notes (Minimal Repro)

Investigation date: February 25, 2026
Package: `libs/skip-playground`
Type: transpiled + bridged minimal module

## Symptoms

After running `skip android build`, the next Android parity test run can fail at Kotlin compile with:

- `.../SkipPlayground/src/androidTest/kotlin/skip/playground/PackageSupportTest.kt:3:13 Unresolved reference 'lib'`

Typical cascade includes unresolved symbols from:

- `skip.lib`
- `skip.foundation`
- `skip.unit`
- XCTest symbols (`XCTestCase`, `XCTAssert*`)

Failing task:

- `:SkipPlayground:compileDebugAndroidTestKotlin FAILED`

## Minimal Feature Used For Repro

To ensure the repro is meaningful, this package includes a small feature and XCTests that depend on symbols involved in the unresolved chain:

- `Sources/SkipPlayground/MockRuntime.swift`
  - uses simple bridged API with primitive types (`String`, `[String]`)
- `Tests/SkipPlaygroundTests/SkipPlaygroundTests.swift`
  - uses `XCTestCase`, `XCTAssert*`, `Bundle.module`, `JSONDecoder`

Package setup notes:

- `Package.swift` includes direct `skip-bridge` dependency so bridge-generated files can import `SkipBridge`.
- Bridge-facing source is wrapped in `#if !SKIP_BRIDGE` to avoid bridge-build redeclaration issues.

## Repro Sequence

1. Clean + build + test:
   - `rm -rf .build`
   - `swift build`
   - `ANDROID_SERIAL=R5CXC1DKRNA skip test --plain --verbose`
2. Then run:
   - `skip android build`
3. Then run test again:
   - `ANDROID_SERIAL=R5CXC1DKRNA skip test --plain --verbose`

Observed behavior:

- First test lane produced Android results (4/4 passed), but `skip test` reported known JUnit output path mismatch (`testDebugUnitTest` path missing).
- `skip android build` completes, but prunes dependency Kotlin outputs.
- After that build, next `skip test` fails with unresolved `skip.lib` starting in `PackageSupportTest.kt`.

## Generated Output State Change

Before `skip android build` (after first test run):

- `skip-lib`: `kt=40`, `sourcemap=14`
- `skip-foundation`: `kt=59`, `sourcemap=58`
- `skip-unit`: `kt=1`, `sourcemap=0`

After `skip android build`:

- `skip-lib`: `kt=0`, `sourcemap=14`
- `skip-foundation`: `kt=0`, `sourcemap=58`
- `skip-unit`: `kt=0`, `sourcemap=0`

So dependency `.kt` files are pruned while sourcemaps remain.

## Before/After Diff Snapshot

Captured around `skip android build --plain --verbose`:

- `skip-lib` kotlin tree entries: `54 -> 14` (all `.kt` removed, `.sourcemap` retained)
- `skip-foundation` kotlin tree entries: `117 -> 58` (all `.kt` removed, `.sourcemap` retained)
- `skip-unit` kotlin tree entries: `1 -> 0` (`XCTest.kt` removed)

Deleted file examples:

- `.../skip-lib/.../src/main/kotlin/skip/lib/Array.kt`
- `.../skip-lib/.../src/main/kotlin/skip/lib/SkipLib.kt`
- `.../skip-foundation/.../src/main/kotlin/skip/foundation/Bundle.kt`
- `.../skip-foundation/.../src/main/kotlin/skip/foundation/JSONDecoder.kt`
- `.../skip-unit/.../src/main/kotlin/skip/unit/XCTest.kt`

## Phase Attribution (What Prunes the Files)

The pruning occurs during `skipstone` transpile invocations launched by `skip android build`, not during Android test compilation.

In verbose logs:

1. `skip android build` runs `skip transpile` for dependency modules, for example:
   - `skip transpile --project .../.build/checkouts/skip-unit/Sources/SkipUnit ...`
   - `skip transpile --project .../.build/checkouts/skip-lib/Sources/SkipLib ...`
   - `skip transpile --project .../.build/checkouts/skip-foundation/Sources/SkipFoundation ...`
2. For each module, logs show:
   - `Skip<Module>.skipcode.json ... codebase unchanged`
   - `.Skip<Module>.sourcehash ... sourcehash unchanged`
   - then many `warning: removing stale output file: .../*.kt`

So the same phase marks outputs as unchanged, yet removes existing Kotlin source files from dependency output folders.

## What This Confirms

This failure is reproducible in a minimal module and is not specific to Google Cast code.

The immediate cause is generated output invalidation/pruning: dependency Kotlin sources disappear after `skip android build`, and subsequent `skip test` compiles against incomplete dependency outputs.
