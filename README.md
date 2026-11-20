# cudosag.github.io

One public install shortcut for private CudosAG repositories:

```sh
curl -fsSL https://cudosag.github.io/install.sh | bash -s <repository>
```

`install.sh` only calls the GitHub CLI. It fetches `get.sh` from `CudosAG/<repository>` with your
own GitHub sign-in and runs it. It contains no project names and no code of any tool.
