# =============================================================================
# Alin's ENHANCED Zsh Configuration - Best of All Worlds
# Combines: Current optimized (47ms) + Ultimate v12.0 gold nuggets
# Target: <50ms startup with MAXIMUM productivity features
# =============================================================================

# 0. PERFORMANCE PROFILING (uncomment to analyze)
# zmodload zsh/zprof

# 1. INSTANT PROMPT (MUST be absolutely first)
# =============================================================================
{
    mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" \
             "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" \
             "${XDG_DATA_HOME:-$HOME/.local/share}/zsh" \
             "$HOME/.local/bin"
} &>/dev/null

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. CRITICAL PERFORMANCE OPTIONS
# =============================================================================
setopt no_global_rcs
unsetopt prompt_cr

# 3. CORE ENVIRONMENT & OPTIONS (ENHANCED)
# =============================================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export TERM="${TERM:-xterm-256color}"
export EDITOR="${EDITOR:-micro}"
export VISUAL="$EDITOR"
export BROWSER="${BROWSER:-firefox}"

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

if command -v batcat &>/dev/null; then
    export PAGER="batcat --style=plain --paging=always"
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    export BAT_THEME="Nord"
elif command -v bat &>/dev/null; then
    export PAGER="bat --style=plain --paging=always"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export BAT_THEME="Nord"
else
    export PAGER="less -R"
fi

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=100000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS HIST_REDUCE_BLANKS HIST_VERIFY
setopt INC_APPEND_HISTORY

setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT CDABLE_VARS
setopt EXTENDED_GLOB NO_NOMATCH NO_BEEP INTERACTIVE_COMMENTS
setopt COMPLETE_IN_WORD ALWAYS_TO_END PATH_DIRS AUTO_PARAM_SLASH MARK_DIRS

# 4. PATH OPTIMIZATION
# =============================================================================
typeset -U path PATH fpath FPATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.cargo/bin"
  "$HOME/.go/bin"
  $path
)

# 5. ZINIT SETUP (silent and fast)
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
  {
    command mkdir -p "${ZINIT_HOME:h}"
    command git clone -q https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  } &>/dev/null
fi
source "$ZINIT_HOME/zinit.zsh"

# 6. COMPLETION SYSTEM (OPTIMIZED)
# =============================================================================
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

autoload -Uz compinit
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
if [[ ! -f "$zcompdump" ]] || [[ "$zcompdump" -ot "$HOME/.zshrc" ]]; then
  compinit -d "$zcompdump"
else
  compinit -d "$zcompdump" -C
fi

# 7. PLUGINS WITH OPTIMIZED TURBO MODE
# =============================================================================
zinit ice depth=1 atload'[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh'
zinit light romkatv/powerlevel10k

zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

zinit wait lucid for \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    atload'bindkey "^[[A" history-substring-search-up; bindkey "^[[B" history-substring-search-down' \
        zsh-users/zsh-history-substring-search

zinit wait"0b" lucid for hlissner/zsh-autopair

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

# 8. ENHANCED CLI ALIASES
# =============================================================================
alias rm='trash-put 2>/dev/null || rm -i'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'

if command -v batcat &>/dev/null; then
    alias bat='batcat'
    alias cat='batcat --style=plain --paging=never'
    alias catp='batcat --style=plain'
    alias catl='batcat --style=numbers,header --line-range :500'
elif command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias catp='bat --style=plain'
    alias catl='bat --style=numbers,header --line-range :500'
fi

if command -v eza &>/dev/null; then
    alias ls='eza --color=always --icons=always --group-directories-first'
    alias ll='eza -lahg --color=always --icons=always --git --group-directories-first'
    alias la='eza -a --color=always --icons=always --group-directories-first'
    alias lt='eza --tree --level=2 --color=always --icons=always'
else
    alias ls='ls --color=auto -F --group-directories-first 2>/dev/null || ls -F'
    alias ll='ls -lahF'
    alias la='ls -A'
    alias lt='tree -L 2 2>/dev/null || find . -maxdepth 2 -type d'
fi

command -v procs &>/dev/null && alias ps='procs'
command -v btop &>/dev/null && alias top='btop' || { command -v htop &>/dev/null && alias top='htop'; }
command -v duf &>/dev/null && alias df='duf'
command -v fd &>/dev/null && alias find='fd'
command -v rg &>/dev/null && alias grep='rg'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -v'
alias gp='git push'
alias gl='git pull --rebase --autostash'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias glog='git log --oneline --decorate --graph -20'

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'
alias dclean='docker system prune -f'

