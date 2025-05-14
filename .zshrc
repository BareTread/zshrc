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
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
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

# Autosuggestions
zinit ice wait"0.2" atload"ZSH_AUTOSUGGEST_USE_ASYNC=1"
zinit light zsh-users/zsh-autosuggestions

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

# atuin history with better configuration
if command -v atuin &>/dev/null; then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^r' _atuin_search_widget
  # Don't store sensitive commands in atuin history
  export ATUIN_FILTER_COMMANDS="aws .* --profile|aws .* --access-key|password|secret|token|api.?key|credential"
  # Use SQLite mode for better performance
  export ATUIN_DB_IMPLEMENTATION="sqlite"
fi

### 4 ▸ Completion ###########################################################
autoload -Uz compinit && compinit -i -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump-$ZSH_VERSION"

### 5 ▸ Modern CLI aliases ###################################################
alias rm='trash-put'
if command -v eza &>/dev/null; then
  alias ls='eza --icons --git --group-directories-first --sort=type'
else
  alias ls='ls --color=auto -F --group-directories-first'
fi
alias ll='ls -alh'
alias cat='bat --style=plain --paging=never'
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
# Initialize Zinit (plugin manager)
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  command git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  echo "Zinit cloned. Please restart your shell or source ~/.zshrc"
else
  source "${ZINIT_HOME}/zinit.zsh"
fi

# Load Zsh's completion system
# These are now conditional, only loading if zinit itself loaded successfully
if (( $+functions[zinit] )); then
  autoload -Uz compinit && compinit
  # Load and initialize completion system for zinit itself
  # zinit cdreplay -q # This was causing issues, let's see if compinit is enough
else
  echo "Zinit not loaded. Completions might be affected." >&2
fi

### 10 ▸ Secrets ############################################################
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh

### 11 ▸ direnv & zoxide ####################################################
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd j)"
command -v direnv  &>/dev/null && eval "$(direnv hook zsh)"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

### 12 ▸ Local overrides ####################################################
# Profile zsh startup time (uncomment to use)
# zsh-time() { time zsh -i -c exit; }

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
