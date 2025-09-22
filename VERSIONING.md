# Version Management Guide

## Version Terminology

This project uses two version identifiers:

### VERSION_NAME (MARKETING_VERSION in Xcode)
- **What**: User-facing version number (e.g., "1.1.2")
- **Where**: Displayed in App Store and Settings
- **Format**: MAJOR.MINOR.PATCH
- **When to change**: For feature releases and updates

### VERSION_CODE (CURRENT_PROJECT_VERSION in Xcode)
- **What**: Build number (e.g., "28", "29", "30")
- **Where**: Used internally by Apple for tracking builds
- **Format**: Integer that must always increase
- **When to change**: Every single build uploaded to TestFlight/App Store

## ✅ Centralized Version Configuration

**Versions are now defined in ONE place only!**

### How to Update Versions

To update versions, simply edit the file `V2er/Config/Version.xcconfig`:

```bash
# Open the file
V2er/Config/Version.xcconfig

# Update these two lines:
MARKETING_VERSION = 1.1.2         # VERSION_NAME (user-facing version)
CURRENT_PROJECT_VERSION = 29       # VERSION_CODE (build number)
```

**That's it!** No need to edit project.pbxproj or any other files. The xcconfig file is automatically loaded by Xcode and applies to all build configurations.

## Important Notes

1. **Only update Version.xcconfig** - Never modify version numbers in project.pbxproj
2. **VERSION_CODE must always increase** - even for the same VERSION_NAME
3. **Fastlane auto-increment**: Our Fastlane setup automatically increments VERSION_CODE for TestFlight builds
4. **Info.plist**: Automatically uses these values via:
   - `$(MARKETING_VERSION)` → CFBundleShortVersionString (VERSION_NAME)
   - `$(CURRENT_PROJECT_VERSION)` → CFBundleVersion (VERSION_CODE)

## Example Version Progression

| VERSION_NAME | VERSION_CODE | Notes |
|-------------|--------------|-------|
| 1.1.0 | 27 | Previous release |
| 1.1.1 | 28 | Bug fix release |
| 1.1.2 | 29 | First build of 1.1.2 |
| 1.1.2 | 30 | Second build of 1.1.2 (bug fix) |
| 1.1.2 | 31 | Final 1.1.2 for App Store |
| 1.2.0 | 32 | Next feature release |

## Why Two Separate Values?

- **VERSION_NAME**: What users see and understand
- **VERSION_CODE**: Ensures every upload to Apple is unique
- Multiple builds of the same version can exist (e.g., testing different fixes)
- Apple requires VERSION_CODE to always increase for tracking