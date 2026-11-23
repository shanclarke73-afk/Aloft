fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### bump

```sh
[bundle exec] fastlane bump
```

Raise the build number in pubspec.yaml by one (pass version:1.0.2 to change the version name too)

----


## iOS

### ios check

```sh
[bundle exec] fastlane ios check
```

Check the App Store Connect key works and show the latest TestFlight build

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build the prod IPA and upload it to TestFlight

----


## Android

### android check

```sh
[bundle exec] fastlane android check
```

Check the Play key works (reads the Internal testing track, changes nothing)

### android internal

```sh
[bundle exec] fastlane android internal
```

Build the prod AAB and release it to Internal testing

### android production

```sh
[bundle exec] fastlane android production
```

Build the prod AAB and add it to a draft production release (finish it in Play Console)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
