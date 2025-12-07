
class Plan9port < Formula
  desc "Plan 9 from User Space"
  homepage "https://9fans.github.io/plan9port/"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.zip"
  version "2025.12.06.0"
  sha256 "303cf10c600e35eb186070eb6ffd9cb90a99e1042c48d1ff0ee5079f3fa176dd"
  license "MIT"

  # Apple Silicon only
  depends_on arch: :arm64
  depends_on :macos

  def install

    system "./INSTALL", "-r", buildpath, "-b", prefix/"plan9", "-k"

    # install a launch shim `9'
    (bin/"9").write <<~EOS
      #!/bin/sh
      exec "#{prefix}/plan9/bin/9" "$@"
    EOS
  end

  test do 
    assert_match "Plan 9", shell_output("#{bin}/9 ls /")
  end
end
