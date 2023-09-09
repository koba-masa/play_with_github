# ローカル環境でGitHub Actionsの動作検証を行う

- https://github.com/nektos/act

## 仕組み


## 環境構築
1. [`nektos/act`](https://github.com/nektos/act#installation)をインストールする
   ```sh
   brew install act
   ```

2. 検証したいGitHubActionsがあるリポジトリの直下に移動する
   ```sh
   ls -la .github/workflows
   ```
   ```
   total 8
   drwxr-xr-x  3 koba-masa  staff   96  8 28 12:48 .
   drwxr-xr-x  3 koba-masa  staff   96  8 28 12:48 ..
   -rw-r--r--  1 koba-masa  staff  546  8 28 12:48 workflow_dispatch.yml
   ```
