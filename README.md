# dotfiles

MacBookの環境設定を管理するためのdotfilesリポジトリです。新しいMacBookをセットアップする際に、同じ環境を素早く再現することができます。

## ディレクトリ構成

```
dotfiles/
├── .config/            # 各種設定ファイル
│   ├── git/            # Git設定（.gitconfig含む）
│   ├── vscode/         # VSCode/Cursor設定
│   ├── karabiner/      # Karabiner設定
│   ├── starship/       # Starship設定
│   └── iterm2/         # iTerm2設定
├── .ssh/               # SSH設定
├── zsh/                # Zsh関連設定
│   ├── .zshrc          # Zshの主要設定
│   ├── .zshenv         # Zsh環境変数
│   ├── .zlogin         # ログイン時に読み込まれる
│   └── .zlogout        # ログアウト時に読み込まれる
├── fzf/                # Fuzzy Finder設定
│   ├── .fzf.zsh        # Zsh用fzf基本設定
│   └── functions.zsh   # fzf関連の関数定義
├── install.sh          # メインインストールスクリプト
├── uninstall.sh        # アンインストールスクリプト
└── Brewfile            # Homebrew設定
```

## 含まれる設定

- シェル設定
  - Zsh設定 (.zshrc, .zshenv)
  - zinit (プラグイン管理)
  - starship (プロンプトテーマ)
  - fzf (ファジーファインダー)

- Git設定
  - 基本設定 (.gitconfig)
  - エイリアス設定
  - git-delta設定 (差分表示の改善)

- アプリケーション設定
  - Karabiner-Elements (キーマップのカスタマイズ)
  - iTerm2
  - Cursor (コードエディタ)
  - SSH設定

- パッケージ管理
  - Homebrew製品リスト (Brewfile)

## 自動セットアップ機能

scripts/install.shスクリプトには以下の機能が含まれています：

- Homebrewの自動インストール (ARM/Intel Macを自動判別)
- Xcodeコマンドラインツールの自動インストール
- Git設定の対話型セットアップ (ユーザー名・メールアドレス)
- シンボリックリンクによる設定ファイル管理
- Brewfileからのパッケージ自動インストール
- zinitの自動インストール
- MacOS固有の設定適用

## 使い方

### 既存の環境にインストール

新しいMacBookにこのリポジトリをクローンして設定をインストールするには：

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# インストールスクリプトを実行
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

インストールスクリプトは以下の処理を自動的に行います：
1. Homebrewが未インストールの場合はインストール
2. Xcodeコマンドラインツールが未インストールの場合はインストール
3. Gitの初期設定（ユーザー名・メールアドレスが未設定の場合）
4. 設定ファイルのシンボリックリンク作成
5. Brewfileからのパッケージインストール
6. VSCode/Cursor拡張機能のインストール（利用可能な場合）

### 設定の更新

dotfilesを変更したい場合は、シンボリックリンク先の実際のファイルを編集し、変更をコミットしてください。

### Brewfileの更新

新しいパッケージをインストールした後にBrewfileを更新するには：

```bash
brew bundle dump --force --file=~/dotfiles/Brewfile
```

### アンインストール

```bash
cd ~/dotfiles
chmod +x uninstall.sh
./uninstall.sh
```

## 他のアプリケーション設定の追加方法

1. アプリケーションの設定ファイルを `~/dotfiles` の適切な場所にコピー
2. `install.sh` スクリプトを更新して、新しい設定ファイルのシンボリックリンクを作成
3. `uninstall.sh` スクリプトを更新して、アンインストール時に設定を削除するように

## カスタマイズされたGit環境

このdotfilesには以下のGit設定が含まれています：

- 共通設定 (.config/git/common)
  - エディタ設定、文字コード設定、デフォルトブランチ名など

- エイリアス設定 (.config/git/alias)
  - 頻繁に使用するコマンドの短縮形
  - グラフ表示を含むログ表示の改善

- git-delta設定 (.config/delta/config)
  - 差分表示の改善（シンタックスハイライト、行番号表示など）

## 便利コマンド一覧

### eza (`ls` の代替)

| コマンド | 説明 |
|---------|------|
| `ls` | シンプルなファイル一覧 |
| `ll` | 詳細表示 + アイコン + Git status |
| `la` | `ll` + 隠しファイル |
| `lt` | ツリー表示（2階層） |

### zoxide (`cd` の代替)

移動したディレクトリを学習し、部分一致で移動できる。

| コマンド | 説明 |
|---------|------|
| `cd dotfiles` | 部分一致で移動 |
| `cd proj my-app` | 複数キーワードで絞り込み |
| `cdi` | fzf で対話的に選択して移動 |

