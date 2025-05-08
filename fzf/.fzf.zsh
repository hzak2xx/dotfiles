# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

source <(fzf --zsh)

# Load fzf functions
DOTFILES_DIR="$HOME/dotfiles"
[ -f "$DOTFILES_DIR/fzf/functions.zsh" ] && source "$DOTFILES_DIR/fzf/functions.zsh"
