#!/bin/bash

sudo apt update > /dev/null 2>&1
sudo apt install build-essential > /dev/null 2>&1
sudo apt install unzip > /dev/null 2>&1

wget https://github.com/bazelbuild/bazelisk/releases/download/v1.25.0/bazelisk-linux-amd64
sudo chmod +x bazelisk-linux-amd64
sudo mv bazelisk-linux-amd64 /usr/local/bin/bazel
sudo which bazel

# Download CodeQL for Linux with cURL
wget https://github.com/github/codeql-cli-binaries/releases/download/v2.20.1/codeql-linux64.zip
sudo mkdir $HOME/codeql-home
sudo unzip codeql-linux64.zip -d $HOME/codeql-home

# Download queries and add them to the CodeQL home folder
cd $HOME/codeql-home
sudo git clone --recursive https://github.com/github/codeql.git codeql-repo

# Add the CodeQL home folder to the PATH
export PATH=$PATH:$HOME/codeql-home/codeql

# Check the configuration
codeql resolve languages
codeql resolve qlpacks

# Build and create CodeQL database
codeql database create codeqldb --language=python \
--command='bazel build --spawn_strategy=local --nouse_action_cache --noremote_accept_cached --noremote_upload_local_results'

#bazel build //...
#bazel test //...

export CODEQL_SUITES_PATH=$HOME/codeql-home/codeql-repo/python/ql/src/codeql-suites
export RESULTS_FOLDER=$HOME/codeql-results
sudo mkdir -p $RESULTS_FOLDER

# Code Scanning suite: Queries run by default in CodeQL code scanning on GitHub.
# Security extended suite: python-security-extended.qls
# Security and quality suite: python-security-and-quality.qls
sudo codeql database analyze codeqldb $CODEQL_SUITES_PATH/python-code-scanning.qls \
--format=sarif-latest \
--output=$RESULTS_FOLDER/python-code-scanning.sarif

cat $RESULTS_FOLDER/python-code-scanning.sarif | jq '.["$schema"] = "http://json.schemastore.org/sarif-2.1.0-rtm.1"' > $RESULTS_FOLDER/python-code-scanning-fixed-schema.sarif

sudo codeql github upload-results \
--repository=$GITHUB_REPOSITORY \ 
--ref=$GITHUB_REF \  
--commit=$GITHUB_SHA \
--sarif=/temp/example-repo-java.sarif \
--github-auth-stdin'

bazel clean --expunge
bazel shutdown

