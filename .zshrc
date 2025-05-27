# =============================================================================
#  Alin's Ultimate Z‑Shell — v10.1 (Mint 21 · May 2025)
# =============================================================================
# Focus      : ⚡ instant‑prompt • async plugins • modern CLI • AI helpers • performance
# Plugin mgr : zinit (lazy via wait ice)
# Prompt     : powerlevel10k (instant‑prompt suppressed warnings)
# -----------------------------------------------------------------------------
# QUICK BOOTSTRAP (one‑liner):
# sudo apt update && sudo apt install -y zsh git curl jq pv fzf ripgrep bat eza fd-find \
#     procs erdtree sd zoxide direnv trash-cli xclip atuin git-delta
# chsh -s $(which zsh)
# -----------------------------------------------------------------------------

### 0 ▸ Instant prompt #######################################################
# Ensure quiet operation with no warning messages
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Create necessary directories silently
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" 2>/dev/null

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### 1 ▸ zinit bootstrap ######################################################
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  mkdir -p "${ZINIT_HOME:h}" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" &>/dev/null
fi
source "$ZINIT_HOME/zinit.zsh"

### 2 ▸ Core environment #####################################################
# Skip global compinit when using zinit (reduces startup time)
skip_global_compinit=1
export TERM="xterm-256color"
export EDITOR="windsurf --wait"; export VISUAL="$EDITOR"
export PAGER="bat --style=plain --paging=always --theme='Nord'"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"; export MANROFFOPT="-c"

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000; SAVEHIST=20000
setopt share_history append_history inc_append_history hist_verify \
       hist_expire_dups_first hist_reduce_blanks hist_fcntl_lock hist_find_no_dups \
       hist_ignore_all_dups hist_save_no_dups
setopt auto_cd auto_pushd pushd_ignore_dups auto_remove_slash auto_resume \
       notify long_list_jobs extended_glob

typeset -U path; path=("$HOME/.local/bin" "$HOME/bin" $path)

### 3 ▸ Plugin list (async via wait ice) #####################################
# Powerlevel10k theme
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Fast syntax highlighting
zinit ice wait"0.3"
zinit light zdharma-continuum/fast-syntax-highlighting

# Autosuggestions - loading early without delay for instant availability
zinit ice lucid atload"!_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# Autosuggest configuration
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# fzf binary + bindings
zinit ice wait"1" as"program" from"gh-r" pick"fzf"
zinit light junegunn/fzf-bin
zinit ice wait"0.5"
zinit light junegunn/fzf

# zoxide
zinit ice wait"0.6"
zinit light ajeetdsouza/zoxide

# autopair
zinit ice wait"0.7"
zinit light hlissner/zsh-autopair

# extra completions
zinit ice wait"0.4"
zinit light zsh-users/zsh-completions

# Enhanced history search (no atuin required)
# Bind up arrow to history search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Advanced history search with fzf
function fzf_history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort --tac --query "$BUFFER")
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N fzf_history
bindkey '^r' fzf_history

### 4 ▸ Completion ###########################################################
# Optimize compinit with caching based on file modification times
autoload -Uz compinit

# Set path for compdump file
compinit_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump-$ZSH_VERSION"

# Check if compdump is older than 24 hours
if [[ -f "$compinit_cache" && $(find "$compinit_cache" -mtime +1 2>/dev/null) ]]; then
  # Compinit once every 24 hours
  compinit -i -d "$compinit_cache"
else
  # Quick startup: read cached dump if it exists
  compinit -C -i -d "$compinit_cache"
fi

### 5 ▸ Modern CLI aliases ###################################################
alias rm='trash-put'
# Enhanced color scheme for ls (fish-like colors)
# Define vivid colors for different file types
eval "$(dircolors -b 2>/dev/null || true)"
export LS_COLORS="$LS_COLORS:di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# Fish-like directory listings with enhanced colors and columnar display
ls() {
  # Use vivid colors but maintain columnar display
  command ls -CF --group-directories-first --color=always "$@"
}

# Detailed listing - uses function for consistent API
ll() {
  if command -v eza &>/dev/null; then
    eza --long --color=always --icons --group-directories-first --sort=type --header --git "$@"
  elif command -v exa &>/dev/null; then
    exa --long --color=always --icons --group-directories-first --sort=type --header --git "$@"
  else
    command ls -la --color=auto "$@"
  fi
}

