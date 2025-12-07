class Plan9port < Formula
  desc "Plan 9 from User Space - macOS native port by Moonlab"
  homepage "https://pkg.moonlab.org"
  url "https://github.com/9fans/plan9port/archive/refs/heads/master.zip"
  version "2025.12.06.0"
  sha256 "303cf10c600e35eb186070eb6ffd9cb90a99e1042c48d1ff0ee5079f3fa176dd"
  license "MIT"

  # macos/arm64 only
  depends_on arch: :arm64
  depends_on :macos

  # avoid namspace conflicts for GUI apps
  # access via: `9 <cmd>`
  GUI_APPS = %w[
    acme sam samterm 9term page
    clock colors graph plot
    hoc idiff img paint
  ].freeze

  # skip std Unix commands (still avail via `9 <cmd>`)
  SKIP_COMMANDS = [
    # core file utils
    "cat", "ls", "grep", "sed", "awk", "diff", "sort", "comm", "uniq",
    "tr", "cut", "paste", "join", "split", "head", "tail", "wc",
    "expand", "unexpand", "strings",

    # filesystem
    "mkdir", "rm", "mv", "cp", "ln", "chmod", "chown", "chgrp", "touch",
    "tar", "gzip", "gunzip", "bzip2", "bunzip2", "compress", "uncompress",
    "du", "df", "mount", "umount", "file",

    # shell/proc
    "echo", "basename", "dirname", "pwd", "sleep", "test", "kill",
    "ps", "who", "whoami", "id",

    # time/util
    "date", "cal", "uptime",

    # network
    "ping", "netstat", "ftp", "telnet",

    # admin
    "passwd", "shutdown", "reboot", "halt", "ssh-agent"
  ].freeze

  def install
    system "./INSTALL", "-b"

    plan9_root = prefix/"plan9"
    plan9_root.install Dir["*"]

    cd plan9_root do
      system "./INSTALL", "-c", "-r", plan9_root.to_s
    end

    plan9_bin = plan9_root/"bin"

    (bin/"9").write <<~EOS
      #!/bin/sh
      export PLAN9="#{plan9_root}"
      exec "#{plan9_bin}/9" "$@"
    EOS
    chmod 0o755, bin/"9"

    Dir["#{plan9_bin}/*"].each do |cmd_path|
      next unless File.file?(cmd_path) && File.executable?(cmd_path)

      cmd = File.basename(cmd_path)

      next if cmd == "9"

      next if GUI_APPS.include?(cmd)
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
    assert_match "Plan 9", shell_output("#{bin}/9 ls /")

    system bin/"rc", "-c", "echo test"
  end
end

