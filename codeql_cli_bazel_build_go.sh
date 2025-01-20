#!/bin/bash

TOKEN=$1
HOME_PATH=./temp
CODEQL_RELEASE=v2.20.1
BAZEL_RELEASE=v1.25.0

# Certify that your runner has unzip & build-essential
#sudo apt update
#sudo apt install build-essential

# Download Bazel - You may need to use sudo to run the following steps depending on your runner configuration
wget -q https://github.com/bazelbuild/bazelisk/releases/download/$BAZEL_RELEASE/bazelisk-linux-amd64
sudo chmod +x bazelisk-linux-amd64
sudo mv bazelisk-linux-amd64 /usr/local/bin/bazel
which bazel

# Download CodeQL for Linux
wget -q https://github.com/github/codeql-action/releases/download/codeql-bundle-$CODEQL_RELEASE/codeql-bundle-linux64.tar.gz
mkdir -p $HOME_PATH/codeql-home
tar xzf codeql-bundle-linux64.tar.gz -C $HOME_PATH/codeql-home

# Before building, remove cached objects and stop all running Bazel server processes
bazel clean --expunge

# Build and create CodeQL database
$HOME_PATH/codeql-home/codeql/codeql database create codeqldb --overwrite --language=go \
--command='bazel build //projects/go_web --spawn_strategy=local --nouse_action_cache --noremote_accept_cached --noremote_upload_local_results --disk_cache= --remote_cache='

#https://github.com/github/codeql/issues/17458
#for Go, we do not support builds with Bazel. 
#That is because Bazel does not use the ordinary Go build tooling (i.e. go build) under the hood when building Go applications. 
#Unfortunately it is not straightforward to add support for the way that Bazel builds Go projects.
#We monitor how much demand there is for this and may look into adding support in the future, but we do not currently have any plans to work on this.
#reported by Michael B. Gale - https://github.com/mbg

export CODEQL_SUITES_PATH=$HOME_PATH/codeql-home/codeql-repo/go/ql/src/codeql-suites
mkdir -p $HOME_PATH/codeql-result

# # Code Scanning suite: Queries run by default in CodeQL code scanning on GitHub.
# # Default: go-code-scanning.qls
# # Security extended suite: go-security-extended.qls
# # Security and quality suite: go-security-and-quality.qls
$HOME_PATH/codeql-home/codeql/codeql database analyze codeqldb \
--format=sarif-latest \
--output=$HOME_PATH/codeql-result/go-code-scanning.sarif

# Send SARIF to GitHub
$HOME_PATH/codeql-home/codeql/codeql github upload-results \
--repository=$GITHUB_REPOSITORY \
--ref=$GITHUB_REF \
--commit=$GITHUB_SHA \
--sarif=$HOME_PATH/codeql-result/go-code-scanning.sarif \
--github-auth-stdin=$TOKEN

# cat $HOME_PATH/codeql-result/go-code-scanning.sarif

# After building, stop all running Bazel server processes. This ensures future build commands start in a clean Bazel server process without CodeQL attached.
bazel shutdown