# Tree view for directories
lt() {
  if command -v eza &>/dev/null; then
    eza --tree --level=2 --color=always --icons --group-directories-first "$@"
  elif command -v exa &>/dev/null; then
    exa --tree --level=2 --color=always --icons --group-directories-first "$@"
  else
    # Poor man's tree with find and ls
    find . -maxdepth 2 -type d | sort | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
  fi
}

# Additional ls variants
alias la='ls -a'
alias ldir='ls -d */'

# Enhanced bat configuration with fallback
if command -v bat &>/dev/null; then
  # Initialize bat cache for performance
  export BAT_CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/bat"
  [[ ! -d "$BAT_CACHE_PATH" ]] && mkdir -p "$BAT_CACHE_PATH"
  
  # Use bat with consistent theme and settings
  export BAT_THEME="Nord"
  export BAT_STYLE="plain"
  
  # Replace cat with bat but keep cat available as original-cat
  alias cat='bat --style=$BAT_STYLE --paging=never'
  alias original-cat='\cat'
  
  # Add useful bat variants
  alias batl='bat --style=numbers --line-range :500'
  alias bats='bat --style=plain,header,grid'
  alias batg='bat --style=grid,header'
else
  # If bat isn't available, regular cat works fine
  alias batl='cat'
  alias bats='cat'
  alias batg='cat'
fi
command -v procs &>/dev/null && alias ps='procs --tree --sortd cpu'
command -v erd   &>/dev/null && alias tree='erd --icons'
command -v sd    &>/dev/null && alias replace='sd'
command -v delta &>/dev/null && git config --global core.pager delta

### 6 ▸ fzf defaults #########################################################
if command -v rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
else
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--ansi --height 40% --layout=reverse --border --preview "bat --color=always --style=numbers {} | head -120"'

# Enhanced fzf keybindings for better productivity
# Ctrl+T: Search for files and paste selection to commandline
# Alt+C: Navigate directories with interactive selection
# Ctrl+R: Search history with enhanced preview
if [ -f ~/.fzf.zsh ]; then
  # Add preview for history search
  export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
  
  # Add preview for Alt+C directory search
  export FZF_ALT_C_OPTS="--preview 'ls -l {}'"
  
  # Enhanced file search with enter, tab, and ctrl+space bindings
  export FZF_CTRL_T_OPTS="--bind 'ctrl-space:toggle+up,space:toggle+up' --preview-window right:60%"
fi
# Enhanced fzf file finder with preview
function ff() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')
  if [[ -n "$file" ]]; then
    $EDITOR "$file"
  fi
}

### 7 ▸ Helper functions #####################################################
# Universal project finder (compatible with zoxide)
function pj() {
  local dir
  dir=$(find ~/projects ~/work ~/github -maxdepth 2 -type d -name ".git" 2>/dev/null | 
        sed 's/\/\.git$//' | sort | fzf --preview "ls -la {}")
  if [[ -d "$dir" ]]; then
    cd "$dir" || return
  fi
}

# Extract various archive formats
function extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
mkcd() { mkdir -p "$1" && cd "$1"; }
serve() { python3 -m http.server "${1:-9000}"; }
please() { sudo $(fc -ln -1); }
chpwd() { ls; }
timer() { (sleep "$1" && notify-send "⌛ $1 done") & }

### 8 ▸ Last-command capture #################################################
LAST_OUT_FILE="${XDG_RUNTIME_DIR:-/tmp}/zsh_last_out.$$"; : >| "$LAST_OUT_FILE"
LAST_CMD_OUT=""; LAST_CMD_RET=0
__FD_OUT=-1; __FD_ERR=-1

preexec() {
  exec {__FD_OUT}>&1 {__FD_ERR}>&2
  exec > >(tee "$LAST_OUT_FILE") 2>&1
}
precmd() {
  if (( __FD_OUT >= 0 )); then
    exec 1>&${__FD_OUT} 2>&${__FD_ERR}
    exec {__FD_OUT}>&- {__FD_ERR}>&-
    __FD_OUT=-1; __FD_ERR=-1
  fi
  LAST_CMD_RET=$?
  if [[ -s $LAST_OUT_FILE ]]; then
    LAST_CMD_OUT=$(tail -20 "$LAST_OUT_FILE" | sed 's/^/│ /')
    : >| "$LAST_OUT_FILE"
  else
    LAST_CMD_OUT=""
  fi
}

p10k_segment_last_error() {
  (( LAST_CMD_RET == 0 )) && return
  [[ -z $LAST_CMD_OUT ]] && return
  p10k segment -t "$LAST_CMD_OUT" -f red -i ✖
}
[[ ${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[(I)last_error]} -eq 0 ]] && \
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status context dir vcs last_error)

