# ============================================================================
#  Alin's Ultimate Z‑Shell — v6  (Mint 21, May 2025)
# ============================================================================
#  Philosophy  : instant prompt, minimal cognitive load, future‑proof.
#  Priorities  : ⚡ speed  •  🛠️ modern CLI  •  🔍 fuzzy/semantic search  •  🪄 joy.
#  Plugin mgr  : zinit Turbo (background lazy‑loading).
#  Prompt      : powerlevel10k (kept – you like it).
# -----------------------------------------------------------------------------
#  QUICK BOOTSTRAP  — run once if any tools are missing
#  sudo apt update && sudo apt install -y \
#       zsh git curl fzf ripgrep bat eza fd-find procs erdtree sd \
#       zoxide direnv trash-cli xclip atuin git-delta
#  chsh -s $(which zsh)   # make Zsh your login shell
# -----------------------------------------------------------------------------

### 0 ▸ P10k instant‑prompt  (must stay first) ###############################
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### 1 ▸ zinit Turbo bootstrap ###############################################
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
  mkdir -p "${ZINIT_HOME:h}" && \
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" 2>/dev/null
fi
source "$ZINIT_HOME/zinit.zsh"

# Turbo: load everything *after* ZLE is ready, interactive instantly
zinit turbo 1; zinit wait lucid

### 2 ▸ Core environment #####################################################
export TERM="xterm-256color"
export EDITOR="windsurf --wait"   # VS‑Code fork GUI
export VISUAL="$EDITOR"
export PAGER="bat --style=plain --paging=never"

# Bat as manpager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# History (XDG‑compliant & safe) -------------------------------------------
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=20000
setopt share_history append_history inc_append_history hist_verify \
       hist_expire_dups_first hist_fcntl_lock hist_reduce_blanks \
       hist_ignore_all_dups hist_find_no_dups

# Shell niceties ------------------------------------------------------------
setopt auto_cd auto_pushd pushd_ignore_dups auto_remove_slash auto_resume \
       notify long_list_jobs extended_glob

### 3 ▸ PATH (deduped) ######################################################
typeset -U path
path=($HOME/.local/bin $HOME/bin $path)
export PATH

### 4 ▸ Plugins (minimal & async) ###########################################
# 4.1  Powerlevel10k
zinit ice depth=1
zinit light romkatv/powerlevel10k

# 4.2  fast‑syntax‑highlighting (faster than legacy plugin)
zinit ice wait"0.7"
zinit light zdharma-continuum/fast-syntax-highlighting

# 4.3  Autosuggestions (async)
zinit ice wait"0.5" atload"ZSH_AUTOSUGGEST_USE_ASYNC=1"
zinit light zsh-users/zsh-autosuggestions

# 4.4  fzf binary + key‑bindings
zinit ice wait"1" lucid as"program" from"gh-r" pick"fzf"
zinit light junegunn/fzf-bin
zinit ice wait"1.2"
zinit light junegunn/fzf

# 4.5  zoxide smart cd
zinit ice wait"0.6"
zinit light ajeetdsouza/zoxide

# 4.6  Atuin – SQLite fuzzy history (optional, loads only if installed)
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# 4.7  autopair (auto‑close brackets)
zinit ice wait"1.5"
zinit light hlissner/zsh-autopair

### 5 ▸ Modern CLI aliases ###################################################
# Safer file ops
alias rm='trash-put'

# List ------------------------------------------------
if command -v eza &>/dev/null; then
  alias ls='eza --icons --git --group-directories-first --sort=type'
else
  alias ls='ls --color=auto -F --group-directories-first'
fi
alias ll='ls -alh'

# View -------------------------------------------------
alias cat='bat --style=plain --paging=never'

# Process / tree / replace
command -v procs   &>/dev/null && alias ps='procs --tree --sortd cpu'
command -v erd     &>/dev/null && alias tree='erd --icons'
command -v sd      &>/dev/null && alias replace='sd'

# Git diff pager (delta)
if command -v delta &>/dev/null; then
  git config --global core.pager delta
fi

### 6 ▸ FZF + Ripgrep power ##################################################
if command -v rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
  export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
else
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--ansi --height 40% --layout=reverse --border=rounded \
  --preview "bat --style=numbers --color=always {} | head -100" --preview-window=right:55%:wrap'

# Interactive ripgrep search → open in $EDITOR
rgi() {
  local query="$*"; [[ -z $query ]] && read -r "?🔍 Pattern: " query
  [[ -z $query ]] && return 1
  local result=$(rg --line-number --column --smart-case --no-heading --color=always "$query" | \
    fzf --ansi --delimiter : --preview 'bat --color=always {1} --highlight-line {2}' --preview-window=right:60%:wrap)
  [[ -z $result ]] && return 1
  local file=${result%%:*}; local line=${result#*:}; line=${line%%:*}
  $EDITOR +$line "$file"
}

### 7 ▸ Functions & helpers ##################################################
mkcd() { mkdir -p "$1" && cd "$1"; }
serve() { python3 -m http.server "${1:-9000}"; }
please() { sudo $(fc -ln -1); }
chpwd() { ls; }
timer() { (sleep "$1" && notify-send "⌛ Timer done: $1") & }

### 8 ▸ Tool hooks ###########################################################
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd j)"
command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

### 9 ▸ Auto‑update (weekly, silent) ########################################
zinit self-update --silent --frequency 7d
zinit update --silent --frequency 7d &!

### 10 ▸ Local overrides #####################################################
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

### 11 ▸ P10k theme ##########################################################
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ==========================================================================
#  End of file — enjoy the flow! ✨
# ==========================================================================
