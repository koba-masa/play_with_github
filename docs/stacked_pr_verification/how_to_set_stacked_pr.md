# Stacked Pull Request(2)

## Stacked PRの設定方法

### GitHub CLIを使用する場合
※CLIで指定するには、[サブコマンドのstack](https://docs.github.com/ja/pull-requests/reference/stacked-prs-cli-commands)をインストールする必要がある

1. 1層目のブランチを指定する
    ```sh
    gh stack init 
    ```
    or
    ```sh
    gh stack init {first_branch_name}
    ```
    - ベースブランチをデフォルトブランチ以外にしたい場合
        ```sh
        gh stack init --base {base_branch_name} {first_branch_name}
        ```

2. ローカルのスタックをGitHub上に同期する
    ```sh
    gh stack submit
    ```
    ![gh stack submit](/docs/stacked_pr_verification/images/gh_stack_submit_single_branch.png)
    - 2層目のブランチが存在しない状態では、1層目のブランチのPRには、スタックの情報は表示されない

3. スタックを追加する
    ```sh
    gh stack add {second_branch_name}
    ```
    ```sh
    gh stack add {third_branch_name}
    ```

4. ローカルのスタックをGitHub上に同期する
    ```sh
    gh stack submit
    ```
    ![gh stack submit](/docs/stacked_pr_verification/images/gh_stack_submit_three_branches.png)
    ![stack status on pr](/docs/stacked_pr_verification/images/stack_status_on_pr.png)
    - PRが作成されていない場合、PRを作成するためのウィザードが開きます
        ![pr creation wizard](/docs/stacked_pr_verification/images/pr_creation_wizard.png)

#### 1〜4の作業をまとめて行う
```sh
gh stack init --base {base_branch_name} {first_branch_name} {second_branch_name} {third_branch_name}

gh stack submit
```

#### スタックの状態を確認する
```sh
gh stack view
```

![stack status](/docs/stacked_pr_verification/images/stack_status.png)

### スタックを解除する

```sh
gh stack unstack {stack_number}
```

#### サブコマンド`stack`のインストール

```sh
gh extension install github/gh-stack
```

### GitHubのサイト上から設定する方法

![stack on web site](/docs/stacked_pr_verification/images/web_can_be_stacked_banner.png)
![stack on web site](/docs/stacked_pr_verification/images/web_preview_stack_dialog.png)
![stack on web site](/docs/stacked_pr_verification/images/web_stack_created_banner.png)