### 9 ▸ AI helpers ###########################################################
# Requires: curl jq; keys in ~/.secrets.zsh
# Tip:  AIDEBUG=1 ai "hi"  →  prints request + response headers

# Prevent "no matches found" when grep pattern has no hits
setopt nonomatch

_gem_call() {
  # Check for dependencies
  if ! command -v curl &> /dev/null; then
    echo "Error: curl command not found. Please install curl." >&2
    return 1
  fi
  if ! command -v jq &> /dev/null; then
    echo "Error: jq command not found. Please install jq." >&2
    return 1
  fi

  local stream=0
  local prompt_args="$*"
  # Detect if --stream is the first argument
  if [[ "$1" == "--stream" ]]; then
    stream=1
    prompt_args="${@:2}" # Remove --stream from args
  fi
  
  local prompt_stdin=""
  local prompt=""

  # Check for stdin (pipe or redirect)
  if ! [[ -t 0 ]]; then
    prompt_stdin=$(cat)
  fi

  if [[ -n "$prompt_stdin" && -n "$prompt_args" ]]; then
    prompt="${prompt_stdin}\n\nContext/Question from arguments: ${prompt_args}"
  elif [[ -n "$prompt_stdin" ]]; then
    prompt="$prompt_stdin"
  elif [[ -n "$prompt_args" ]]; then
    prompt="$prompt_args"
  else
    echo "Usage: ai/q [--stream] \"prompt\" or echo text | ai/q [--stream] [\"optional context\"]" >&2; return 1
  fi

  [[ -z $GEMINI_API_KEY ]] && { echo "GEMINI_API_KEY not set" >&2; return 1; }
  local model="${GEMINI_MODEL:-gemini-2.0-flash}"
  
  local prompt_as_json_string_value
  prompt_as_json_string_value=$(printf '%s' "$prompt" | jq -R -s .)
  
  local body
  body=$(jq -n --argjson prompt_text_val "$prompt_as_json_string_value" \
    '{contents:[{parts:[{text:$prompt_text_val}]}]}')
  
  local url
  local curlflags_default
  local curlflags

  if (( stream )); then
    url="https://generativelanguage.googleapis.com/v1beta/models/${model}:streamGenerateContent?alt=sse&key=$GEMINI_API_KEY"
    curlflags_default="-sSN" # Silent, ShowError, No-buffer for streaming
  else # Non-streaming
    url="https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=$GEMINI_API_KEY"
    curlflags_default="-sS" # Silent, ShowError
  fi
  curlflags="$curlflags_default"

  # Pre-flight diagnostics (if AIDEBUG is set)
  if [[ -n $AIDEBUG ]]; then
    curlflags="-v" # Verbose for debug if streaming, -vN if not (or just -v always)
    [[ $stream -eq 1 ]] && curlflags="-vN"
    echo "--- DEBUG: Attempting curl call with following parameters: ---      (diagnostic)" >&2
    echo "--- DEBUG: URL: $url ---      (diagnostic)" >&2
    echo "--- DEBUG: Curl Flags: $curlflags ---      (diagnostic)" >&2
    echo "--- DEBUG: Body: $body ---      (diagnostic)" >&2 # Body already shown if AIDEBUG for _gem_call
    echo "--- DEBUG: End of pre-flight diagnostics ---      (diagnostic)" >&2
  fi

  local curl_output_file
  curl_output_file=$(mktemp) || { echo "Error: Failed to create temp file for curl output." >&2; return 1; }
  
  local curl_exit_code=0
  curl $curlflags -L --request POST "$url" -H 'Content-Type: application/json' -d "$body" > "$curl_output_file" 2>&1
  curl_exit_code=$?

  if [[ -n $AIDEBUG ]]; then
    echo "--- DEBUG: curl command exit code: $curl_exit_code ---      (0 means success)" >&2
    echo "--- DEBUG: Raw curl output (stdout & stderr combined) from temp file: ---      (see below)" >&2
    if [[ -s "$curl_output_file" ]]; then
      command cat "$curl_output_file" >&2
    else
      echo "(curl produced no output to stdout/stderr)" >&2
    fi
    echo "--- DEBUG: End of raw curl output ---      (see above)" >&2
  fi

  if [[ $curl_exit_code -eq 0 ]] && [[ -s "$curl_output_file" ]]; then
    if (( stream )); then
      command cat "$curl_output_file" | grep --line-buffered -o '^data: .*' | cut -d' ' -f2- | jq -r '.candidates[0].content.parts[]?.text // empty'
    else
      local response_json
      response_json=$(command cat "$curl_output_file")
      local extracted_text
      extracted_text=$(printf '%s' "$response_json" | jq -r '.candidates[0].content.parts[0].text')

      if [[ -n "$extracted_text" && "$extracted_text" != "null" ]]; then
        echo "$extracted_text"
      else
        echo "⚠️ AI response text not found or was null." >&2
        if [[ -z "$AIDEBUG" ]]; then # Show raw JSON if not in AIDEBUG and error
          echo "--- Raw Gemini API Response (for error context): ---" >&2
          printf '%s' "$response_json" | command cat - >&2
          echo "" >&2
        fi
        local api_error_message
        api_error_message=$(printf '%s' "$response_json" | jq -r '.error.message // empty')
        if [[ -n "$api_error_message" ]]; then
          echo "API Error from JSON: $api_error_message" >&2
        fi        
      fi
    fi
  else
    echo "⚠️ AI API call failed. Exit code: $curl_exit_code" >&2
    if [[ -z "$AIDEBUG" ]] && [[ -s "$curl_output_file" ]]; then # Show output file if not in AIDEBUG and error
        echo "--- Raw AI API Output/Error (for context): ---" >&2
        command cat "$curl_output_file" >&2
    fi
  fi
  command rm -f "$curl_output_file"
}

