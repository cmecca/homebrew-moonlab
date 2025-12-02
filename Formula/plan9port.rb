class Plan9port < Formula
  desc "Plan 9 from User Space - macOS/arm64 native port by Moonlab"
  homepage "https://moonlab.org"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  version "0.1.0"
  sha256 "814a1aa814d49b6e1a64a3ade3f5ada1496338c30e977ebe8c60cd2e84e3ef06"
  license "LPL-1.02"

  depends_on :macos
  depends_on arch: :arm64

  def install
    ENV["PLAN9"] = prefix
    
    system "./INSTALL", "-b"
    
    # Install everything
    prefix.install Dir["*"]
    
    # Rename the bin directory to lib
    (prefix/"lib").mkpath
    mv prefix/"bin", prefix/"lib/bin"
    
    # Create new bin with wrappers
    bin.mkpath
    
    (bin/"9").write <<~EOS
      #!/bin/bash
      export PLAN9=#{prefix}
      exec #{prefix}/lib/bin/9 "$@"
    EOS
    
    %w[acme sam 9term].each do |app|
      (bin/app).write <<~EOS
        #!/bin/bash
        export PLAN9=#{prefix}
        exec #{prefix}/lib/bin/#{app} "$@"
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
      
      For full Plan9 environment, use: 9 <command>
      Example: 9 ls
      
      PLAN9 is automatically set to: #{prefix}
    EOS
  end

  test do
    system bin/"9", "true"
  end
end
