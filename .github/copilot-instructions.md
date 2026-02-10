# GitHub Copilot Instructions

This file provides guidance to GitHub Copilot when working with code in this repository.

## Project Overview

V2er is a V2EX forum client for iOS built with SwiftUI. The app follows a Redux-like unidirectional data flow architecture for state management.

**Key Technologies:**
- SwiftUI for UI
- Redux-like state management pattern
- Swift Package Manager for dependencies
- Xcode project structure

## Code Style and Conventions

### Swift Style
- Follow Swift API Design Guidelines
- Use descriptive variable and function names
- Prefer `let` over `var` when possible
- Use type inference where it improves readability
- Keep files focused on single responsibility

### SwiftUI Patterns
- Use `@EnvironmentObject` for accessing the Store
- Separate view logic from business logic
- Keep views small and composable
- Use custom view modifiers for reusable styling

### State Management
The app uses a centralized Redux-like pattern:

1. **Store** (`V2er/State/DataFlow/Store.swift`): Single source of truth
2. **Actions** (`V2er/State/DataFlow/Actions/`): Define state mutations
3. **Reducers** (`V2er/State/DataFlow/Reducers/`): Handle state updates
4. **States** (`V2er/State/`): Individual feature state containers

When implementing new features:
1. Define actions in appropriate `*Actions.swift` file
2. Create/update state in `*State.swift`
3. Implement reducer logic in `*Reducer.swift`
4. Connect to views using `@EnvironmentObject` Store

## Project Structure

```
V2er/
├── State/              # State management
│   ├── DataFlow/      # Redux-like architecture
│   └── Networking/    # API services
├── View/              # SwiftUI views by feature
│   ├── Feed/         # Main topic feed
│   ├── FeedDetail/   # Topic details and replies
│   ├── Login/        # Authentication flow
│   ├── Me/           # User profile
│   ├── Message/      # Notifications
│   ├── Explore/      # Discovery
│   ├── Settings/     # App preferences
│   └── Widget/       # Reusable UI components
├── Config/           # Configuration files
└── www/              # Web content assets
```

## Architecture Components

### API Integration
- **APIService** (`V2er/State/Networking/APIService.swift`): Central API handling
- **Endpoints** defined in `Endpoint.swift`
- HTML responses parsed using SwiftSoup into Swift models
- Network errors handled via `NetworkException.swift`

### Authentication
- Supports V2EX standard login and two-step verification
- Login state in `LoginState.swift` and `LoginReducer.swift`
- Credentials persisted via `Persist.swift`

### Content Parsing
- V2EX HTML content parsed with SwiftSoup
- Rich text rendering: `RichText.swift` and `HtmlView.swift`
- Special handling for V2EX-specific formats

## Dependencies

Managed via Swift Package Manager:
- **Kingfisher**: Image loading and caching
- **SwiftSoup**: HTML parsing
- **SwiftUI-WebView**: Web content display
- **Atributika**: Rich text attributes

## Development Commands

### Building
```bash
# Build the project
xcodebuild -project V2er.xcodeproj -scheme V2er-iOS-configuration Debug build

# Build for simulator
xcodebuild -project V2er.xcodeproj -scheme V2er-iOS-sdk iphonesimulator -configuration Debug

# Clean build
xcodebuild clean -project V2er.xcodeproj -scheme V2er
```

### Testing
```bash
# Run tests
xcodebuild test -project V2er.xcodeproj -scheme V2er-iOS-destination 'platform=iOS Simulator,name=iPhone 14'
```

Test locations:
- `V2erTests/`: Unit tests
- `V2erUITests/`: UI tests

### Archiving
```bash
# Archive for App Store
xcodebuild archive -project V2er.xcodeproj -scheme V2er-iOS-archivePath V2er.xcarchive
```

## Release Management

### Version Management
Version info is centralized in `V2er/Config/Version.xcconfig`:
- `MARKETING_VERSION`: User-facing version (e.g., 1.1.1)
- `CURRENT_PROJECT_VERSION`: Build number (auto-incremented by CI)

### Release Process
1. **Update Version.xcconfig**
   ```bash
   # Edit V2er/Config/Version.xcconfig
   MARKETING_VERSION = 1.2.0
   ```

2. **Update CHANGELOG.md**
   Add a new section at the top:
   ```markdown
   ## v1.2.0 (Build XX)
   1. Feature: Description of new feature
   2. Fix: Description of bug fix
   3. Improvement: Description of enhancement
   ```

3. **Commit and push**
   ```bash
   git add V2er/Config/Version.xcconfig CHANGELOG.md
   git commit -m "chore: bump version to 1.2.0"
   git push origin main
   ```

**Important:** CHANGELOG.md is required for all releases. The build will fail if the current version is missing from the changelog.

### Fastlane Commands
```bash
# Build and upload to TestFlight (requires changelog)
fastlane beta

# Distribute existing build to beta testers
fastlane distribute_beta

# Sync certificates and provisioning profiles
fastlane sync_certificates
```

## Common Patterns

### Making API Calls
```swift
// 1. Define endpoint in Endpoint.swift
// 2. Call via APIService
// 3. Parse HTML response with SwiftSoup
// 4. Update state via action/reducer
```

### Adding a New Feature
```swift
// 1. Create *Actions.swift with action types
// 2. Create *State.swift with state model
// 3. Create *Reducer.swift with state logic
// 4. Create SwiftUI view
// 5. Connect view to Store with @EnvironmentObject
```

### State Updates
```swift
// Always dispatch actions to update state
dispatch(SomeActions.UpdateState(newValue))

// Never mutate state directly
// state.value = newValue  // ❌ Don't do this
```

## Important Constraints

- **Minimum iOS version**: iOS 15.0
- **Architectures**: armv7, arm64
- **Orientation**: Portrait only on iPhone, all on iPad
- **UI Style**: Light mode enforced
- **Submodules**: `website/` directory is a separate repository

## Pull Request Guidelines

- Always use English for PR titles and descriptions
- Follow conventional commit format
- Include changelog entry for version changes
- Ensure tests pass before submitting
- Keep changes focused and atomic

## Workflows

The repository includes several GitHub Actions workflows:

- **iOS Build & Test**: Runs on push/PR to main
- **PR Validation**: SwiftLint, conventional commits, PR sizing
- **Release**: Manual trigger for TestFlight/App Store
- **Dependency Updates**: Weekly automated updates
- **Code Quality**: SwiftFormat and coverage reporting

See `.github/workflows/README.md` for details.

## Getting Help

- Check existing documentation in CLAUDE.md, VERSIONING.md
- Review similar patterns in the codebase
- Refer to V2EX API documentation for endpoint details
- Check workflows README for CI/CD questions
