#!/bin/bash

path="$1"
path_dir="$path"
if [ -f "$path_dir" ]; then
  path_dir=$(dirname "$path_dir")
fi
cd "$path_dir" || exit

# Function to get the package target from the csproj file
get_target_from_csproj() {
  local csproj_file="$1"
  local target=$(xmllint --xpath "string(//Project/PropertyGroup/RepositoryType)" "$csproj_file")

  # return the target if found, if not return "nuget"
  if [[ -z "$target" ]]; then
    echo "nuget"
  else
    echo "$target"
  fi
}

# Function to get the repository URL from the csproj file
get_repository_url_from_csproj() {
  local csproj_file="$1"
  local xpath="//Project/PropertyGroup/RepositoryUrl"

  # Check if the file exists
  if [[ ! -f "$csproj_file" ]]; then
    echo "Error: File '$csproj_file' does not exist."
    exit 1
  fi

  # Extract the repository URL
  local repository_url
  repository_url=$(xmlstarlet sel -t -v "$xpath" "$csproj_file" 2>/dev/null)

  # Check if the XPath was found
  if [[ -z "$repository_url" ]]; then
    echo "Error: XPath '$xpath' not found in file '$csproj_file'."
    exit 1
  fi

  echo "$repository_url"
}

# Function to extract owner and repo from the repository URL
extract_owner_and_repo() {
  local repo_url=$1
  local owner=$(echo "$repo_url" | awk -F'/' '{print $(NF-1)}')
  local repo=$(echo "$repo_url" | awk -F'/' '{print $NF}' | sed 's/.git$//')
  echo "$owner $repo"
}

## Function to check if a specific version of a package is already deployed using GitHub CLI
# is_package_version_deployed() {
#   local owner=$1
#   local repo=$2
#   local package_name=$3
#   local package_version=$4
#   local token=$5

#   # NOTE: Fix this
#   local target="user"
#   if [[ $(echo "$owner" | tr '[:upper:]' '[:lower:]') == *"ikea"* ]]; then
#     target="orgs/${owner}"
#   fi

#   # Get the list of package versions using GitHub CLI
#   local versions=$(gh api --paginate "/${target}/packages/nuget/${package_name}/versions" -q '.[] | .name' | sort -V)
#   for version in $versions; do
#     if [[ "$version" == "$package_version" ]]; then
#       return 0
#     fi
#   done

#   return 1
# }

# Locate project specific variables
project=$(find . -name '*.csproj' -print -quit)
target=$(get_target_from_csproj "$project")
repo_url=$(get_repository_url_from_csproj "$project")

# Check if this is a 'git' target
if [[ "$target" == "git" ]]; then
    echo $repo_url
fi


# repo_url=$(get_repository_url_from_csproj "$project")

# # Only proceed if the repository URL is found
# if [[ -z "$repo_url" ]]; then
#   echo "Error: Repository URL not found in the project file."
#   exit 1
# fi

# Extract owner and repo from the repository URL
#read owner repo <<< $(extract_owner_and_repo "$repo_url")
# Check if the package version is already deployed
# if is_package_version_deployed "$owner" "$repo" "$package_id" "$new_version" "$GITHUB_TOKEN"; then
#     echo "Skipping build and deployment for $package_id version $new_version."
#     continue
# fi