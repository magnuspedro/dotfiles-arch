#!/usr/bin/env bash
# DESC: Identidade global do git (nome e email)
set -euo pipefail

git config --global user.name "Magnus"
git config --global user.email "pedmagnus@gmail.com"
git config --global init.defaultBranch main

echo "git: $(git config --global user.name) <$(git config --global user.email)>"
