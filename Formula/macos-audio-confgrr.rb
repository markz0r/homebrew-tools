class MacosAudioConfgrr < Formula
  desc "Set default macOS output device and sample rate via CoreAudio (configurable)"
  homepage "https://github.com/markz0r/macos-audio-confgrr"
  url "https://github.com/markz0r/macos-audio-confgrr/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "4693cca72fad599e4cd544712b6341dd19b5192c476b5ec3a7778ca0ee86b7eb"
  license "GPL-3.0"

  depends_on :macos
  depends_on xcode: :build

  def install
    system "mkdir", "-p", ".build"
    system "xcrun", "swiftc", "-O", "-o", ".build/macos-audio-confgrr", "Sources/main.swift"
    bin.install ".build/macos-audio-confgrr"

    # ship examples to share/
    (share/"macos-audio-confgrr/config").install "config/macos-audio-confgrr-settings.json"
    (prefix/"launchd").install Dir["launchd/*.plist"]
    (prefix/"scripts").install Dir["scripts/*.sh"]
  end

  def caveats
    <<~EOS
      Example config was installed to:
        #{share}/macos-audio-confgrr/config/macos-audio-confgrr-settings.json

      To run from config on a schedule:
        mkdir -p ~/Library/Application\\ Support/macos-audio-confgrr/config
        cp "#{share}/macos-audio-confgrr/config/macos-audio-confgrr-settings.json" \
           "~/Library/Application Support/macos-audio-confgrr/config/"

        # Create/update LaunchAgent with interval from config:
        "#{opt_prefix}/scripts/apply-config-launchd.sh"

      To run once at login (uses login plist):
        cp "#{opt_prefix}/launchd/one.mwc.macos-audio-confgrr.login.plist" \
           ~/Library/LaunchAgents/
        launchctl load ~/Library/LaunchAgents/one.mwc.macos-audio-confgrr.login.plist
    EOS
  end

  test do
    # Should emit 'Device not found yet' if run against a bogus device with 1 try
    output = shell_output("#{bin}/macos-audio-confgrr --device 'Not-A-Device' --tries 1 --wait 0 2>&1", 1)
    assert_match "Device not found yet", output
  end
end
