#!/bin/bash

# Function to install xmlstarlet
install_xmlstarlet() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y xmlstarlet
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install xmlstarlet
  else
    echo "::error Unsupported OS type: $OSTYPE" >> $GITHUB_STEP_SUMMARY
    exit 1
  fi
}

# Function to install xmllint
install_xmllint() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y libxml2-utils
  fi
}

# Check if xmlstarlet is installed, if not, install it
if ! command -v xmlstarlet &> /dev/null
then
    echo "xmlstarlet could not be found, installing..."
    install_xmlstarlet
fi

# Check if xmllint is installed, if not, install it
if ! command -v xmllint &> /dev/null
then
    echo "xmllint could not be found, installing..."
    install_xmllint
fi

# Check if gpr tool is installed, if not, install it
if ! command -v gpr &> /dev/null
then
    echo "gpr tool could not be found, installing..."
    dotnet tool install --global --verbosity minimal --no-cache gpr
fi