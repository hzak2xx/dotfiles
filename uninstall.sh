#!/bin/bash
set -euo pipefail

# dotfilesへのパス
DOTFILES_DIR="$HOME/dotfiles"

# シンボリックリンクを削除する関数
remove_symlink() {
    local target=$1
    
    # シンボリックリンクが存在する場合は削除
    if [ -L "$target" ]; then
        echo "Removing symlink: $target"
        rm "$target"
        
        # バックアップがある場合は復元
        if [ -e "${target}.backup" ]; then
            echo "Restoring backup: ${target}.backup -> $target"
            mv "${target}.backup" "$target"
        fi
    fi
}

# Git設定のシンボリックリンクを削除
echo "Removing symlinks for Git config..."
remove_symlink "$HOME/.config/git/common"
remove_symlink "$HOME/.config/git/alias"
remove_symlink "$HOME/.config/delta/config"
remove_symlink "$HOME/.gitconfig"

# ホームディレクトリの各dotfileのシンボリックリンクを削除
echo "Removing symlinks for dotfiles..."
# Zsh設定ファイル
remove_symlink "$HOME/.zshrc"
remove_symlink "$HOME/.zshenv"
remove_symlink "$HOME/.zlogin"
remove_symlink "$HOME/.zlogout"

# fzf設定ファイル
remove_symlink "$HOME/.fzf.zsh"

# .config ディレクトリのシンボリックリンクを削除
echo "Removing symlinks for .config directory..."
# starshipの設定
remove_symlink "$HOME/.config/starship/starship.toml"

# karabinerの設定
remove_symlink "$HOME/.config/karabiner/karabiner.json"

# Cursorの設定
remove_symlink "$HOME/vscode/settings.json"

# iTerm2の設定
remove_symlink "$HOME/.config/iterm2"

# SSHの設定
echo "Removing symlinks for SSH config..."
remove_symlink "$HOME/.ssh/config"

echo "Done! Dotfiles have been uninstalled." 
