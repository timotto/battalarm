fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android test

```sh
[bundle exec] fastlane android test
```

Runs all the tests

### android internal

```sh
[bundle exec] fastlane android internal
```

Deploy a new version to Google Play internal track

### android beta

```sh
[bundle exec] fastlane android beta
```

Submit a new Beta Build to Crashlytics Beta

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Deploy a new version to the Google Play

### android promote_internal_to_closed

```sh
[bundle exec] fastlane android promote_internal_to_closed
```

Promote Internal Testing to Closed Testing

### android promote_closed_to_open

```sh
[bundle exec] fastlane android promote_closed_to_open
```

Promote Closed Testing to Open Testing

### android promote_open_to_prod

```sh
[bundle exec] fastlane android promote_open_to_prod
```

Promote Open Testing to production

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
