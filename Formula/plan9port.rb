class Plan9port < Formula
  desc "Plan 9 from User Space - macOS native port by Moonlab"
  homepage "https://pkg.moonlab.org"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.tar.gz"
  sha256 "814a1aa814d49b6e1a64a3ade3f5ada1496338c30e977ebe8c60cd2e84e3ef06"
  version "2025.12.01"
  license "LPL-1.02"
  
  depends_on :macos
  depends_on arch: :arm64

  bottle do
    root_url "https://github.com/cmecca/homebrew-moonlab/releases/download/bottles"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "0a42f7a8d03dd45988237e57e0305318b5447f36dbd203eb078abb0f2962e67a"
  end

  # GUI applications that should only be accessed via: 9 <command>
  # This avoids namespace pollution and conflicts
  GUI_APPS = %w[
    acme sam samterm 9term page
    clock colors graph plot
    hoc idiff img paint
  ].freeze

  # Standard Unix commands to skip (available via: 9 <command>)
  SKIP_COMMANDS = %w[
    ssh-agent
    cat ls grep sed awk diff sort comm date cal bc dc
    echo basename dirname pwd sleep test kill
    rm mv cp mkdir ln chmod touch
    tar gzip gunzip bzip2 bunzip2 compress uncompress
    tr cut paste join split uniq
    head tail wc expand unexpand
    file du df mount ps
  ].freeze

  def install
    ENV["PLAN9"] = prefix
    
    system "./INSTALL", "-b"
    
    mv "bin", "plan9bin"
    prefix.install Dir["*"]
    
    # Create wrappers for all commands EXCEPT GUI apps and system conflicts
    Dir["#{prefix}/plan9bin/*"].each do |cmd|
      next unless File.file?(cmd) && File.executable?(cmd)
      
      app_name = File.basename(cmd)
      
      # Skip GUI apps (use via '9 <app>')
      next if GUI_APPS.include?(app_name)
      
      # Skip conflicting Unix commands
      next if SKIP_COMMANDS.include?(app_name)
      
      # Create wrapper for CLI tools
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

      This is an opinionated package from Moonlab that avoids
      conflict with existing Unix and popular third-party tooling.

      CLI tools (available directly):
        rc             Plan 9 shell
        mk             Plan 9 build tool
        plumber        Plumber daemon
        fontsrv        Font server
        And 100+ other Plan 9 utilities...

      GUI applications (use via '9' launcher):
        9 acme         Launch the Acme text editor
        9 sam          Launch the Sam text editor  
        9 9term        Launch a Plan9 terminal
        9 page         Launch the Page document viewer

      Plan 9 implementations of Unix tools (use via '9' launcher):
        9 grep         Plan 9's grep
        9 sed          Plan 9's sed
        9 ls           Plan 9's ls

      Documentation: https://9fans.github.io/plan9port/
    EOS
  end

  test do
    # Test that CLI tools work directly
    system bin/"rc", "-c", "echo test"
    
    # Test that GUI apps work via 9 launcher
    system "#{prefix}/plan9bin/9", "true"
  end
end
