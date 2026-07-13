fpath+=($HOME/.zsh/pure)
[[ -r "$HOME/.config/zsh/pure-os1.zsh" ]] && source "$HOME/.config/zsh/pure-os1.zsh"
autoload -U promptinit; promptinit
prompt pure

# Initialize zsh-autocomplete
[[ -s "$HOME/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]] && source "$HOME/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# Initialize zsh-autosuggestions
[[ -s "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Intitialize zsh-history-substring-search
[[ -s "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] && source "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"

# Initialize zoxide
eval "$(zoxide init zsh)"

# Initialize a flag so we run keychain only once per session
if [[ -z "$KEYCHAIN_INITIALIZED" ]]; then
  KEYCHAIN_INITIALIZED=0
fi

# Define a preexec hook that checks if the command starts with "ssh"
function preexec() {
  if [[ $KEYCHAIN_INITIALIZED -eq 0 && $1 == ssh* ]]; then
    # This will prompt you for your passphrase if needed and set SSH_AUTH_SOCK
    eval "$(keychain --eval ~/.ssh/id_ed25519)"
    KEYCHAIN_INITIALIZED=1
  fi
}

function ld() {
  eval 'sudo lazydocker'
}

# Helper function to open yazi in the current directory
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function cursor() {
  if [ $# -eq 0 ]; then
    env XDG_DATA_DIRS=/usr/share:/usr/local/share nohup /usr/bin/cursor --no-sandbox . > /dev/null 2>&1 &
    disown
  else
    env XDG_DATA_DIRS=/usr/share:/usr/local/share nohup /usr/bin/cursor --no-sandbox "$@" > /dev/null 2>&1 &
    disown
  fi
}

# Env variables
export EDITOR="nvim"
export VISUAL="nvim"
export XDG_CONFIG_HOME="$HOME/.config"

# Aliases
alias c="clear"
alias ff="fastfetch"
alias lg="lazygit"
alias nv="nvim"
function up() {
  sudo pacman -Syu &&
    yay -Syu &&
    /home/oli/dotfiles/scripts/update-codex-desktop
}

# bun completions
[ -s "/home/oli/.bun/_bun" ] && source "/home/oli/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export NVIM_DIR="$HOME/.nvm"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# autoload -U promptinit; promptinit
# prompt pure

# autoload -Uz promptinit
# promptinit
# prompt zen

# Enable syntax highlighting
[[ -s "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && nvm use --silent default >/dev/null
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.local/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
