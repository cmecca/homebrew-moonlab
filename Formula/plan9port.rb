class Plan9port < Formula
  desc "Plan 9 from User Space - macOS native port by Moonlab"
  homepage "https://pkg.moonlab.org"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.zip"
  version "2025.12.06.0"
  sha256 "303cf10c600e35eb186070eb6ffd9cb90a99e1042c48d1ff0ee5079f3fa176dd"
  license "MIT"

  # Apple Silicon only
  depends_on arch: :arm64
  depends_on :macos

  # GUI applications that should only be accessed via: 9 <command>
  # This avoids namespace pollution and conflicts.
  GUI_APPS = %w[
    acme sam samterm 9term page
    clock colors graph plot
    hoc idiff img paint
  ].freeze

  # Standard Unix commands to skip (available via: 9 <command>)
  SKIP_COMMANDS = [
    # Core text/file utils
    "cat", "ls", "grep", "sed", "awk", "diff", "sort", "comm", "uniq",
    "tr", "cut", "paste", "join", "split", "head", "tail", "wc",
    "expand", "unexpand", "strings",

    # File/filesystem
    "mkdir", "rm", "mv", "cp", "ln", "chmod", "chown", "chgrp", "touch",
    "tar", "gzip", "gunzip", "bzip2", "bunzip2", "compress", "uncompress",
    "du", "df", "mount", "umount", "file",

    # Shell/proc/session
    "echo", "basename", "dirname", "pwd", "sleep", "test", "kill",
    "ps", "who", "whoami", "id",

    # Time
    "date", "cal", "uptime",

    # Networking
    "ping", "netstat", "ftp", "telnet",

    # Admin / sensitive
    "passwd", "shutdown", "reboot", "halt", "ssh-agent"
  ].freeze

  def install
    # 1. Build in the source tree
    system "./INSTALL", "-b"

    # 2. Install entire Plan 9 tree into prefix/plan9
    plan9_root = prefix/"plan9"
    plan9_root.install Dir["*"]

    # 3. Fix up internal paths for the final root
    cd plan9_root do
      system "./INSTALL", "-c", "-r", plan9_root.to_s
    end

    plan9_bin = plan9_root/"bin"

    # 4. Provide the main `9` launcher
    (bin/"9").write <<~EOS
      #!/bin/sh
      export PLAN9="#{plan9_root}"
      exec "#{plan9_bin}/9" "$@"
    EOS
    chmod 0o755, bin/"9"

    # 5. Provide wrappers for *selected* CLI tools to avoid PATH pollution
    Dir["#{plan9_bin}/*"].each do |cmd_path|
      next unless File.file?(cmd_path) && File.executable?(cmd_path)

      cmd = File.basename(cmd_path)

      # `9` itself is handled above
      next if cmd == "9"

      # Skip GUI apps (use via `9 <app>`)
      next if GUI_APPS.include?(cmd)

      # Skip conflicting / sensitive Unix commands
      next if SKIP_COMMANDS.include?(cmd)

      (bin/cmd).write <<~EOS
        #!/bin/sh
        export PLAN9="#{plan9_root}"
        exec "#{plan9_bin}/#{cmd}" "$@"
      EOS
      chmod 0o755, bin/cmd
    end
  end

  def caveats
    <<~EOS
      Plan 9 from User Space (Moonlab edition) installed.

      The full Plan 9 tree lives under:
        #{opt_prefix}/plan9

      Usage:

        GUI applications (via the 9 launcher):
          9 acme         # Acme text editor
          9 sam          # Sam text editor
          9 9term        # Plan 9 terminal
          9 page         # Document viewer

        Plan 9 versions of Unix-style tools (via 9):
          9 grep         # Plan 9 grep
          9 sed          # Plan 9 sed
          9 ls           # Plan 9 ls
          ...

        Selected Plan 9 CLI tools are available directly on PATH:
          rc, mk, plumber, fontsrv, and many others that do not
          conflict with core Unix utilities.

      Documentation:
        https://9fans.github.io/plan9port/
    EOS
  end

  test do
    # Basic: does the 9 launcher work & run a command?
    assert_match "Plan 9", shell_output("#{bin}/9 ls /")

    # And a direct CLI tool (non-GUI) via PATH
    system bin/"rc", "-c", "echo test"
  end
end

