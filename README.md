# SkipPlayground

This is a [Skip](https://skip.dev) Swift/Kotlin library project containing the following modules:

SkipPlayground

## Purpose

This repository exists as a minimal reproducible package for the issue where
`skip android build` can leave transpiled dependency outputs in a bad state
for the next Android parity test run.

## Observed Issue (Android Build -> Skip Test)

In this repro package, running `skip android build` can leave transpiled dependency
outputs in a bad state for the next `skip test` run on Android. A common failure is:

- `PackageSupportTest.kt:3:13 Unresolved reference 'lib'`

## Reproduction steps:

```bash
rm -rf .build
swift build
ANDROID_SERIAL=DEVICEREF skip test --plain --verbose # Passes (Save for JUnit folder discrepancies noted in https://github.com/orgs/skiptools/discussions/624)

skip android build --plain --verbose # Note the 'warning: removing stale output file...' messages
ANDROID_SERIAL=DEVICEREF skip test --plain --verbose # Fails w/ 'Unresolved reference'

rm -rf .build
swift build
ANDROID_SERIAL=DEVICEREF skip test --plain --verbose # Passes again
```

Desired behavior:

- The final `skip test` should also pass, same as the first `skip test`.

Actual behavior:

- The final `skip test` fails during Android test Kotlin compile, commonly starting with
  `PackageSupportTest.kt:3:13 Unresolved reference 'lib'`.

[Also see detailed investigation notes](.docs/skipplayground-android-test-failure-notes.md)
