#!/bin/bash
set -euo pipefail

# dotfilesへのパス
DOTFILES_DIR="$HOME/dotfiles"

# シンボリックリンクを作成する関数
create_symlink() {
    local src=$1
    local dst=$2
    
    # 既存のシンボリックリンクを削除
    if [ -L "$dst" ]; then
        echo "Removing existing symlink: $dst"
        rm "$dst"
    # 既存のファイル/ディレクトリがある場合はバックアップ
    elif [ -e "$dst" ]; then
        echo "Backing up $dst to ${dst}.backup"
        mv "$dst" "${dst}.backup"
    fi
    
    echo "Creating symlink: $dst -> $src"
    ln -s "$src" "$dst"
}

# =========================================
# Homebrewのインストール
# =========================================
if ! type brew >/dev/null 2>&1; then
  # Install brew if not installed
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ "$(uname -m)" = "arm64" ]; then
    # ARM版Mac(M*)用
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    # Intel版Mac用
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew is already installed."
fi

# =========================================
# Xcodeコマンドラインツールのインストール
# =========================================
# Check if command line tools are installed
if ! xcode-select --print-path >/dev/null 2>&1; then
  # Install command line tools
  echo "Command line tools not found. Installing..."
  xcode-select --install
else
  echo "Command line tools are already installed."
fi

# =========================================
# MacOS固有の設定
# =========================================
if [[ "$OSTYPE" == "darwin"* ]]; then
  # MacOS向けのコマンド
  echo "Running on MacOS"
  # Disable Character Picker in VSCode, Obsidian for Smooth cursor movement in VSCode Neovim.
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  defaults write md.obsidian ApplePressAndHoldEnabled -bool false
  defaults write io.cursor.Cursor ApplePressAndHoldEnabled -bool false
elif [[ "$OSTYPE" == "linux"* ]]; then
  # Linux向けのコマンド
  echo "Running on Linux"
fi

# =========================================
# Git設定
# =========================================
# グローバルで設定されたGitのユーザー名が存在しなければ、ユーザーに名前を尋ねて設定する
if [ -z "$(git config --global --get user.name)" ]; then
  echo "Git username is not set. Please enter your username: "
  read -r user_name
  git config --global user.name "$user_name"
  echo "Git username has been set to: $user_name"
else
  echo "Git username is already set. Skipping..."
fi

# グローバルで設定されたGitのメールアドレスが存在しなければ、ユーザーにメールアドレスを尋ねて設定する
if [ -z "$(git config --global --get user.email)" ]; then
  echo "Git email is not set. Please enter your email: "
  read -r user_email
  git config --global user.email "$user_email"
  echo "Git email has been set to: $user_email"
else
  echo "Git email is already set. Skipping..."
fi

# Gitの設定ディレクトリの作成
mkdir -p "$HOME/.config/git" "$HOME/.config/delta"

# Git設定ファイルのシンボリックリンク作成（存在する場合）
if [ -f "$DOTFILES_DIR/.config/git/common" ]; then
  create_symlink "$DOTFILES_DIR/.config/git/common" "$HOME/.config/git/common"
fi
if [ -f "$DOTFILES_DIR/.config/git/alias" ]; then
  create_symlink "$DOTFILES_DIR/.config/git/alias" "$HOME/.config/git/alias"
fi
if [ -f "$DOTFILES_DIR/.config/delta/config" ]; then
  create_symlink "$DOTFILES_DIR/.config/delta/config" "$HOME/.config/delta/config"
fi

# Gitの設定ファイルを更新
git config --global --unset-all include.path >/dev/null 2>&1 || true # include.pathを一度リセット
# 環境共通の設定を追加する
git config --global --add include.path "$HOME/.config/git/common"
# aliasを追加する
git config --global --add include.path "$HOME/.config/git/alias"
# deltaの設定を追加する
git config --global --add include.path "$HOME/.config/delta/config"