alias zshrc="$EDITOR ~/.zshrc"
alias reload='exec zsh'
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'

if command -v xclip &>/dev/null; then
    alias clip='xclip -selection clipboard'
    alias clipp='xclip -selection clipboard -o'
    alias copy='xclip -selection clipboard'
    alias paste='xclip -selection clipboard -out'
    alias cpwd='pwd | tr -d "\n" | xclip -selection clipboard'
    alias copylast='fc -ln -1 | xclip -selection clipboard'
elif command -v wl-copy &>/dev/null; then
    alias clip='wl-copy'
    alias clipp='wl-paste'
    alias copy='wl-copy'
    alias paste='wl-paste'
elif command -v pbcopy &>/dev/null; then
    alias clip='pbcopy'
    alias clipp='pbpaste'
    alias copy='pbcopy'
    alias paste='pbpaste'
fi

alias cx='claude'

# 9. ENHANCED SMART FUNCTIONS (GOLD NUGGETS!)
# =============================================================================
mkcd() { mkdir -p "$1" && cd "$1"; }

chpwd() {
    if [[ "$PWD" != "$HOME" ]]; then
        if (( $(command ls -1 | wc -l) < 30 )); then
            eza --icons 2>/dev/null || ls
        else
            ls
        fi
    fi
}

perf() {
    echo "CPU: $(grep MHz /proc/cpuinfo | head -1 | awk '{print $4}') MHz"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
}

proj() { cd ~/projects 2>/dev/null && ls || echo "~/projects not found"; }
opt() { cd ~/projects/optimizable-ai 2>/dev/null || echo "Project not found"; }

extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"       ;;
            *.zip)       unzip "$1"       ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

