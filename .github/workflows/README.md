# GitHub Actions Workflows

This directory contains automated workflows for the V2er-iOS project.

## Workflows

### 🔨 iOS Build and Test (`ios-build-test.yml`)
- **Trigger**: Push to main/develop, Pull requests to main
- **Purpose**: Build the app and run tests
- **Features**:
  - Builds for iOS Simulator
  - Runs unit and UI tests
  - Caches Swift Package Manager dependencies
  - Uploads test results on failure

### ✅ PR Validation (`pr-validation.yml`)
- **Trigger**: Pull request events
- **Purpose**: Validate pull requests before merge
- **Features**:
  - SwiftLint analysis
  - PR size labeling (XS, S, M, L, XL, XXL)
  - Conventional commit message checking

### 🚀 Release (`release.yml`)
- **Trigger**: Manual workflow dispatch
- **Purpose**: Build and release to App Store
- **Features**:
  - Version bumping (major/minor/patch)
  - Archive and export IPA
  - Upload to TestFlight
  - Create GitHub release
  - Option for TestFlight-only releases

### 📦 Dependency Updates (`dependency-update.yml`)
- **Trigger**: Weekly (Mondays at 9 AM UTC) or manual
- **Purpose**: Keep dependencies up to date
- **Features**:
  - Updates Swift Package dependencies
  - Creates automated pull request
  - Security vulnerability scanning

### 📊 Code Quality (`code-quality.yml`)
- **Trigger**: Push to main/develop, Pull requests
- **Purpose**: Maintain code quality standards
- **Features**:
  - SwiftFormat checking
  - Code coverage reporting
  - Coverage badge generation

## Required Secrets

To use these workflows, configure the following secrets in your repository:

### For Release Workflow:
- `CERTIFICATES_P12`: Base64 encoded distribution certificate
- `CERTIFICATES_PASSWORD`: Certificate password
- `KEYCHAIN_PASSWORD`: Temporary keychain password
- `PROVISIONING_PROFILE_BASE64`: Base64 encoded provisioning profile
- `TEAM_ID`: Apple Developer Team ID
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID`: API key issuer ID
- `APP_STORE_CONNECT_API_KEY`: API key content

### For Coverage Badge (Optional):
- `GIST_SECRET`: GitHub personal access token with gist scope

## Setup Instructions

1. Generate required certificates and provisioning profiles from Apple Developer portal
2. Encode files to base64:
   ```bash
   base64 -i certificate.p12 -o certificate_base64.txt
   base64 -i profile.mobileprovision -o profile_base64.txt
   ```
3. Add secrets to repository settings
4. Update Xcode version in workflows if needed
5. Customize workflow triggers as needed

## Manual Triggers

Some workflows can be triggered manually from the Actions tab:
- **Release**: Choose release type (major/minor/patch) and TestFlight-only option
- **Dependency Updates**: Manually check for updates

## Maintenance

- Update Xcode version when new versions are released
- Review and update SwiftLint rules as needed
- Adjust test simulator versions for new iOS releases
- Monitor dependency update PRs for breaking changes