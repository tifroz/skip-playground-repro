# SkipPlayground

This is a [Skip](https://skip.dev) Swift/Kotlin library project containing the following modules:

SkipPlayground

## Building

This project is a Swift Package Manager module that uses the
[Skip](https://skip.dev) plugin to transpile Swift into Kotlin.

Building the module requires that Skip be installed using
[Homebrew](https://brew.sh) with `brew install skiptools/skip/skip`.
This will also install the necessary build prerequisites:
Kotlin, Gradle, and the Android build tools.

## Testing

The module can be tested using the standard `swift test` command
or by running the test target for the macOS destination in Xcode,
which will run the Swift tests as well as the transpiled
Kotlin JUnit tests in the Robolectric Android simulation environment.

Parity testing can be performed with `skip test`,
which will output a table of the test results for both platforms.

## Known Issue (Android Build -> Parity Test)

In this repro package, running `skip android build` can leave transpiled dependency
outputs in a bad state for the next `skip test` run on Android. A common failure is:

- `PackageSupportTest.kt:3:13 Unresolved reference 'lib'`

Reproduction steps:

```bash
rm -rf .build
swift build
ANDROID_SERIAL=R5CXC1DKRNA skip test --plain --verbose
skip android build --plain --verbose
ANDROID_SERIAL=R5CXC1DKRNA skip test --plain --verbose
```

Detailed investigation notes are in:

- `.docs/skipplayground-android-test-failure-notes.md`
