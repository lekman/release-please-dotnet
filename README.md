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
    "include-component-in-tag": true,
    "include-v-in-tag": true,
    "tag-separator": "@",
    "separate-pull-requests": true,
    "release-type": "simple",
    "prerelease": true,
    "bump-patch-for-minor-pre-major": true,
    "packages": {
      "sample": {
      "package-name": "Lekman.ReleasePlease.DotNet.Sample"
      }
    }
  }
  ```

## Usage

Simple usage:

```yaml
- name: Bump .NET package versions
  uses: lekman/release-please-dotnet@v1
  with:
    manifest: ".release-please-manifest.json"
    branch: ${{ github.head_ref }}
```

Complete workflow example, with Nuget package publishing, and bumping versions during a push or PR.

```yaml
name: "CD: Release and Publish"

on:
  workflow_dispatch:
  push:
    # Run on changes and let release-please create
    # PRs for version bumps and new releases
    paths:
      - "**/*.cs"
      - "**/*.csproj"
      - "**/*.sln"
      - ".github/workflows/cd_release_please.yml"
      - ".release-please-manifest.json"
      - "release-please-config.json"

jobs:
  release-please:
    name: Release Please
    # Only run on main, after merge is completed
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "16"

      - name: Run release-please
        uses: googleapis/release-please-action@v4
        id: release
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

  bump-versions:
    name: Set Version
    if: github.ref != 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Bump .NET package versions
        uses: lekman/release-please-dotnet@v1
        with:
          manifest: ".release-please-manifest.json"
          branch: ${{ github.head_ref }}

  publish:
    name: Publish
    # Only run on main, after merge is completed
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "9.0.x"

      - name: Restore dependencies
        run: dotnet restore

      - name: Build
        run: dotnet build

      - name: Publish
        run: dotnet publish -c Release

      - name: Publish to Nuget
        run: dotnet nuget push **/*.nupkg --source https://api.nuget.org/v3/index.json --api-key ${{ secrets.NUGET_API_KEY }} --skip-duplicate
```
