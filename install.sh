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
# Homebrewパッケージのインストール
# =========================================
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "Installing Homebrew packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
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

  # dutiでデフォルトアプリケーションをVSCodeに設定
  echo "Setting default applications with duti..."
  # UTIで広くカバー
  duti -s com.microsoft.VSCode public.plain-text all
  duti -s com.microsoft.VSCode public.source-code all
  duti -s com.microsoft.VSCode public.shell-script all
  duti -s com.microsoft.VSCode public.script all
  duti -s com.microsoft.VSCode public.xml all
  # 個別の拡張子（アプリが独自UTIを登録して上書きする場合の対策）
  extensions=(
    .js .ts .tsx .jsx .mjs .cjs
    .json .jsonc .jsonl
    .css .scss .sass .less
    .html .htm .svg
    .md .mdx .txt
    .yaml .yml .toml .ini .cfg .conf .env
    .sh .bash .zsh .fish
    .py .rb .go .rs .java .kt .swift .c .cpp .h .hpp .cs
    .sql .graphql .prisma
    .xml .csv .log
    .dockerfile .gitignore .gitattributes .editorconfig
    .lua .vim .el
  )
  for ext in "${extensions[@]}"; do
    duti -s com.microsoft.VSCode "$ext" all
  done
elif [[ "$OSTYPE" == "linux"* ]]; then
  # Linux向けのコマンド
  echo "Running on Linux"
fi

# =========================================
# Git設定
# =========================================
# Gitの設定ディレクトリの作成
mkdir -p "$HOME/.config/git"

# .gitconfigのシンボリックリンク作成
create_symlink "$DOTFILES_DIR/.config/git/.gitconfig" "$HOME/.gitconfig"

# Git設定ファイルのシンボリックリンク作成（存在する場合）
if [ -f "$DOTFILES_DIR/.config/git/common" ]; then
  create_symlink "$DOTFILES_DIR/.config/git/common" "$HOME/.config/git/common"
fi
if [ -f "$DOTFILES_DIR/.config/git/alias" ]; then
  create_symlink "$DOTFILES_DIR/.config/git/alias" "$HOME/.config/git/alias"
fi
if [ -f "$DOTFILES_DIR/.config/git/delta" ]; then
  create_symlink "$DOTFILES_DIR/.config/git/delta" "$HOME/.config/git/delta"
fi

# ローカル設定ファイル（user.name, email等）の作成
GIT_LOCAL="$HOME/.config/git/local"
if [ ! -f "$GIT_LOCAL" ]; then
  echo "Git local config not found. Creating $GIT_LOCAL..."
  echo "Please enter your Git username: "
  read -r user_name
  echo "Please enter your Git email: "
  read -r user_email
  cat > "$GIT_LOCAL" <<EOF
[user]
	name = $user_name
	email = $user_email
EOF
  echo "Git local config has been created."
else
  echo "Git local config already exists. Skipping..."
fi

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

# .config ディレクトリのシンボリックリンクを作成
echo "Creating symlinks for .config directory..."
mkdir -p "$HOME/.config"

# starshipの設定
mkdir -p "$HOME/.config/starship"
if [ -d "$DOTFILES_DIR/.config/starship" ]; then
    create_symlink "$DOTFILES_DIR/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"
fi

# zsh-abbrの設定
mkdir -p "$HOME/.config/zsh-abbr"
if [ -f "$DOTFILES_DIR/.config/zsh-abbr/user-abbreviations" ]; then
    create_symlink "$DOTFILES_DIR/.config/zsh-abbr/user-abbreviations" "$HOME/.config/zsh-abbr/user-abbreviations"
fi

# karabinerの設定
mkdir -p "$HOME/.config/karabiner"
if [ -f "$DOTFILES_DIR/.config/karabiner/karabiner.json" ]; then
    create_symlink "$DOTFILES_DIR/.config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
fi

# VSCode/Cursorの設定
mkdir -p "$HOME/Library/Application Support/Code/User"
mkdir -p "$HOME/Library/Application Support/Cursor/User"

if [ -f "$DOTFILES_DIR/.config/vscode/settings.json" ]; then
    create_symlink "$DOTFILES_DIR/.config/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    create_symlink "$DOTFILES_DIR/.config/vscode/settings.json" "$HOME/Library/Application Support/Cursor/User/settings.json"
fi

# Ghosttyの設定
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
if [ -f "$DOTFILES_DIR/.config/ghostty/config" ]; then
    create_symlink "$DOTFILES_DIR/.config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
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
# nvmのインストール
# =========================================
NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    
    # シェル環境の設定を読み込む
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # Node.js LTSバージョンをインストール
    echo "Installing Node.js LTS version..."
    nvm install --lts
    nvm alias default node
    
    echo "Node.js $(node -v) has been installed via nvm."
else
    echo "nvm is already installed."
fi

# =========================================
# yarnのインストール
# =========================================
if ! type yarn >/dev/null 2>&1; then
    echo "Installing yarn..."
    # nvmの環境を読み込む
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # yarnをインストール
    npm install -g yarn
    echo "yarn $(yarn --version) has been installed."
