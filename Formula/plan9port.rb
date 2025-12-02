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
    # Set PLAN9 to the installation prefix
    ENV["PLAN9"] = prefix
    
    # Run the Plan9 install script
    system "./INSTALL", "-b"
    
    # Rename bin to plan9bin to avoid conflicts when creating wrappers
    mv "bin", "plan9bin"
    
    # Install everything to the prefix
    prefix.install Dir["*"]
    
    # Create wrapper scripts for ALL executables
    # These wrappers automatically set PLAN9 before running the real binary
    Dir["#{prefix}/plan9bin/*"].each do |cmd|
      next unless File.file?(cmd) && File.executable?(cmd)
      
      app_name = File.basename(cmd)
      
      (bin/app_name).write <<~EOS
        #!/bin/bash
        export PLAN9=#{prefix}
        exec #{prefix}/plan9bin/#{app_name} "$@"
      EOS
      
      chmod 0755, bin/app_name
    end
  end

  def caveats
    <<~EOS
      Plan 9 from User Space

      <https://github.com/9fans/plan9port>

      For the full Plan 9 environment, use: 9 <command>
      Example: 9 ls

      PLAN9 is automatically set to: #{prefix}
    EOS
  end

  test do
    # Test that the wrapper works
    system bin/"9", "true"
  end
end
