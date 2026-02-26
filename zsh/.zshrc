# =========================================
# 環境変数 / PATH
# =========================================

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

# local bin
export PATH="$HOME/.local/bin:$PATH"

# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# puppeteer
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=$(which chromium)

# .envから環境変数を読み込み
[ -f "${HOME}/.env" ] && export $(grep -v '^#' "${HOME}/.env" | xargs)

# =========================================
# Zshオプション
# =========================================
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space
setopt hist_reduce_blanks

# =========================================
# zinit / プラグイン
# =========================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-history-substring-search
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light olets/zsh-abbr

zinit ice wait"1"
zinit light Aloxaf/fzf-tab

# =========================================
# 補完
# =========================================
autoload -Uz compinit
compinit

# =========================================
# キーバインド
# =========================================
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# =========================================
# fzf-tab設定
# =========================================
# tab補完でファイルをプレビュー
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always ${(Q)realpath} 2>/dev/null || ls -l $realpath'

# ディレクトリの中身をプレビュー
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la $realpath'

# git操作のプレビュー
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
    'git diff $word | delta'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
    'case "$group" in
    "recent branches") git log --oneline -n 20 $word ;;
    *) git log --oneline -n 20 $word ;;
    esac'

# キルプロセスのプレビュー
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    'ps --pid=$word -o cmd --no-headers -w -w'

# 配色をカスタマイズ
zstyle ':fzf-tab:*' fzf-flags --color=bg+:23

# =========================================
# ツール初期化
# =========================================
# starship
export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"
eval "$(starship init zsh)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# direnv
eval "$(direnv hook zsh)"

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# =========================================
# エイリアス
# =========================================
alias g="git"
alias ls="eza"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lt="eza --tree --icons --level=2"
