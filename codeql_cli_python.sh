#!/bin/bash

TOKEN=$1
HOME_PATH=./temp
CODEQL_RELEASE=v2.20.1

# Certify that your runner has unzip & build-essential
#sudo apt update
#sudo apt install build-essential

# Download CodeQL for Linux
wget https://github.com/github/codeql-action/releases/download/codeql-bundle-$CODEQL_RELEASE/codeql-bundle-linux64.tar.gz
mkdir -p $HOME_PATH/codeql-home
tar xvzf codeql-bundle-linux64.tar.gz -C $HOME_PATH/codeql-home

# Build and create CodeQL database
# build-mode:
# # none: The database will be created without building the source root. Available for C#, Java, JavaScript/TypeScript, Python, and Ruby.
# # autobuild: The database will be created by attempting to automatically build the source root. Available for C/C++, C#, Go, Java/Kotlin, and Swift.
# # manual: The database will be created by building the source root using a manually specified build command. Available for C/C++, C#, Go, Java/Kotlin, and Swift.
$HOME/codeql-home/codeql/codeql database create codeqldb --build-mode=none --overwrite --language=$lang

export CODEQL_SUITES_PATH=$HOME/codeql-home/codeql-repo/python/ql/src/codeql-suites
mkdir -p $HOME/codeql-result

# Analyze CodeQL database
# # Code Scanning suite: Queries run by default in CodeQL code scanning on GitHub.
# # Default: python-code-scanning.qls
# # Security extended suite: python-security-extended.qls
# # Security and quality suite: python-security-and-quality.qls
$HOME/codeql-home/codeql/codeql database analyze codeqldb \
--format=sarif-latest \
--output=$HOME/codeql-result/$lang-code-scanning.sarif \
--sarif-category=$lang

# Send SARIF to GitHub
$HOME/codeql-home/codeql/codeql github upload-results \
--repository=$GITHUB_REPOSITORY \
--ref=$GITHUB_REF \
--commit=$GITHUB_SHA \
--sarif=$HOME/codeql-result/$lang-code-scanning.sarif \
--github-auth-stdin=$TOKEN

# cat $HOME/codeql-result/$lang-code-scanning.sarif
