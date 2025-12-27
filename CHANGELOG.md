# Changelog

All notable changes to V2er iOS app will be documented in this file.

## v1.2.2 (Build XX)
1. Feature: Add reply sorting by popularity for better content discovery
2. Feature: Redesigned feedback section with improved vertical layout
3. Fix: Check-in timer now resets at 8 AM instead of midnight for better daily routine alignment
4. Fix: Auto check-in now triggers correctly when returning to the app
5. Fix: Tapping a single item no longer opens all items in tag detail page
6. Fix: Improved text handling when replies contain inline images
7. Fix: Better markdown rendering for special characters

## v1.2.1 (Build XX)
1. Feature: Add Imgur image upload support for easier image sharing
2. Feature: Auto check-in when app returns to foreground
3. Feature: Add thank reply functionality to reply list
4. Improvement: Enhanced release pipeline with optional public beta distribution

## v1.2.0 (Build XX)
1. Feature: Add daily check-in button with automatic and manual check-in support
2. Feature: Display consecutive check-in days on Me tab
3. Feature: Add share, sticky (10 min), and fade (1 day) options to topic detail menu
4. Fix: Remove duplicate loading indicator on topic detail page
5. Fix: Prevent small images and emojis from expanding beyond their natural size
6. Fix: Toast notifications now animate smoothly and dismiss reliably
7. Fix: Tapping one item no longer opens all items in user profile
8. Improvement: Enhanced mobile web viewing experience for topics
9. Improvement: Updated TestFlight support email

## v1.1.20 (Build XX)
1. Feature: Add splash screen with centered logo on app launch
2. Feature: Improved markdown rendering with support for task list checkboxes
3. Feature: Enhanced HTML content display with additional tag support
4. Fix: Tables now render as proper visual tables instead of plain text
5. Fix: Images in replies display correctly with improved loading
6. Fix: Smoother pull-to-refresh animation with system List integration
7. Fix: Better scrolling behavior with improved bottom bounce handling
8. Improvement: RichView styles optimized to match Android app appearance
9. Improvement: Enhanced overall content rendering quality

## v1.1.19 (Build XX)
1. Infrastructure: Migrate certificate management to shared ios-certificates repository
2. Improvement: Update Fastlane Match to use git@github.com:graycreate/ios-certificates.git
3. Test: Verify release pipeline works with new Match repository configuration

## v1.1.18 (Build XX)
1. Improvement: Upgrade all CI/CD workflows to use Xcode 26.0.1 (latest version)
2. Improvement: Use macOS 26 runners with Fastlane 2.228.0 for improved build performance
3. Test: Verify release pipeline works correctly with new Xcode version

## v1.1.17 (Build XX)
1. Fix: Restore stable release pipeline configuration from Oct 10
2. Fix: Remove invalid Fastlane export_compliance parameters
3. Improvement: Use proven working TestFlight upload configuration

## v1.1.16 (Build XX)
1. Test: Pipeline validation test for CI/CD workflow
2. Improvement: Verify automatic build number increment
3. Improvement: Test TestFlight distribution automation

## v1.1.15 (Build 51)
1. Fix: Configure automatic export compliance bypass for TestFlight releases
2. Improvement: Added ITSAppUsesNonExemptEncryption flag to automate compliance
3. Improvement: Enhanced Fastlane with export compliance parameters for automatic distribution

## v1.1.14 (Build 50)
1. Test: Verify TestFlight internal distribution pipeline with explicit build number
2. Improvement: Test automatic distribution to App Store Connect Users group

## v1.1.13 (Build 48)
1. Improvement: Optimize TestFlight release pipeline to skip export compliance review
2. Improvement: Add explicit internal tester group distribution for immediate availability
3. Improvement: Clarify automatic distribution messaging in release workflow

## v1.1.12 (Build 48)
1. Fix: Configure automatic distribution to internal testers on TestFlight
2. Improvement: Builds now automatically appear for App Store Connect Users group after processing

## v1.1.5 (Build XX)
1. Fix: Resolve online count display bug where count always showed as 0
2. Feature: Add configurable TestFlight release channel (internal/public_beta)
3. Improvement: Default to internal testing for faster iteration without beta review
4. Improvement: Support manual public beta distribution through workflow parameter

## v1.1.4 (Build XX)
1. Feature: Add green indicator dot to online user count for better visual indication
2. Feature: Implement smooth numeric animation for online count changes (iOS 16+)
3. Improvement: Add smart 300ms delay before hiding refresh indicator when online count updates
4. Improvement: Enhance user feedback by allowing time to see count changes

## v1.1.3 (Build XX)
1. Feature: Display online user count in pull-to-refresh view with live server data
2. Feature: Add user balance display (gold/silver/bronze coins) to Me page
3. Fix: Correct balance parsing to properly separate coin types
4. Improvement: Optimize balance display UI with compact spacing and improved readability
5. Improvement: Enhance tab bar color contrast in both light and dark modes

## v1.1.2 (Build 44)
1. Feature: Add feed filter menu with Reddit-style dropdown for better content filtering
1. Feature: Update app icon with single high-resolution asset for better display quality
2. Feature: Add feedback link to TestFlight release notes for easier user communication

## v1.1.1 (Build 43)
1. Feature: Add feed filter menu with Reddit-style dropdown for better content filtering
2. Fix: Prevent crash when clicking Ignore/Report buttons without being logged in
3. Fix: Improve TestFlight beta distribution configuration
4. Feature: Enable automatic TestFlight beta distribution to public testers

## v1.1.0 (Build 30)
1. Feature: Initial public beta release
2. Fix: Resolve iOS build hanging at code signing step
3. Fix: Improve version management system using xcconfig
4. Feature: Centralized version configuration in Version.xcconfig

---

## How to Update Changelog

When updating the version in `V2er/Config/Version.xcconfig`:

1. Add a new version section at the top of this file
2. List all changes since the last version:
   - Use "Feature:" for new features
   - Use "Fix:" for bug fixes
   - Use "Improvement:" for enhancements
   - Use "Breaking:" for breaking changes

Example format:
```
## vX.Y.Z (Build N)
1. Feature: Description of new feature
2. Fix: Description of bug fix
3. Improvement: Description of enhancement
```

The changelog will be automatically extracted and used in TestFlight release notes.
