#!/bin/bash

path="$1"
root_simple=false

# Function to check if a node has a "release-type" property set to "simple"
is_simple_release() {
  local node="$1"
  jq -e '.["release-type"] == "simple"' <<< "$node" > /dev/null 2>&1
}

# Function to check if a node has no "release-type" property or set to "simple"
# If the "release-type" property is not set, it should return the root_simple variable
is_simple_or_no_release() {
  local node="$1"
  if jq -e '.["release-type"] == null' <<< "$node" > /dev/null 2>&1; then
    echo "$root_simple"
  else
    is_simple_release "$node"
  fi
}

# Read the release-please-config.json file
config=$(cat "$path")

# Check if there are no "packages" node
if ! jq -e '.packages' <<< "$config" > /dev/null 2>&1; then
  # This is not a monorepo
  echo '["."]'
  exit 0
fi

# Initialize an array to hold the paths
paths=()

# Check the root level "release-type" property
if is_simple_release "$config"; then
  root_simple=true
fi

# Iterate over each package
packages=$(jq -c '.packages | to_entries[]' <<< "$config")
while IFS= read -r package; do
  package_path=$(jq -r '.key' <<< "$package")
  package_config=$(jq -r '.value' <<< "$package")

  # Check if the package has a "release-type" property set to "simple"
  if is_simple_or_no_release "$package_config" > /dev/null; then
    paths+=("$package_path")
  fi
done <<< "$packages"

# Output the paths as a JSON array
jq -n --argjson paths "$(printf '%s\n' "${paths[@]}" | jq -R . | jq -s . | tr -d '\t\n')" '$paths'
