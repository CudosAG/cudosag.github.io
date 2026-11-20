#!/usr/bin/env bash
# Installer shortcut for private CudosAG repositories.
#
#   curl -fsSL https://cudosag.github.io/install.sh | bash -s <repository> [branch]
#
# This file knows no project. It signs in through the GitHub CLI, fetches get.sh from the
# private repository CudosAG/<repository> (default branch, or the branch you name) with your
# own GitHub account and runs it, so you need access to that repository. The branch is passed on
# to get.sh as INSTALL_REF.
set -euo pipefail

owner="CudosAG"
usage="usage: curl -fsSL https://cudosag.github.io/install.sh | bash -s <repository> [branch]"

die() { echo "install: $*" >&2; exit 1; }

(( $# >= 1 && $# <= 2 )) || die "$usage"
repo="$1"
ref="${2:-}"

[[ "$repo" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "invalid repository name '$repo'. $usage"
if [[ -n "$ref" ]]; then
  [[ "$ref" =~ ^[A-Za-z0-9][A-Za-z0-9._/-]*$ && "$ref" != *..* ]] || die "invalid branch name '$ref'"
fi

# 1. GitHub CLI installed
command -v gh >/dev/null 2>&1 || die "the GitHub CLI (gh) is not installed: https://cli.github.com"

# 2. GitHub CLI signed in
gh auth status --hostname github.com >/dev/null 2>&1 \
  || die "gh is not signed in to github.com; run: gh auth login"
login="$(gh api user --jq .login 2>/dev/null || true)"
login="${login:-unknown}"

# 3. Repository exists and this account can read it
if ! default_branch="$(gh api "repos/$owner/$repo" --jq .default_branch 2>&1)"; then
  case "$default_branch" in
    *"HTTP 404"*) die "repository $owner/$repo not found, or the account '$login' has no access to it (private repositories need the 'repo' scope: gh auth refresh -s repo)" ;;
    *"HTTP 401"*) die "GitHub rejected the sign-in; run: gh auth login" ;;
    *"HTTP 403"*) die "access to $owner/$repo denied for '$login' (SAML single sign-on? authorize the token for $owner). GitHub says: $default_branch" ;;
    *) die "cannot reach GitHub: $default_branch" ;;
  esac
fi

# 4. Branch exists
target="${ref:-$default_branch}"
if [[ -n "$ref" ]] && ! gh api "repos/$owner/$repo/branches/$ref" >/dev/null 2>&1; then
  die "branch '$ref' not found in $owner/$repo"
fi

# 5. Repository offers get.sh on that branch
if ! script="$(gh api -X GET "repos/$owner/$repo/contents/get.sh" -f ref="$target" -H 'Accept: application/vnd.github.raw' 2>&1)"; then
  case "$script" in
    *"HTTP 404"*) die "$owner/$repo has no get.sh on branch '$target'; it does not offer this installer (yet)" ;;
    *) die "cannot read get.sh from $owner/$repo: $script" ;;
  esac
fi
[[ -n "$script" ]] || die "get.sh in $owner/$repo ($target) is empty"

# Lets git clone private repositories with the same sign-in.
gh auth setup-git

echo "Installing $owner/$repo ($target) as $login"
printf '%s\n' "$script" | INSTALL_REF="$ref" bash
