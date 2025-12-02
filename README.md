# Moonlab Homebrew Tap

Opinionated, macOS packages maintained by Moonlab.

## Installation
```sh
brew tap cmecca/moonlab
```

## Available Packages

### `plan9port`

Plan 9 from User Space - native macOS port with CLI/GUI separation.
```sh
brew install plan9port
```

**Features:**
- Native Cocoa rendering (no X11)
- CLI tools available directly: `rc`, `mk`, `plumber`, `fontsrv`, etc.
- GUI apps via launcher: `9 acme`, `9 sam`, `9 9term`, etc.
- Zero conflicts with system packages
- No shell configuration required

Full Plan 9 environment accessible via `9 <cmd>` for grep, sed, ls, and other utilities.

## More
Visit [pkg.moonlab.org](https://pkg.moonlab.org) for documentation and additional Moonlab software.

## License
Individual packages maintain their upstream licenses.  See formula files for details.
