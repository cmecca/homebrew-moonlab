# Moonlab Homebrew Tap

Opinionated, macOS packages maintained by Moonlab.

## Installation
```sh
brew tap cmecca/moonlab
```

## Available Packages

<details>
<summary>
<strong><code>plan9port</code></strong> — Plan 9 from User Space for macOS  
<br/>
<img src="https://img.shields.io/badge/macOS-Sonoma%20%7C%20Tahoe-000000?style=flat-square&logo=apple" />
<img src="https://img.shields.io/badge/arch-arm64-4c1?style=flat-square" />
</summary>

Plan 9 from User Space — native macOS port with CLI/GUI separation.

### Install
```sh
brew install plan9port
```

### Features
- Native Cocoa rendering (no X11)
- CLI tools available directly: `rc`, `mk`, `plumber`, `fontsrv`, etc.
- GUI apps via launcher: `9 acme`, `9 sam`, `9 9term`, etc.
- Zero conflicts with system packages
- No shell configuration required

### Usage
Run the full Plan 9 userland through the `9` shim:

```sh
9 <cmd>
```

Examples:
- `9 ls`
- `9 grep`
- `9 sed`

### Platform Support
- macOS Sonoma (14)
- macOS Tahoe (15)
- Apple Silicon (arm64)
- Intel Mac's not supported

</details>

## More
Visit [pkg.moonlab.org](https://pkg.moonlab.org) for documentation and additional Moonlab software.

## License
Individual packages maintain their upstream licenses. See formula files for details.

