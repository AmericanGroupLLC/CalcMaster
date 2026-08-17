fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Run the Flutter test suite

### ios bootstrap

```sh
[bundle exec] fastlane ios bootstrap
```

ONE-TIME: register the App ID + create the App Store Connect record

### ios build

```sh
[bundle exec] fastlane ios build
```

Build a signed App Store IPA via Flutter (manual signing)

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build + upload to TestFlight (works for the very first build too)

### ios release_xcode

```sh
[bundle exec] fastlane ios release_xcode
```

Upload an Xcode-signed IPA + metadata and submit for review (Apple ID auth)

### ios release

```sh
[bundle exec] fastlane ios release
```

Build + upload binary, metadata, screenshots, and submit for App Store review

----


## Android

### android beta

```sh
[bundle exec] fastlane android beta
```

Build + upload the AAB + listing to the Play internal track

### android release

```sh
[bundle exec] fastlane android release
```

Build + upload the AAB + listing straight to production

### android promote

```sh
[bundle exec] fastlane android promote
```

Promote the current internal build to production (no new binary)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
