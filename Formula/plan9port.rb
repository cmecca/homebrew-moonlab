class Plan9port < Formula
  desc "Plan 9 from User Space - macOS native port by Moonlab"
  homepage "https://moonlab.org"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  sha256 "814a1aa814d49b6e1a64a3ade3f5ada1496338c30e977ebe8c60cd2e84e3ef06"
  version "0.1.0"
  license "LPL-1.02"

  depends_on :macos
  depends_on arch: :arm64

  def install
    ENV["PLAN9"] = prefix
    
    system "./INSTALL", "-b"
    
    # Move bin to plan9bin to avoid conflicts
    mv "bin", "plan9bin"
    
    # Install everything to prefix
    prefix.install Dir["*"]
    
    # Create wrapper scripts in the Homebrew bin
    (bin/"9").write <<~EOS
      #!/bin/bash
      export PLAN9=#{prefix}
      exec #{prefix}/plan9bin/9 "$@"
    EOS
    chmod 0755, bin/"9"
    
    %w[acme sam 9term].each do |app|
      (bin/app).write <<~EOS
        #!/bin/bash
        export PLAN9=#{prefix}
        exec #{prefix}/plan9bin/#{app} "$@"
      EOS
      chmod 0755, bin/app
    end
  end

  def caveats
    <<~EOS
      Plan9port GUI applications installed (native macOS):
        - acme
        - sam  
        - 9term
      
      Run them directly from your terminal.
      
      For full Plan9 environment, use: 9 <command>
      Example: 9 ls
      
      PLAN9 is automatically set to: #{prefix}
    EOS
  end

  test do
    system bin/"9", "true"
  end
end
