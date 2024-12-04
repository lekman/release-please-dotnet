# release-please-dotnet

This action is intended to be used together with the Google [`release-please-action`](https://github.com/marketplace/actions/release-please-action) for .NET-based releases, to automate versioning of NuGet packages.

## Overview

The [`release-please-action`](https://github.com/marketplace/actions/release-please-action) works in `simple` mode for .NET based releases. This updates only the `CHANGELOG.md` file, and does not update the version numbers in the `csproj` files.

This action can be run on push or during a pull request to set the `<Version>` element in the `csproj` files to the version number in the `.release-please-manifest.json` file.

## Pre-requisites

You should follow the instructions for  [`release-please-action`](https://github.com/marketplace/actions/release-please-action), and ensure that the repository is correctly bootstrapped for the release-please workflow.

- Bootstrap the repository with `.release-please-manifest.json` and `release-please-config.json` files.
- Add the `csproj` files to the `.release-please-manifest.json` file.

  ```json
  {
    "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
    "release-type": "simple",
    "packages": {
      "sample": {
        "package-name": "Lekman.ReleasePlease.DotNet.Sample"
      }
    }
  }
  ```

## Usage

```yaml
- name: Bump .NET package versions
  uses: lekman/release-please-dotnet@v1
  with:
    manifest: ".release-please-manifest.json"
    commit: false
```

### Inputs

- `manifest` - The path to the `.release-please-manifest.json` file. Default: `.release-please-manifest.json`
- `commit` - Commit the changes to the `csproj` files. Default: `false`. Use together with a push or PR workflow to set changes in the repository before merging.

Complete workflow example, with Nuget package publishing, and bumping versions during a push or PR.

```yaml
name: "CD: Release and Publish"

on:
  push:
    # Run on changes and let release-please create PRs and publish releases
    # Bump package versions as needed and publish packages to NuGet gallery
    branches:
      - main
    paths:
      - "**/*.cs"
      - "**/*.csproj"
      - "**/*.sln"
      - ".github/workflows/cd_release_please.yml"
      - ".release-please-manifest.json"
      - "release-please-config.json"

jobs:
  release:
    name: Release and Publish
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: "16"

      - uses: googleapis/release-please-action@v4
        id: release
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - uses: lekman/release-please-dotnet@v1

      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "9.0.x"

      - run: |
          dotnet publish -c Release
          dotnet nuget push **/*.nupkg \
            --source https://api.nuget.org/v3/index.json \
            --api-key ${{ secrets.NUGET_API_KEY }} \
            --skip-duplicate
