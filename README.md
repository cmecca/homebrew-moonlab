# Moonlab Homebrew Tap

Opinionated Homebrew formulae for Moonlab projects and tools.

This tap is currently focused on:
- macOS
- Apple Silicon (arm64)
- Native builds + bottled releases

---

## Installation

You can install directly from the tap without manually tapping:

```sh
brew install cmecca/moonlab/<formula>
```

Or tap once and install normally:

```sh
brew tap cmecca/moonlab
brew install <formula>
```

Or in a brew bundle (Brewfile):

```sh
tap "cmecca/moonlab"
brew "<formula>"
```

---

## Maintainer Workflow (How to Update or Add Formulae)

This section documents the end-to-end workflow for updating an existing formula
or adding a new one — including automatic bottle generation via GitHub Actions.

This isn't somethign we do everyday --- these steps are recorded for our benefit.

---

### 1. Create a feature branch

From the local tap checkout:

```sh
cd /opt/homebrew/Library/Taps/cmecca/homebrew-moonlab
git checkout -b my-change
```

---

### 2. Edit or add a formula

- Existing formula:
  Formula/<name>.rb

- New formula:
  Formula/<newname>.rb

No bottle do block is required at this stage — CI will add it later.

---

### 3. Test locally (important)

Always do at least:

```sh
brew uninstall <formula> 2>/dev/null || true
brew install --build-from-source cmecca/moonlab/<formula>
brew test cmecca/moonlab/<formula>
```

This confirms:
- The formula builds
- Installs correctly
- Passes its test block

---

### 4. Commit and push

```sh
git add Formula/<formula>.rb
git commit -m "<formula>: describe the change"
git push -u origin my-change
```

---

### 5. Open a Pull Request

Open a PR from your branch → main.

This automatically triggers:

- brew test-bot on:
  - Ubuntu
  - macOS Intel
  - macOS ARM
- Bottles will be built and uploaded as GitHub Actions artifacts.

You do not need to build bottles locally.

---

### 6. Download bottle artifacts

Once CI is green:

1. Go to the PR on GitHub.
2. Open the Checks tab.
3. For each OS job, download the artifact:

   bottles_<os>

4. Extract them locally — you will get files like:

   <formula>-<version>.arm64_sonoma.bottle.tar.gz

---

### 7. Create a GitHub Release

1. Go to Releases → New Release
2. Tag name should match the formula version, for example:

   plan9port-2025.12.06.0

3. Upload all the *.bottle.* files as Release assets
4. Publish the release.

---

### 8. Label the PR with pr-pull

Add the label:

pr-pull

This triggers the publish.yml workflow, which automatically:

- Runs brew pr-pull
- Downloads bottles from the Release
- Updates the bottle do block in the formula
- Pushes the changes to main
- Deletes the PR branch

At this point the formula is fully bottled and live.

---

## Adding Future Formulae

The exact same workflow applies:

1. Create Formula/<newformula>.rb
2. Test locally with brew install --build-from-source
3. Push + PR
4. CI builds bottles
5. Create a Release with the bottles
6. Label the PR with pr-pull

---

## Documentation

- `brew help`
- `man brew`
- Homebrew Docs: https://docs.brew.sh
