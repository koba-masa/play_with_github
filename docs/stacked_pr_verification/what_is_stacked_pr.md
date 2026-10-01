# Stacked Pull Request(1)

## Stacked Pull Request is 何？

> スタックは、同じリポジトリ内の一連のプル要求です。各プル要求は、その下のプル要求のブランチを対象とし、1 つのブランチ (通常はメイン ブランチ) に配置される順序付きチェーンを形成します。

- 複数の一連のPull Request(以下、PR)を仕組みとして一連のものとして扱う

> 1 つの大きなプル要求の代わりに、一連の小さなプル要求を取得します。

- 巨大なPRを小さく分解し、レビューのコストを下げる

  ```mermaid
  ---
  title: ブランチイメージ
  ---
  gitGraph
    switch 'main'
    commit id: 'commit A'
    commit id: 'commit B'
    branch 'feature1'
    commit id: 'commit C'
    commit id: 'commit D'
    branch 'feature2'
    commit id: 'commit E'
    switch 'feature1'
    commit id: 'commit F'
    switch 'feature2'
    commit id: 'commit G'
    branch 'feature3'
    commit id: 'commit H'
  ```

  ```mermaid
  ---
  title: Pull Requestイメージ
  ---
  graph TD;
      A(上位) ---> B(下位);
      C["PR#3 (feature3ブランチ)"] 
      --> D["PR#2 (feature2ブランチ)"] 
      --> E["PR#1 (feature1ブランチ)"]
      --> F["ベースブランチ(masterブランチ)"];
  ```

  ![stack status on pr](/docs/stacked_pr_verification/images/stack_status_on_pr.png)

### 何ができるのか？

#### 下位のPRをマージした場合
```mermaid
---
title: feature1ブランチをmasterにmerge
---
gitGraph
  switch 'main'
  commit id: 'commit A'
  commit id: 'commit B'
  branch 'feature1'
  commit id: 'commit C'
  commit id: 'commit D'
  branch 'feature2'
  commit id: 'commit E'
  switch 'feature1'
  commit id: 'commit F'
  switch 'main'
  merge 'feature1'
  switch 'feature2'
  commit id: 'commit G'
  branch 'feature3'
  commit id: 'commit H'
```

```mermaid
---
title: 上位のPR(ブランチ)をrebaseしてくれる
---
gitGraph
  switch 'main'
  commit id: 'commit A'
  commit id: 'commit B'
  commit id: 'commit C'
  commit id: 'commit D'
  commit id: 'commit F'
  branch 'feature2'
  commit id: 'commit E'
  commit id: 'commit G'
  branch 'feature3'
  commit id: 'commit H'
```

- 下位のPRをマージすると、その上位PRの向き先がベースブランチに変わる
   ![rebase second branch](/docs/stacked_pr_verification/images/rebase_second_branch.png)
- 一連の上位のPRをrebaseしてくれる
   ![rebase third branch](/docs/stacked_pr_verification/images/rebase_third_branch.png)

#### 上位のPRをマージした場合

![merge higher pr](/docs/stacked_pr_verification/images/merge_higher_pr.png)

- 一連の下位のPRもマージする
   ![lower pr after higher pr was merged](/docs/stacked_pr_verification/images/lower_pr_after_higher_pr_was_merged.png)
   ![base branch after higher pr was merged](/docs/stacked_pr_verification/images/base_branch_after_higher_pr_was_merged.png)

### まとめ

- 一連のPRの下位のPRをマージした場合は、スタックの有無によって動きは大きく変わらない
  - 自動的にrebaseする
- 一連の上位のPRをマージした際に下位のPRもベースブランチにマージする

#### ユースケース

- PRのサイズが巨大である
  - 分解したPR個別ではリリースできない(機能として不十分など)

こういった場合に、上位のPRをマージすることで一連のPRを一括でマージするための機能
