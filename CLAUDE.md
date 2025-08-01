# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

V2er is a V2EX forum client built for iOS using SwiftUI. It implements a Redux-like unidirectional data flow architecture for state management.

## Development Commands

Since this is an Xcode project, most development is done through Xcode IDE. However, for command-line operations:

```bash
# Build the project
xcodebuild -project V2er.xcodeproj -scheme V2er -configuration Debug build

# Run tests
xcodebuild test -project V2er.xcodeproj -scheme V2er -destination 'platform=iOS Simulator,name=iPhone 14'

# Archive for App Store release
xcodebuild archive -project V2er.xcodeproj -scheme V2er -archivePath V2er.xcarchive

# Clean build folder
xcodebuild clean -project V2er.xcodeproj -scheme V2er

# Build for specific simulator
xcodebuild -project V2er.xcodeproj -scheme V2er -sdk iphonesimulator -configuration Debug
```

## Architecture

### Redux-like State Management

The app uses a centralized state management pattern similar to Redux:

1. **Store** (`V2er/State/DataFlow/Store.swift`): Single source of truth for application state
2. **Actions** (`V2er/State/DataFlow/Actions/`): Define state mutations
3. **Reducers** (`V2er/State/DataFlow/Reducers/`): Handle state updates based on actions
4. **States** (`V2er/State/`): Individual state containers for features

### Key Components

- **APIService** (`V2er/State/Networking/APIService.swift`): Central API handling for V2EX endpoints
- **SwiftSoup**: Used for HTML parsing of V2EX content
- **Kingfisher**: Image loading and caching
- **SwiftUI-WebView**: Web content display
- **Rich Text Rendering**: Custom implementation for V2EX content format

### View Organization

Views are organized by feature in `V2er/View/`:
- `Feed/`: Main topic feed
- `FeedDetail/`: Topic details and replies
- `Login/`: Authentication flow (including two-step login)
- `Me/`: User profile and settings
- `Message/`: Notifications
- `Explore/`: Discovery and search
- `Settings/`: App preferences
- `Widget/`: Reusable UI components

## Key Implementation Details

### Authentication
- Supports V2EX's standard login and two-step verification
- Login state managed in `LoginState.swift` and `LoginReducer.swift`
- Credentials persisted via `Persist.swift`

### Content Parsing
- V2EX HTML content parsed using SwiftSoup
- Rich text rendering implemented with custom `RichText.swift` and `HtmlView.swift`
- Special handling for V2EX-specific content formats

### State Updates
When implementing new features:
1. Define actions in appropriate `*Actions.swift` file
2. Create/update state in `*State.swift`
3. Implement reducer logic in `*Reducer.swift`
4. Connect to views using `@EnvironmentObject` Store

### API Integration
- All API calls go through `APIService.swift`
- Endpoints defined in `Endpoint.swift`
- HTML responses parsed into Swift models
- Network errors handled via `NetworkException.swift`

## Dependencies

Managed via Swift Package Manager:
- **Kingfisher**: Image loading
- **SwiftSoup**: HTML parsing
- **SwiftUI-WebView**: Web content
- **Atributika**: Rich text attributes

## Testing

Tests are located in:
- `V2erTests/`: Unit tests
- `V2erUITests/`: UI tests

Currently contains only boilerplate test setup.

## Important Notes

- Minimum iOS version: iOS 15.0
- Supported architectures: armv7, arm64
- Orientation: Portrait only on iPhone, all orientations on iPad
- UI Style: Light mode enforced
- Website submodule: Located at `website/` (separate repository)