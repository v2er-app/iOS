# changelog_helper.rb
# Helper module to extract changelog entries from CHANGELOG.md

require 'fastlane_core/ui/ui'

module ChangelogHelper
  # Import Fastlane's UI for logging
  UI = FastlaneCore::UI unless defined?(UI)
  # Extract changelog for a specific version from CHANGELOG.md
  # @param version [String] The version to extract (e.g., "1.1.1")
  # @return [String] The changelog content for the specified version
  def self.extract_changelog(version)
    changelog_path = File.expand_path("../CHANGELOG.md", __dir__)

    unless File.exist?(changelog_path)
      UI.error("CHANGELOG.md not found at #{changelog_path}")
      return "Bug fixes and improvements"
    end

    content = File.read(changelog_path)

    # Match the version section, handling both "vX.Y.Z" and "X.Y.Z" formats
    # Also capture optional build number like "v1.1.1 (Build 31)"
    version_pattern = /^##\s+v?#{Regexp.escape(version)}(?:\s+\(Build\s+\d+\))?\s*$/

    lines = content.lines
    start_index = nil
    end_index = nil

    # Find the start of the version section
    lines.each_with_index do |line, index|
      if line.match?(version_pattern)
        start_index = index
        break
      end
    end

    if start_index.nil?
      UI.important("Version #{version} not found in CHANGELOG.md")
      UI.message("Available versions:")
      lines.each do |line|
        if line.match?(/^##\s+v?\d+\.\d+\.\d+/)
          UI.message("  - #{line.strip}")
        end
      end
      return "Bug fixes and improvements"
    end

    # Find the end of the version section (next ## heading or ---)
    ((start_index + 1)...lines.length).each do |index|
      line = lines[index]
      if line.match?(/^##\s+/) || line.match?(/^---/)
        end_index = index
        break
      end
    end

    end_index ||= lines.length

    # Extract the changelog content (skip the version header)
    changelog_lines = lines[(start_index + 1)...end_index]

    # Remove leading/trailing empty lines and convert to string
    changelog = changelog_lines
      .join("")
      .strip

    if changelog.empty?
      UI.important("No changelog content found for version #{version}")
      return "Bug fixes and improvements"
    end

    # Format for TestFlight (convert numbered list to bullet points if needed)
    # TestFlight supports basic formatting
    formatted_changelog = format_for_testflight(changelog)

    UI.success("Extracted changelog for version #{version}:")
    UI.message(formatted_changelog)

    formatted_changelog
  end

  # Format changelog content for TestFlight display
  # @param content [String] Raw changelog content
  # @return [String] Formatted changelog
  def self.format_for_testflight(content)
    # TestFlight supports:
    # - Plain text
    # - Line breaks
    # - Basic formatting

    # Convert numbered lists to bullet points for better readability
    # "1. Feature: xxx" -> "• Feature: xxx"
    formatted = content.gsub(/^\d+\.\s+/, "• ")

    # Add feedback link at the end
    feedback_link = "\n\n问题反馈: https://github.com/v2er-app/iOS/issues"

    # Ensure we don't exceed TestFlight's changelog length limit (4000 chars)
    if (formatted + feedback_link).length > 4000
      extra_message = "\n\n(See full changelog at github.com/v2er-app/iOS)"
      max_length = 4000 - feedback_link.length - extra_message.length
      formatted = formatted[0...max_length] + extra_message
    end

    formatted + feedback_link
  end

  # Get the current version from Version.xcconfig
  # @return [String] The current marketing version
  def self.get_current_version
    xcconfig_path = File.expand_path("../Version.xcconfig", __dir__)

    unless File.exist?(xcconfig_path)
      UI.user_error!("Version.xcconfig not found at #{xcconfig_path}")
    end

    content = File.read(xcconfig_path)
    version_match = content.match(/MARKETING_VERSION\s*=\s*(.+)/)

    if version_match
      version = version_match[1].strip
      UI.message("Current version from Version.xcconfig: #{version}")
      version
    else
      UI.user_error!("Could not find MARKETING_VERSION in Version.xcconfig")
    end
  end

  # Validate that changelog exists for the current version
  # @return [Boolean] True if changelog exists, false otherwise
  def self.validate_changelog_exists
    current_version = get_current_version
    changelog_path = File.expand_path("../CHANGELOG.md", __dir__)

    unless File.exist?(changelog_path)
      UI.error("❌ CHANGELOG.md not found!")
      UI.message("Please create CHANGELOG.md with an entry for version #{current_version}")
      return false
    end

    content = File.read(changelog_path)
    version_pattern = /^##\s+v?#{Regexp.escape(current_version)}/

    if content.match?(version_pattern)
      UI.success("✅ Changelog entry found for version #{current_version}")
      return true
    else
      UI.error("❌ No changelog entry found for version #{current_version}")
      UI.message("Please add a changelog entry in CHANGELOG.md:")
      UI.message("")
      UI.message("## v#{current_version}")
      UI.message("1. Feature/Fix: Description of changes")
      UI.message("")
      return false
    end
  end
end
