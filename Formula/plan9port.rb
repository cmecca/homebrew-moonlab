class Plan9port < Formula
  desc "Plan 9 from User Space - macOS native port by Moonlab"
  homepage "https://moonlab.org"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  sha256 "814a1aa814d49b6e1a64a3ade3f5ada1496338c30e977ebe8c60cd2e84e3ef06"
  version "0.1.0"
  license "LPL-1.02"
  
  depends_on :macos
  depends_on arch: :arm64

  # Commands to skip - either conflict with system packages or are standard Unix tools
  # All these are still available via: 9 <command>
  SKIP_COMMANDS = %w[
    ssh-agent
    cat ls grep sed awk diff sort comm date cal bc dc
    echo basename dirname pwd sleep test kill
    rm mv cp mkdir ln chmod touch
    tar gzip gunzip bzip2 bunzip2 compress uncompress
    tr cut paste join split uniq
    head tail wc expand unexpand
    file du df mount
    ps
  ].freeze

  def install
    ENV["PLAN9"] = prefix
    
    system "./INSTALL", "-b"
    
    mv "bin", "plan9bin"
    
    prefix.install Dir["*"]
    
    # Create wrappers only for Plan9-specific tools and GUI apps
    Dir["#{prefix}/plan9bin/*"].each do |cmd|
      next unless File.file?(cmd) && File.executable?(cmd)
      
      app_name = File.basename(cmd)
      
      # Skip commands that conflict or are standard Unix tools
      next if SKIP_COMMANDS.include?(app_name)
      
      (bin/app_name).write <<~EOS
        #!/bin/bash
        export PLAN9=#{prefix}
        exec #{prefix}/plan9bin/#{app_name} "$@"
      EOS
      
      chmod 0755, bin/app_name
    end
    
    # Remove conflicting headers
    rm_f prefix/"include/event.h"
  end

  def caveats
    <<~EOS
      Plan 9 from User Space installed successfully!
      
      GUI applications:
        acme, sam, 9term, page
      
      Plan 9 shell and tools:
        rc, mk, 9
      
      All Plan 9 commands available via: 9 <command>
      Example: 9 ls, 9 grep, 9 sed
      
      No shell configuration needed.
    EOS
  end

  test do
    system bin/"9", "true"
  end
end