alias ai='_gem_call'
alias q='_gem_call --stream'
alias aipipe='_gem_call "$(cat)"'

px() {
  # Check for dependencies
  if ! command -v curl &> /dev/null; then
    echo "Error: curl command not found. Please install curl." >&2
    return 1
  fi
  if ! command -v jq &> /dev/null; then
    echo "Error: jq command not found. Please install jq." >&2
    return 1
  fi

  local prompt_args="$*"
  local prompt_stdin=""
  local prompt=""

  # Check for stdin (pipe or redirect)
  if ! [[ -t 0 ]]; then
    prompt_stdin=$(cat)
  fi

  if [[ -n "$prompt_stdin" && -n "$prompt_args" ]]; then
    # Combine stdin and args; you might prefer a different separator or order
    prompt="${prompt_stdin}\n\nContext/Question from arguments: ${prompt_args}"
  elif [[ -n "$prompt_stdin" ]]; then
    prompt="$prompt_stdin"
  elif [[ -n "$prompt_args" ]]; then
    prompt="$prompt_args"
  else
    echo "Usage: px \"prompt\" or echo text | px [\"optional context\"]" >&2; return 1
  fi

  [[ -z "$PERPLEXITY_API_KEY" ]] && { echo "PERPLEXITY_API_KEY not set in ~/.secrets.zsh" >&2; return 1; }

  local prompt_as_json_string_value
  prompt_as_json_string_value=$(printf '%s' "$prompt" | jq -R -s .)

  local perplexity_model="sonar-pro" # Good for web-search tasks
  local body
  body=$(jq -n --argjson p_content "$prompt_as_json_string_value" \
    --arg p_model "$perplexity_model" \
    '{
       "model": $p_model,
       "messages":[{"role":"user","content": $p_content}],
       "stream": false, 
       "web_access": true
     }')

  local url
  local curlflags

  url="https://api.perplexity.ai/chat/completions"
  local curlflags_default="-sS" # Silent, ShowError
  curlflags="$curlflags_default"

  # Pre-flight diagnostics (if AIDEBUG is set)
  if [[ -n "$AIDEBUG" ]]; then
    curlflags="-v" # Verbose for debug
    echo "--- DEBUG (Perplexity): Attempting curl call with following parameters: ---" >&2
    echo "--- DEBUG (Perplexity): URL: $url ---" >&2
    echo "--- DEBUG (Perplexity): Curl Flags: $curlflags ---" >&2
    echo "--- DEBUG (Perplexity): Body: $body ---" >&2
    echo "--- DEBUG (Perplexity): End of pre-flight diagnostics ---" >&2
  fi

  local curl_output_file
  curl_output_file=$(mktemp) || { echo "Error: Failed to create temp file for curl output." >&2; return 1; }
  
  local curl_exit_code=0
  curl $curlflags -L --request POST "$url" \
       -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
       -H 'Content-Type: application/json' \
       -d "$body" > "$curl_output_file" 2>&1
  curl_exit_code=$?

  # Unified Debugging Output (if AIDEBUG is set)
  if [[ -n "$AIDEBUG" ]]; then
    echo "--- DEBUG (Perplexity): curl command exit code: $curl_exit_code ---      (0 means success)" >&2
    echo "--- DEBUG (Perplexity): Raw curl output (stdout & stderr combined) from temp file: ---      (see below)" >&2
    if [[ -s "$curl_output_file" ]]; then
      command cat "$curl_output_file" >&2
    else
      echo "(curl produced no output to stdout/stderr)" >&2
    fi
    echo "--- DEBUG (Perplexity): End of raw curl output ---      (see above)" >&2
  fi

  # Process curl output
  if [[ $curl_exit_code -eq 0 ]] && [[ -s "$curl_output_file" ]]; then
    local response_json
    response_json=$(command cat "$curl_output_file")
    local extracted_text
    extracted_text=$(printf '%s' "$response_json" | jq -r '.choices[0].message.content') 

    if [[ -n "$extracted_text" && "$extracted_text" != "null" ]]; then
      echo "$extracted_text"
    else
      echo "⚠️ Perplexity response text not found or was null." >&2
      if [[ -z "$AIDEBUG" ]]; then 
          echo "--- Raw Perplexity API Response (for error context): ---" >&2
          printf '%s' "$response_json" | command cat - >&2 
          echo "" >&2 
      fi
    fi
  else
    echo "⚠️ Perplexity API call failed. Exit code: $curl_exit_code" >&2
    if [[ -z "$AIDEBUG" ]] && [[ -s "$curl_output_file" ]]; then
        echo "--- Raw Perplexity API Output/Error (for context): ---" >&2
        command cat "$curl_output_file" >&2
    fi
  fi
  command rm -f "$curl_output_file"
}

