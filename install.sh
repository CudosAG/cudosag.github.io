#!/usr/bin/env bash
# Installer shortcut for private CudosAG repositories.
#
#   curl -fsSL https://cudosag.github.io/install.sh | bash -s <repository>
#
# This file knows no project. It signs in through the GitHub CLI, fetches get.sh from the
# private repository CudosAG/<repository> with your own GitHub account and runs it, so you
# need access to that repository.
set -euo pipefail

die() { echo "install: $*" >&2; exit 1; }

repo="${1:-}"
[[ "$repo" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] \
  || die "usage: curl -fsSL https://cudosag.github.io/install.sh | bash -s <repository>"

command -v gh >/dev/null 2>&1 || die "the GitHub CLI is required: https://cli.github.com"
gh auth status >/dev/null 2>&1 || die "not signed in; run: gh auth login"

# Lets git clone private repositories with the same sign-in.
gh auth setup-git

script="$(gh api "repos/CudosAG/$repo/contents/get.sh" -H 'Accept: application/vnd.github.raw')" \
  || die "cannot read get.sh from CudosAG/$repo (no such file or no access)"

printf '%s\n' "$script" | bash
