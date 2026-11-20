# cudosag.github.io

One public install shortcut for private CudosAG repositories:

```sh
curl -fsSL https://cudosag.github.io/install.sh | bash -s <repository> [branch]
```

`install.sh` only calls the GitHub CLI. It fetches `get.sh` from `CudosAG/<repository>` (default
branch, or the branch you name, which is passed on to `get.sh` as `INSTALL_REF`) with your own
GitHub sign-in and runs it. It contains no project names and no code of any tool.

It stops with a clear message when `gh` is missing, not signed in, the repository is not found or
not readable, the branch does not exist or the repository has no `get.sh`.