else
    echo "yarn is already installed."
fi

# =========================================
# pnpmのインストール
# =========================================
if ! type pnpm >/dev/null 2>&1; then
    echo "Installing pnpm..."
    # nvmの環境を読み込む
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # pnpmをインストール
    npm install -g pnpm
    
    # pnpmのセットアップ（既存の設定があれば上書き）
    pnpm setup --force
    
    # 設定を読み込む
    export PNPM_HOME="${HOME}/Library/pnpm"
    case ":$PATH:" in
      *":$PNPM_HOME:"*) ;;
      *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
    
    echo "pnpm $(pnpm --version) has been installed."
else
    echo "pnpm is already installed."
fi

# =========================================
# bunのインストール
# =========================================
if ! type bun >/dev/null 2>&1; then
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    echo "bun has been installed."
else
    echo "bun is already installed."
fi

# =========================================
# Claude Codeのインストール
# =========================================
if ! type claude >/dev/null 2>&1; then
    echo "Installing Claude Code..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm install -g @anthropic-ai/claude-code
    echo "Claude Code $(claude --version) has been installed."
else
    echo "Claude Code is already installed."
fi

# =========================================
# Rosetta 2のインストール（Apple Silicon Macの場合）
# =========================================
if [[ "$(uname -m)" == "arm64" ]]; then
  if ! /usr/bin/pgrep -q oahd; then
    echo "Installing Rosetta 2..."
    sudo softwareupdate --install-rosetta --agree-to-license
  else
    echo "Rosetta 2 is already installed."
  fi
fi

# =========================================
# フォントのインストール
# =========================================
echo "Installing fonts..."
# Hack Nerd Fontのインストール
if ! brew list --cask font-hack-nerd-font &>/dev/null; then
    echo "Installing Hack Nerd Font..."
    brew install --cask font-hack-nerd-font
else
    echo "Hack Nerd Font is already installed."
fi

# =========================================
# VSCode/Cursor拡張機能のインストール
# =========================================
install_vscode_extensions() {
  local extension=$1
  local cmd=$2
  
  # 拡張機能が既にインストールされているか確認
  local installed
  installed=$($cmd --list-extensions 2>/dev/null)
  if echo "$installed" | grep -q "^$extension$"; then
    echo "Extension $extension is already installed for $cmd"
    return 0
  fi
  
  echo "Installing extension with $cmd: $extension"
  if $cmd --install-extension "$extension" --force; then
    echo "Successfully installed $extension with $cmd"
    return 0
  else
    echo "Failed to install $extension with $cmd"
    return 1
  fi
}

EXTENSIONS_FILE="$DOTFILES_DIR/.config/vscode/extensions"
echo "Checking for VSCode/Cursor extensions..."

if [ -f "$EXTENSIONS_FILE" ]; then
  echo "Installing VSCode/Cursor extensions from $EXTENSIONS_FILE..."
  
  # インストール失敗した拡張機能を記録
  failed_extensions=()
  
  while IFS= read -r extension || [ -n "$extension" ]; do
    # Skip empty lines or comments
    if [[ -z "$extension" || "$extension" =~ ^# ]]; then
      continue
    fi
    
    # Try to install with code (VSCode) command
    if command -v code &> /dev/null; then
      if ! install_vscode_extensions "$extension" "code"; then
        failed_extensions+=("code:$extension")
      fi
    fi
    
    # Try to install with cursor command
    if command -v cursor &> /dev/null; then
      if ! install_vscode_extensions "$extension" "cursor"; then
        failed_extensions+=("cursor:$extension")
      fi
    fi
  done < "$EXTENSIONS_FILE"
  
  # インストール結果の報告
  if [ ${#failed_extensions[@]} -eq 0 ]; then
    echo "All VSCode/Cursor extensions were installed successfully."
  else
    echo "The following extensions failed to install:"
    printf '%s\n' "${failed_extensions[@]}"
  fi
else
  echo "Extensions file not found: $EXTENSIONS_FILE. Skipping VSCode/Cursor extensions installation."
fi

# =========================================
# Raycastの設定インポート
# =========================================
RAYCAST_CONFIG="$DOTFILES_DIR/.config/raycast"
RAYCAST_FILE=$(find "$RAYCAST_CONFIG" -name "*.rayconfig" -type f 2>/dev/null | head -1)

if [ -n "$RAYCAST_FILE" ]; then
    echo "Raycast config found: $RAYCAST_FILE"
    echo "Opening Raycast import dialog..."
    open "$RAYCAST_FILE"
    echo "Please complete the Raycast import in the dialog window."
else
    echo "No .rayconfig file found in $RAYCAST_CONFIG."
    echo "To export: Raycast Settings > Advanced > Export Settings & Data"
    echo "Save the .rayconfig file to $RAYCAST_CONFIG/"
fi

echo "Done! Dotfiles have been installed."
