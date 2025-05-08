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

## 注意事項

- SSH鍵などの機密情報は含まれていません。必要に応じて手動でコピーしてください。
- Karabiner-ElementsとCursorの設定は初期状態のものです。必要に応じてカスタマイズしてください。
