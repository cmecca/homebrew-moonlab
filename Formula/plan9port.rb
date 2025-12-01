class plan9port < Formula
  desc "Plan 9 from User Space/Moonlab Port (macOS/arm64)"
  homepage "https://pkg.moonlab.org"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  version "0.1.0"
  sha256 "814a1aa814d49b6e1a64a3ade3f5ada1496338c30e977ebe8c60cd2e84e3ef06"
  license "LPL-1.02"

  depends_on :macos
  depends_on arch: :arm64

  def install
    ENV["PLAN9"] = prefix
    
    system "./INSTALL", "-b"
    
    prefix.install Dir["*"]
    
    (bin/"9").write <<~EOS
      #!/bin/bash
      export PLAN9=#{prefix}
      exec #{prefix}/bin/9 "$@"
    EOS
    
    %w[acme sam 9term].each do |app|
      (bin/app).write <<~EOS
        #!/bin/bash
        export PLAN9=#{prefix}
        exec #{prefix}/bin/#{app} "$@"
      EOS
      chmod 0755, bin/app
    end
    
    chmod 0755, bin/"9"
  end

  def caveats
    <<~EOS
      Plan9port GUI applications installed (native macOS):
        - acme
        - sam
        - 9term
      
      Run them directly from your terminal.
      
      PLAN9 is automatically set to: #{prefix}
    EOS
  end

  test do
    assert_match "usage", shell_output("#{bin}/9 ls 2>&1", 1)
  end
end
