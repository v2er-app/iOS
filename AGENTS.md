# Repository Guidelines

## Project Structure & Module Organization
- `V2er/` contains the SwiftUI app; feature views live in `View/`, state management in `State/`, and shared configuration (including `Version.xcconfig`) in `Config/`.
- `V2erTests/` hosts unit tests for reducers, services, and view models; `V2erUITests/` is reserved for UI automation suites.
- `fastlane/` holds release automation (`Fastfile`, `changelog_helper.rb`), while `scripts/` includes utilities such as `update-version.sh`.
- Asset bundles (`Assets.xcassets`, `Preview Content/`) and bundled web resources (`www/`) ship with the iOS target; marketing collateral lives in `website/`.

## Build, Test, and Development Commands
```bash
xcodebuild -project V2er.xcodeproj -scheme V2er -configuration Debug build   # Local debug build
xcodebuild test -project V2er.xcodeproj -scheme V2er -destination 'platform=iOS Simulator,name=iPhone 14'   # Unit/UI tests
fastlane beta                                                                # Validate changelog, bump build number, upload to TestFlight
fastlane distribute_beta                                                     # Distribute an existing TestFlight build to beta groups
./scripts/update-version.sh 1.2.0 42                                         # Update MARKETING_VERSION and CURRENT_PROJECT_VERSION
```
Run automation from the repository root; Fastlane expects valid App Store Connect credentials in your environment.

## Coding Style & Naming Conventions
- Follow Swift API Design Guidelines: `UpperCamelCase` for types, `lowerCamelCase` for values, and keep file-per-feature modules consistent with existing folders (e.g., add Feed views under `V2er/View/Feed/`).
- Indent with four spaces, prefer SwiftUI composition over UIKit, and scope helpers with `private` extensions to keep reducers and services focused.
- Keep reducers pure; network side effects belong in service layers under `V2er/State/Networking/`.

## Testing Guidelines
- Mirror production code structure inside `V2erTests/`; create `FeatureNameTests.swift` alongside the feature reducer or service you touch.
- Use `xcodebuild test` (above) for local validation; set destinations to match CI simulators (iPhone 14, iOS 17) to avoid config drift.
- When adding UI work, include a smoke scenario in `V2erUITests/` or capture simulator screenshots for PR reviewers if automation is impractical.

## Commit & Pull Request Guidelines
- Adopt the conventional short prefix format from history, e.g., `chore: bump version to 1.1.18` or `fix(auth): handle MFA token refresh`; keep messages in English and under 72 characters.
- Each PR should link the tracking issue, describe user-facing impact, list test evidence (`xcodebuild test`, simulator run), and attach before/after screenshots for UI changes.
- Update `CHANGELOG.md` and `V2er/Config/Version.xcconfig` together; CI will block TestFlight lanes if the changelog entry is missing.
