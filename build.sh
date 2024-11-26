#!/bin/bash

# Declare a local variable path_dir which is the full folder name of the incoming path
path="$1"
path_dir="$path"
if [ -f "$path_dir" ]; then
  path_dir=$(dirname "$path_dir")
fi
echo "Path directory: $path_dir"
cd "$path_dir" || exit

# Function to get the organization owner using GitHub CLI
get_org_owner() {
  local org_owner=$(gh repo view --json owner -q .owner.login)
  echo "$org_owner"
}

dotnet restore
dotnet build