### ripgrep (`grep` の代替)

| コマンド | 説明 |
|---------|------|
| `rg "pattern"` | カレントディレクトリ以下を再帰検索 |
| `rg "pattern" -t ts` | .ts ファイルのみ検索 |
| `rg "pattern" -i` | 大文字小文字を無視 |
| `rg "pattern" -l` | マッチしたファイル名のみ表示 |
| `rg "pattern" -C 3` | 前後3行のコンテキスト付き |

### fd (`find` の代替)

| コマンド | 説明 |
|---------|------|
| `fd` | 全ファイル一覧 |
| `fd "\.ts$"` | .ts ファイルを検索 |
| `fd component -e tsx` | 名前に component を含む .tsx ファイル |
| `fd -t d node_modules` | ディレクトリのみ検索 |
| `fd -H .env` | 隠しファイルも含めて検索 |

### tldr (`man` の簡易版)

| コマンド | 説明 |
|---------|------|
| `tldr tar` | tar の使い方を簡潔に表示 |
| `tldr git rebase` | サブコマンドも対応 |

### fzf (ファジーファインダー)

| コマンド | 説明 |
|---------|------|
| `Ctrl+R` | コマンド履歴を検索 |
| `Ctrl+T` | ファイルを検索してパスを挿入 |
| `Alt+C` | ディレクトリを検索して移動 |

### bat (`cat` の代替)

| コマンド | 説明 |
|---------|------|
| `bat file.ts` | シンタックスハイライト付きで表示 |
| `bat -n file.ts` | 行番号のみ（ヘッダーなし） |
| `bat -l json` | 言語を指定して表示 |

### Git エイリアス (`g` = `git`)

基本:

| コマンド | 展開 | 説明 |
|---------|------|------|
| `g s` | `git status` | 状態確認 |
| `g a` | `git add` | ステージング |
| `g aa` | `git add -A` | 全ファイルをステージング |
| `g c` | `git commit` | コミット |
| `g cm "msg"` | `git commit -m` | メッセージ付きコミット |
| `g ca` | `git commit --amend` | 直前のコミットを修正 |
| `g cane` | `git commit --amend --no-edit` | メッセージ変更なしで修正 |

ブランチ:

| コマンド | 展開 | 説明 |
|---------|------|------|
| `g co branch` | `git checkout` | ブランチ切り替え |
| `g cob name` | `git checkout -b` | 新規ブランチ作成 |
| `g b` | `git branch` | ローカルブランチ一覧 |
| `g ba` | `git branch -a` | 全ブランチ一覧 |
| `g recent` | - | 最近使った10ブランチを表示 |

ログ・差分:

| コマンド | 展開 | 説明 |
|---------|------|------|
| `g lg` | - | グラフ付きログ |
| `g lga` | - | 全ブランチのグラフ付きログ |
| `g d` | `git diff` | 差分表示 |
| `g ds` | `git diff --staged` | ステージ済みの差分 |
| `g last` | `git log -1 HEAD` | 直前のコミットを表示 |

リモート・スタッシュ:

| コマンド | 展開 | 説明 |
|---------|------|------|
| `g f` | `git fetch` | フェッチ |
| `g p` | `git push` | プッシュ |
| `g pl` | `git pull` | プル |
| `g st` | `git stash` | スタッシュ |
| `g stp` | `git stash pop` | スタッシュを適用 |
| `g unstage` | `git reset HEAD --` | ステージングを取り消し |

### fzf カスタムキーバインド

| キー | 説明 |
|------|------|
| `Ctrl+R` | コマンド履歴を fzf で検索 |
| `Ctrl+T` | ファイルを fzf で検索してパスを挿入 |
| `Ctrl+Q` | 最近移動したディレクトリを fzf で選択して移動 |
| `Alt+C` | ディレクトリを fzf で検索して移動 |

### direnv (ディレクトリごとの環境変数管理)

| コマンド | 説明 |
|---------|------|
| `direnv allow` | カレントディレクトリの .envrc を許可 |
| `direnv deny` | .envrc の読み込みを拒否 |
| `direnv edit .` | .envrc を編集して自動で allow |

プロジェクトに `.envrc` を置くと、`cd` 時に自動で環境変数がロード/アンロードされる。

## 注意事項

- SSH鍵などの機密情報は含まれていません。必要に応じて手動でコピーしてください。
- Karabiner-ElementsとCursorの設定は初期状態のものです。必要に応じてカスタマイズしてください。
