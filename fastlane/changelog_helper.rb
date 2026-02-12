# changelog_helper.rb
# Helper module to extract changelog entries from CHANGELOG.md

require 'fastlane_core/ui/ui'

module ChangelogHelper
  # Import Fastlane's UI for logging
  UI = FastlaneCore::UI unless defined?(UI)

  # GitHub repository URL for feedback links (TestFlight)
  GITHUB_REPO_URL = "https://github.com/v2er-app/iOS"

  # Support email for App Store release notes
  SUPPORT_EMAIL = "hi@v2er.app"

  # TestFlight changelog character limit
  TESTFLIGHT_CHANGELOG_LIMIT = 4000

  # Patterns for individual entries to exclude when falling back to filtering
  # (used only for old changelog entries without "### What's New" section)
  TECHNICAL_ENTRY_PATTERNS = [
    /\bCI\/?CD\b/i,
    /\bpipeline\b/i,
    /\binfrastructure\b/i,
    /\bworkflow\b/i,
    /\bcodebase\b/i,
    /\brefactor/i,
    /\bdeprecated API\b/i,
    /\bInfo\.plist\b/i,
    /\bTestFlight\b/i,
    /\bcode signing\b/i,
    /\bkeychain\b/i,
    /\bcertificate/i,
    /\brelease pipeline\b/i,
    /\bversion management\b/i,
    /\bconfiguration files\b/i,
    /\bautomated workflow\b/i,
    /\bgit remote\b/i,
    /\brepository\b/i,
    /\bMatch\b.*\bbranch\b/i,
    /\bbuild.*deploy/i,
  ].freeze

  # Extract the full changelog section for a specific version from CHANGELOG.md
  # @param version [String] The version to extract (e.g., "1.2.8")
  # @return [String] The changelog content for the specified version
  def self.extract_changelog(version)
    changelog_path = File.expand_path("../CHANGELOG.md", __dir__)

    unless File.exist?(changelog_path)
      UI.error("CHANGELOG.md not found at #{changelog_path}")
      return "Bug fixes and improvements"
    end

    content = File.read(changelog_path)

    # Match the version section, handling both "vX.Y.Z" and "X.Y.Z" formats
    # Also capture optional build number like "v1.2.8 (Build 55)"
    version_pattern = /^##\s+v?#{Regexp.escape(version)}(?:\s+\(Build\s+\w+\))?\s*$/

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
    formatted_changelog = format_for_testflight(changelog)

    UI.success("Extracted changelog for version #{version}:")
    UI.message(formatted_changelog)

    formatted_changelog
  end

  # Extract only the "### What's New" section for a specific version.
  # This section contains pre-written, App Store-ready user-facing text.
  # @param version [String] The version to extract (e.g., "1.2.8")
  # @return [String, nil] The What's New content, or nil if section not found
  def self.extract_whats_new(version)
    changelog_path = File.expand_path("../CHANGELOG.md", __dir__)
    return nil unless File.exist?(changelog_path)

    content = File.read(changelog_path)
    version_pattern = /^##\s+v?#{Regexp.escape(version)}(?:\s+\(Build\s+\w+\))?\s*$/

    lines = content.lines
    version_start = nil

    # Find the version section
    lines.each_with_index do |line, index|
      if line.match?(version_pattern)
        version_start = index
        break
      end
    end

    return nil if version_start.nil?

    # Find the "### What's New" header within this version section
    whats_new_start = nil
    ((version_start + 1)...lines.length).each do |index|
      line = lines[index]
      # Stop if we hit the next version or separator
      break if line.match?(/^##\s+/) || line.match?(/^---/)

      if line.strip.match?(/^###\s+What's New\s*$/i)
        whats_new_start = index
        break
      end
    end

    return nil if whats_new_start.nil?

    # Collect lines until the next ### header, ## header, or ---
    result_lines = []
    ((whats_new_start + 1)...lines.length).each do |index|
      line = lines[index]
      break if line.match?(/^###?\s+/) || line.match?(/^---/)
      result_lines << line
    end

    text = result_lines.join("").strip
    text.empty? ? nil : text
  end

  # Format changelog content for TestFlight display
  # @param content [String] Raw changelog content
  # @return [String] Formatted changelog
  def self.format_for_testflight(content)
    # Convert numbered lists to bullet points for better readability
    formatted = content.gsub(/^\d+\.\s+/, "• ")

    # Add feedback link at the end
    feedback_link = "\n\n问题反馈: #{GITHUB_REPO_URL}/issues"

    # Ensure we don't exceed TestFlight's changelog length limit (4000 chars)
    if (formatted + feedback_link).length > TESTFLIGHT_CHANGELOG_LIMIT
      extra_message = "\n\n(See full changelog at #{GITHUB_REPO_URL.sub('https://', '')})"
      max_length = TESTFLIGHT_CHANGELOG_LIMIT - feedback_link.length - extra_message.length
      formatted = formatted[0...max_length] + extra_message
    end

    formatted + feedback_link
  end

  # Get App Store "What's New" text for a specific version.
  # Prefers the dedicated "### What's New" section in CHANGELOG.md (new format).
  # Falls back to filtering the full changelog for older entries without that section.
  # @param version [String] The version (e.g., "1.2.8")
  # @return [String] Clean, App Store-ready release notes
  def self.app_store_whats_new(version)
    # Try the dedicated "### What's New" section first (new CHANGELOG format)
    whats_new = extract_whats_new(version)

    if whats_new
      UI.success("Found '### What's New' section for version #{version}")
      formatted = whats_new
    else
      # Fallback: extract full raw changelog and filter out technical entries
      UI.important("No '### What's New' section found for #{version}, falling back to filtering")
      raw = extract_raw_changelog(version) || "Bug fixes and improvements"
      formatted = filter_for_app_store(raw)
    end

    # Append support email
    formatted += "\n\nFeedback: #{SUPPORT_EMAIL}"

    # App Store "What's New" limit is 4000 chars
    if formatted.length > TESTFLIGHT_CHANGELOG_LIMIT
      max_length = TESTFLIGHT_CHANGELOG_LIMIT - "\n\nFeedback: #{SUPPORT_EMAIL}".length - 3
      formatted = formatted[0...max_length] + "...\n\nFeedback: #{SUPPORT_EMAIL}"
    end

    UI.message("App Store What's New:\n#{formatted}")
    formatted
  end

  # Filter raw changelog content by removing technical entries, emojis, and headers.
  # Used as fallback for old changelog entries without "### What's New" section.
  # @param content [String] Raw changelog content
  # @return [String] Filtered user-facing text
  def self.filter_for_app_store(content)
    lines = content.lines
    result_lines = []
    skip_section = false

    lines.each do |line|
      stripped = line.strip

      # Check for section headers (### Section Name)
      if stripped.match?(/^###\s+/)
        section_name = stripped.gsub(/^###\s+/, '').gsub(/[\u{1F000}-\u{1FFFF}\u{2600}-\u{27BF}]/, '').strip
        skip_section = section_name.downcase.include?("technical")
        next
      end

      next if skip_section
      next if stripped.empty?
      next if TECHNICAL_ENTRY_PATTERNS.any? { |pattern| stripped.match?(pattern) }

      entry = stripped.sub(/^[-*•]\s+/, '').strip
      next if entry.empty?

      result_lines << "- #{entry}"
    end

    formatted = result_lines.join("\n")

    # Strip emojis (App Store Connect rejects them)
    formatted = formatted
      .encode('UTF-8')
      .gsub(/[\u{00A9}\u{00AE}\u{203C}\u{2049}\u{20E3}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}\u{231A}-\u{231B}\u{2328}\u{23CF}\u{23E9}-\u{23F3}\u{23F8}-\u{23FA}\u{24C2}\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{27BF}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}\u{3297}\u{3299}\u{FE00}-\u{FE0F}\u{1F000}-\u{1FFFF}\u{200D}\u{E0020}-\u{E007F}]/, '')
      .gsub(/  +/, ' ')
      .strip

    formatted.empty? ? "Bug fixes and improvements" : formatted
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

  # Get all versions from CHANGELOG.md in order (newest first)
  # @return [Array<String>] List of version strings
  def self.get_all_versions
    changelog_path = File.expand_path("../CHANGELOG.md", __dir__)

    unless File.exist?(changelog_path)
      UI.error("CHANGELOG.md not found at #{changelog_path}")
      return []
    end

    content = File.read(changelog_path)
    versions = []

    content.each_line do |line|
      if match = line.match(/^##\s+v?(\d+\.\d+\.\d+)/)
        versions << match[1]
      end
    end

    versions
  end

  # Extract raw changelog content for a version (without formatting)
  # @param version [String] The version to extract
  # @return [String, nil] Raw changelog content or nil if not found
  def self.extract_raw_changelog(version)
    changelog_path = File.expand_path("../CHANGELOG.md", __dir__)

    unless File.exist?(changelog_path)
      return nil
    end

    content = File.read(changelog_path)
    version_pattern = /^##\s+v?#{Regexp.escape(version)}(?:\s+\(Build\s+\w+\))?\s*$/

    lines = content.lines
    start_index = nil
    end_index = nil

    lines.each_with_index do |line, index|
      if line.match?(version_pattern)
        start_index = index
        break
      end
    end

    return nil if start_index.nil?

    ((start_index + 1)...lines.length).each do |index|
      line = lines[index]
      if line.match?(/^##\s+/) || line.match?(/^---/)
        end_index = index
        break
      end
    end

    end_index ||= lines.length

    changelog_lines = lines[(start_index + 1)...end_index]
    changelog_lines.join("").strip
  end

  # Get changelog for current version and up to 2 previous versions
  # Combined length respects TestFlight's 4000 character limit
  # @return [String] Combined changelog for TestFlight
  def self.get_current_changelog
    current_version = get_current_version
    all_versions = get_all_versions

    # Find current version index
    current_index = all_versions.index(current_version)

    if current_index.nil?
      UI.important("Current version #{current_version} not found in CHANGELOG.md")
      return "Bug fixes and improvements"
    end

    # Get up to 3 versions (current + 2 previous)
    versions_to_include = all_versions[current_index, 3] || [current_version]

    # Build combined changelog
    combined_parts = []
    feedback_header = "唯一问题反馈渠道:https://v2er.app/help\n\n"
    truncation_notice = "\n\n(See full changelog at #{GITHUB_REPO_URL.sub('https://', '')})"

    # Reserve space for feedback header
    available_space = TESTFLIGHT_CHANGELOG_LIMIT - feedback_header.length

    versions_to_include.each_with_index do |version, index|
      raw_content = extract_raw_changelog(version)
      next if raw_content.nil? || raw_content.empty?

      # Format the content (convert numbered lists to bullets)
      formatted_content = raw_content.gsub(/^\d+\.\s+/, "• ")

      # Add version header for older versions
      if index == 0
        version_section = formatted_content
      else
        version_section = "\n\n--- v#{version} ---\n#{formatted_content}"
      end

      # Check if adding this section would exceed the limit
      current_length = combined_parts.join.length
      if current_length + version_section.length <= available_space
        combined_parts << version_section
      else
        # Try to fit as much as possible with truncation notice
        remaining_space = available_space - current_length - truncation_notice.length
        if remaining_space > 50 && index > 0
          combined_parts << version_section[0...remaining_space]
          combined_parts << truncation_notice
        end
        break
      end
    end

    if combined_parts.empty?
      return feedback_header + "Bug fixes and improvements"
    end

    result = feedback_header + combined_parts.join

    UI.success("Combined changelog for #{versions_to_include.length} version(s): #{versions_to_include.join(', ')}")
    UI.message("Total length: #{result.length} / #{TESTFLIGHT_CHANGELOG_LIMIT} characters")

    result
  end

  # Validate that changelog exists for the current version
  # @return [Boolean] True if changelog exists, false otherwise
  def self.validate_changelog_exists
    current_version = get_current_version
    changelog_path = File.expand_path("../CHANGELOG.md", __dir__)

    unless File.exist?(changelog_path)
      UI.error("CHANGELOG.md not found!")
      UI.message("Please create CHANGELOG.md with an entry for version #{current_version}")
      return false
    end

    content = File.read(changelog_path)
    version_pattern = /^##\s+v?#{Regexp.escape(current_version)}/

    if content.match?(version_pattern)
      UI.success("Changelog entry found for version #{current_version}")
      return true
    else
      UI.error("No changelog entry found for version #{current_version}")
      UI.message("Please add a changelog entry in CHANGELOG.md:")
      UI.message("")
      UI.message("## v#{current_version}")
      UI.message("")
      UI.message("### What's New")
      UI.message("- User-facing change description")
      UI.message("")
      return false
    end
  end
end
