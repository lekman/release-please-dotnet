# release-please-dotnet

Release packaging GitHub composite action for Google [`release-please`](https://github.com/marketplace/actions/release-please-action) for .NET-based releases.

## Overview

This action is a composite action that extends the  [`release-please`](https://github.com/marketplace/actions/release-please-action) workflow for .NET-based releases. It is intended to be used in a GitHub workflow to automate the packaging of a release to a NuGet feed.

## Pre-requisites

You should follow the instructions for  [`release-please`](https://github.com/marketplace/actions/release-please-action), and ensure that the repository is correctly bootstrapped for the release-please workflow.

This action works with either a single solution or a mono-repo with multiple solutions. The action will automatically detect the solution files and update the version numbers in the `csproj` files.

Note that the action will not commit the version changes to the repository. You can automate this step by adding a commit step to the workflow after the NuGet packages have been published.

## Workflow

- Your existing GitHub workflow runs `release-please` to create a release PR.
- The PR is merged, and the state file `.release-please-manifest.json` is updated.
- The `release-please-dotnet` action is triggered by the release PR, and detects if a new version of a package is available.
- If a new version is available, the action will update the version numbers in the `csproj` files, build the NuGet packages, and push them to the NuGet feed.
- You can use either the GitHub package feed or the standard nuget.org feed.

## Usage

```yaml

name: Release
name: "Release Please"

on:
  workflow_dispatch:
  push:
    branches:
      - main
    paths:
      - "**/*.cs"
      - "**/*.cs*"
      - "**/*.sln"
      - ".release-please-manifest.json"
      - "release-please-config.json"

jobs:
  release:
    name: Release Please
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          lfs: true

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "16"

      - name: Run release-please
        if: github.ref == 'refs/heads/main'
        uses: googleapis/release-please-action@v4
        id: release
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "8.0.x"

      - name: Bump versions and publish
        uses: lekman/release-please-dotnet@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          nuget_api_key: ${{ secrets.GITHUB_TOKEN }}
        continue-on-error: false
```
