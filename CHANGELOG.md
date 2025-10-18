# Changelog

All notable changes to V2er iOS app will be documented in this file.

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