# --- END AI HELPERS ---------------------------------------------------

# === ZINIT SECTION ==========================================================
# Note: Zinit is already initialized at the top of this file

# Better tab completion menu with color support
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %d'

# Cache completions for faster startup
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

### 10 ▸ Secrets ############################################################
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh

### 11 ▸ direnv & zoxide ####################################################
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd j)"
command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

### 12 ▸ Performance & productivity enhancements ############################
# Zsh profiling tools
zsh-time() { time zsh -i -c exit; }

# Detailed zsh profiling (uncomment to run on startup)
# zmodload zsh/zprof

# Auto-notify on long-running commands (notify when command completes if it took more than 30 seconds)
autoload -Uz add-zsh-hook

ZSH_COMMAND_TIME_MIN_SECONDS=30
ZSH_COMMAND_TIME_EXCLUDE=("vim" "nano" "less" "man" "more" "tail" "bat" "ssh" "top" "htop")

command_time_preexec() {
  timer=${timer:-$SECONDS}
  COMMAND_TIME_CMD=${1}
  COMMAND_TIME_START=$(date +%s)
}

command_time_precmd() {
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    if [ -n "$COMMAND_TIME_CMD" ] && [ $timer_show -ge $ZSH_COMMAND_TIME_MIN_SECONDS ]; then
      # Check if command is excluded
      for exclude in ${ZSH_COMMAND_TIME_EXCLUDE[@]}; do
        if [[ "$COMMAND_TIME_CMD" == *"$exclude"* ]]; then
          return
        fi
      done
      notify-send "Command completed after ${timer_show}s" "$COMMAND_TIME_CMD" 2>/dev/null || true
    fi
    unset timer
    unset COMMAND_TIME_CMD
    unset COMMAND_TIME_START
  fi
}

# Only add hooks if notify-send is available
if command -v notify-send &>/dev/null; then
  add-zsh-hook preexec command_time_preexec
  add-zsh-hook precmd command_time_precmd
fi

# Clipboard integration
if command -v xclip &>/dev/null; then
  copy() { xclip -selection clipboard -in "$@"; }
  paste() { xclip -selection clipboard -out; }
  # Copy the last command
  alias copycommand='fc -ln -1 | copy'
fi

# Explain command using your AI function
explain() {
  _gem_call "Explain this shell command in detail: $*"
}
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

### 13 ▸ Powerlevel10k ######################################################
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# =============================================================================
# End of Alin's Ultimate Z-Shell v10 — AI restored & prompt clean
# =============================================================================

# Ensure consistent history management - either use atuin or fzf_history, not both
if [[ -f "$HOME/.atuin/bin/env" ]]; then
  . "$HOME/.atuin/bin/env"
  # Configure atuin to not conflict with fzf_history binding
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  # Use atuin with custom keybinding to avoid conflict
  bindkey '^s' _atuin_search_widget
fi