ff() {
    local file
    if command -v fzf &>/dev/null; then
        file=$(fzf --preview 'batcat --color=always {} 2>/dev/null || bat --color=always {} 2>/dev/null || cat {}')
        [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
    else
        echo "fzf not found. Install with: sudo apt install fzf"
    fi
}

pj() {
    local dir
    local search_dirs=(~/projects ~/code ~/work ~/Documents/projects ~/Desktop)
    local existing_dirs=()
    for d in "${search_dirs[@]}"; do
        [[ -d "$d" ]] && existing_dirs+=("$d")
    done
    if [[ ${#existing_dirs[@]} -eq 0 ]]; then
        echo "No project directories found. Create one of: ${search_dirs[*]}"
        return 1
    fi
    if command -v fzf &>/dev/null; then
        dir=$(find "${existing_dirs[@]}" -maxdepth 2 -type d -name ".git" 2>/dev/null | \
              sed 's/\/\.git$//' | sort -u | \
              fzf --preview "ls -la {}")
        [[ -n "$dir" ]] && cd "$dir"
    else
        echo "Available project directories:"
        find "${existing_dirs[@]}" -maxdepth 2 -type d -name ".git" 2>/dev/null | sed 's/\/\.git$//' | sort -u
    fi
}

backup() {
    [[ -z "$1" ]] && { echo "Usage: backup <file>"; return 1; }
    cp "$1" "$1.$(date +%Y%m%d_%H%M%S).bak"
    echo "Backed up: $1 → $1.$(date +%Y%m%d_%H%M%S).bak"
}

px() {
    if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
        echo "Error: curl and jq required. Install: sudo apt install curl jq" >&2
        return 1
    fi
    [[ -z "$PERPLEXITY_API_KEY" ]] && {
        echo "Error: PERPLEXITY_API_KEY not set. Add to ~/.secrets.zsh:" >&2
        echo "  export PERPLEXITY_API_KEY='your-key-here'" >&2
        echo "Get your key: https://www.perplexity.ai/settings/api" >&2
        return 1
    }
    local prompt_text="$*"
    [[ -z "$prompt_text" ]] && { echo "Usage: px <your question>"; return 1; }
    echo -e "\033[36m🤖 Perplexity AI is thinking...\033[0m"
    local model_name="${PERPLEXITY_MODEL:-sonar-pro}"
    local request_body=$(jq -n --arg prompt_content "$prompt_text" --arg model_name "$model_name" \
        '{model: $model_name, messages: [{role: "user", content: $prompt_content}]}')
    local response_json=$(curl -sS --max-time 30 \
        -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "$request_body" "https://api.perplexity.ai/chat/completions" 2>/dev/null)
    local cleaned_response_json=$(printf '%s' "$response_json" | awk '{
        gsub(/\r/, "\\r"); gsub(/\n/, "\\n"); gsub(/\t/, "\\t"); print;
    }')
    local result_text=$(printf '%s' "$cleaned_response_json" | jq -r '.choices[0].message.content' 2>/dev/null)
    if [[ -z "$result_text" || "$result_text" == "null" ]]; then
        result_text=$(printf '%s' "$response_json" | jq -r '.choices[0].message.content' 2>/dev/null)
    fi
    if [[ -z "$result_text" || "$result_text" == "null" ]]; then
        local error_message=$(printf '%s' "$response_json" | jq -r '.error.message // ""')
        if [[ -n "$error_message" ]]; then
            echo "Error from Perplexity API: $error_message" >&2
        else
            echo "Error: No valid response from Perplexity API." >&2
        fi
        return 1
    fi
    echo -e "\n\033[1;36m🧠 \033[1;37m$prompt_text\033[0m"
    echo -e "\033[36m▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\033[0m"
    local clean_text=$(printf '%s\n' "$result_text" | sed -e 's/\\n/\n/g' -e 's/\\t/\t/g' -e 's/\\r/\r/g')
    echo "$clean_text" | sed \
        -e 's/\*\*\([^*]*\)\*\*/\x1b[1;33m\1\x1b[0m/g' \
        -e 's/\[\([0-9]\+\)\]//g' \
        -e 's/```bash/\x1b[1;36m▶ \x1b[0;36m/g' \
        -e 's/```/\x1b[0m/g' \
        -e 's/`\([^`]*\)`/\x1b[1;37m\1\x1b[0m/g' \
        -e 's/^\- /\x1b[32m▶\x1b[0m /g'
}

pxclip() {
    local content=$(clipp 2>/dev/null)
    [[ -z "$content" ]] && { echo "Clipboard is empty"; return 1; }
    px "$content"
}

explain() {
    [[ -z "$*" ]] && { echo "Usage: explain <command>"; return 1; }
    if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
        echo "Error: curl and jq required. Install: sudo apt install curl jq" >&2
        return 1
    fi
    [[ -z "$PERPLEXITY_API_KEY" ]] && {
        echo "Error: PERPLEXITY_API_KEY not set. Add to ~/.secrets.zsh:" >&2
        echo "  export PERPLEXITY_API_KEY='your-key-here'" >&2
        return 1
    }
    echo -e "\033[36m🧠 Analyzing command...\033[0m"
    local prompt="You are a wise shell expert. Explain this command in 2-3 concise sentences that anyone can understand. Focus on WHAT it does and WHY someone would use it. Be practical, not academic. Format with: 1) One-line summary 2) Key purpose 3) Common use case. Command: $*"
    local request_body=$(jq -n --arg prompt_content "$prompt" '{model: "sonar", messages: [{role: "user", content: $prompt_content}]}')
    local response_json=$(curl -sS --max-time 30 \
        -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "$request_body" "https://api.perplexity.ai/chat/completions" 2>/dev/null)
    local result_text=$(printf '%s' "$response_json" | jq -r '.choices[0].message.content // .error.message // "No response"')
    echo -e "\n\033[1;32m⚡ \033[1;37m$*\033[0m"
    echo -e "\033[32m▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\033[0m"
    local clean_text=$(printf '%s\n' "$result_text" | sed -e 's/\\n/\n/g' -e 's/\\t/\t/g' -e 's/\\r/\r/g')
    echo "$clean_text" | sed \
        -e 's/\*\*\([^*]*\)\*\*/\x1b[1;33m\1\x1b[0m/g' \
        -e 's/\[\([0-9]\+\)\]//g' \
        -e 's/```bash/\x1b[1;36m▶ \x1b[0;36m/g' \
        -e 's/```/\x1b[0m/g' \
        -e 's/`\([^`]*\)`/\x1b[1;37m\1\x1b[0m/g'
}

suggest() {
    [[ -z "$*" ]] && { echo "Usage: suggest <what you want to do>"; return 1; }
    if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
        echo "Error: curl and jq required. Install: sudo apt install curl jq" >&2
        return 1
    fi
    [[ -z "$PERPLEXITY_API_KEY" ]] && {
        echo "Error: PERPLEXITY_API_KEY not set. Add to ~/.secrets.zsh:" >&2
        echo "  export PERPLEXITY_API_KEY='your-key-here'" >&2
        return 1
    }
    echo -e "\033[35m🚀 Finding solution...\033[0m"
    local prompt="You are a shell command expert. For this task: '$*', provide the EXACT command(s) needed. Format as: 1) The precise command 2) One sentence explaining what it does 3) One practical tip. Be specific and actionable, not theoretical."
    local request_body=$(jq -n --arg prompt_content "$prompt" '{model: "sonar", messages: [{role: "user", content: $prompt_content}]}')
    local response_json=$(curl -sS --max-time 30 \
        -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "$request_body" "https://api.perplexity.ai/chat/completions" 2>/dev/null)
    local result_text=$(printf '%s' "$response_json" | jq -r '.choices[0].message.content // .error.message // "No response"')
    echo -e "\n\033[1;35m🎯 \033[1;37m$*\033[0m"
    echo -e "\033[35m▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\033[0m"
    local clean_text=$(printf '%s\n' "$result_text" | sed -e 's/\\n/\n/g' -e 's/\\t/\t/g' -e 's/\\r/\r/g')
    echo "$clean_text" | sed \
        -e 's/\*\*\([^*]*\)\*\*/\x1b[1;33m\1\x1b[0m/g' \
        -e 's/\[\([0-9]\+\)\]//g' \
        -e 's/```bash/\x1b[1;36m▶ \x1b[0;36m/g' \
        -e 's/```sh/\x1b[1;36m▶ \x1b[0;36m/g' \
        -e 's/```/\x1b[0m/g' \
        -e 's/`\([^`]*\)`/\x1b[1;37m\1\x1b[0m/g'
}

note() {
    local notes_dir="$HOME/notes"
    local today="$(date +%Y-%m-%d)"
    local file="$notes_dir/$today.md"
    mkdir -p "$notes_dir"
    if [[ -n "$1" ]]; then
        echo "$(date '+%H:%M') - $*" >> "$file"
        echo "✓ Note saved to $today.md"
    else
        [[ -f "$file" ]] || echo "# Notes for $today\n" > "$file"
        $EDITOR "$file"
    fi
}

# 10. ENHANCED FZF CONFIGURATION
# =============================================================================
if command -v fzf &>/dev/null; then
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    elif command -v rg &>/dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    export FZF_DEFAULT_OPTS="
        --height 60%
        --layout=reverse
        --border=rounded
        --preview-window=right:60%:wrap
        --bind='ctrl-y:execute-silent(echo -n {2..} | clip)+abort'
        --bind='ctrl-/:toggle-preview'
    "
    if command -v batcat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza --icons --color=always {} 2>/dev/null || ls -la {}; else batcat --color=always --line-range :500 {}; fi'"
    elif command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then eza --icons --color=always {} 2>/dev/null || ls -la {}; else bat --color=always --line-range :500 {}; fi'"
    fi
    export FZF_ALT_C_OPTS="--preview 'eza --icons --color=always {} 2>/dev/null || ls -la {}'"
    [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# 11. ENHANCED KEY BINDINGS
# =============================================================================
bindkey '^U' kill-whole-line
bindkey '^W' backward-kill-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# 12. EXTERNAL TOOL INTEGRATION (OPTIMIZED)
# =============================================================================
export _ZO_CASE_INSENSITIVE=1

if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    nvm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
        nvm "$@"
    }
    node() { nvm; node "$@"; }
    npm() { nvm; npm "$@"; }
    npx() { nvm; npx "$@"; }
fi

if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)" 2>/dev/null
fi

# 13. LOAD EXTERNAL CONFIGURATIONS
# =============================================================================
[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 14. CLAUDE MONITORING (OPTIMIZED)
# =============================================================================
alias claude-fix='~/.local/bin/claude-fix-monitor'
alias claude-emergency='curl -fsSL https://claude.ai/install.sh | bash'
{ sleep 10 && ~/.local/bin/claude-fix-monitor >/dev/null 2>&1 } &!

(( ! ${+functions[p10k]} )) || p10k finalize

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd j)" 2>/dev/null
fi

# Enable profiling results (uncomment to analyze)
# zprof

# =============================================================================
# 🚀 ENHANCED Configuration - Best of All Worlds!
# =============================================================================