# =========================================
# dotfilesのシンボリックリンク作成
# =========================================
# ホームディレクトリの各dotfileのシンボリックリンクを作成
echo "Creating symlinks for dotfiles..."

# Zsh設定ファイルのシンボリックリンク
for file in zshrc zshenv zlogin zlogout; do
    create_symlink "$DOTFILES_DIR/zsh/.$file" "$HOME/.$file"
done

# fzf設定ファイルのシンボリックリンク
create_symlink "$DOTFILES_DIR/fzf/.fzf.zsh" "$HOME/.fzf.zsh"

# Git設定ファイルのシンボリックリンク
create_symlink "$DOTFILES_DIR/.config/git/.gitconfig" "$HOME/.gitconfig"

# .config ディレクトリのシンボリックリンクを作成
echo "Creating symlinks for .config directory..."
mkdir -p "$HOME/.config"

# starshipの設定
mkdir -p "$HOME/.config/starship"
if [ -d "$DOTFILES_DIR/.config/starship" ]; then
    create_symlink "$DOTFILES_DIR/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"
fi

# karabinerの設定
mkdir -p "$HOME/.config/karabiner"
if [ -f "$DOTFILES_DIR/.config/karabiner/karabiner.json" ]; then
    create_symlink "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
fi

# Cursorの設定
mkdir -p "$HOME/.cursor"
mkdir -p "$HOME/Library/Application Support/Cursor/User"

if [ -f "$DOTFILES_DIR/.config/vscode/settings.json" ]; then
    create_symlink "$DOTFILES_DIR/.config/vscode/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
fi

# iTerm2の設定
if [ -d "$DOTFILES_DIR/.config/iterm2" ]; then
    create_symlink "$DOTFILES_DIR/.config/iterm2" "$HOME/.config/iterm2"
fi

# SSHの設定
echo "Creating symlinks for SSH config..."
mkdir -p "$HOME/.ssh"
if [ -f "$DOTFILES_DIR/.ssh/config" ]; then
    create_symlink "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"
fi

# =========================================
# zinitのインストール
# =========================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    echo "Installing zinit..."
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# =========================================
# Homebrewパッケージのインストール
# =========================================
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "Installing Homebrew packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# =========================================
# Powerlineフォントの追加インストール
# =========================================
echo "Installing additional Powerline fonts..."
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
echo "Powerline fonts installation completed."

# =========================================
# App Storeアプリケーションのインストール
# =========================================
# AppStoreアプリケーションはBrewfileで管理するため、この部分は不要
# if [ -f "$DOTFILES_DIR/AppStore.txt" ]; then
#     echo "Installing App Store applications..."
#     mas install < "$DOTFILES_DIR/AppStore.txt"
# fi

# =========================================
# VSCode/Cursor拡張機能のインストール
# =========================================
install_vscode_extensions() {
  local extension=$1
  local cmd=$2
  echo "Installing extension with $cmd: $extension"
  $cmd --install-extension "$extension" --force || echo "Failed to install $extension with $cmd"
}

EXTENSIONS_FILE="$DOTFILES_DIR/.config/vscode/extensions"
echo "Checking for VSCode/Cursor extensions..."

if [ -f "$EXTENSIONS_FILE" ]; then
  echo "Installing VSCode/Cursor extensions from $EXTENSIONS_FILE..."
  
  while IFS= read -r extension || [ -n "$extension" ]; do
    # Skip empty lines or comments
    if [[ -z "$extension" || "$extension" =~ ^# ]]; then
      continue
    fi
    
    # Try to install with code (VSCode) command
    if command -v code &> /dev/null; then
      install_vscode_extensions "$extension" "code"
    fi
    
    # Try to install with cursor command
    if command -v cursor &> /dev/null; then
      install_vscode_extensions "$extension" "cursor"
    fi
  done < "$EXTENSIONS_FILE"
  echo "VSCode/Cursor extensions installation completed."
else
  echo "Extensions file not found: $EXTENSIONS_FILE. Skipping VSCode/Cursor extensions installation."
fi

echo "Done! Dotfiles have been installed."
