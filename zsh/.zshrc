# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
# homebrew end

# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# nvm end

# pnpm
export PNPM_HOME="${HOME}/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# puppeteer
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

# zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# plugins
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-history-substring-search
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light olets/zsh-abbr

# 補完の履歴を上下キーで検索できるようにする
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

zinit ice wait"1"
zinit light Aloxaf/fzf-tab

# fzf-tab設定
# プレビューウィンドウを有効にする
zstyle ':fzf-tab:complete:*' fzf-preview 'less ${(Q)realpath}'

# tab補完でファイルをプレビュー
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always ${(Q)realpath} 2>/dev/null || ls -l $realpath'

# ディレクトリの中身をプレビュー
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la $realpath'

# git checkoutブランチのプレビュー
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

# Load completion system
autoload -Uz compinit
compinit

# starship
export STARSHIP_CONFIG="${HOME}/.config/starship/starship.toml"
eval "$(starship init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# 基本的なZshの設定
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space
setopt hist_reduce_blanks
