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

### ios sync_certificates

```sh
[bundle exec] fastlane ios sync_certificates
```

Sync certificates and provisioning profiles

### ios distribute_beta

```sh
[bundle exec] fastlane ios distribute_beta
```

Distribute existing build to beta testers

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Submit to App Store Review

### ios create_app_version

```sh
[bundle exec] fastlane ios create_app_version
```

Create a new version on App Store Connect

### ios download_metadata

```sh
[bundle exec] fastlane ios download_metadata
```

Download metadata from App Store Connect

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
