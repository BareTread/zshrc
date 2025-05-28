    # =============================================================================
    #  🚀 Ultimate Z-Shell Configuration — v12.0 (Linux Mint · May 2025)
    # =============================================================================
    # Focus      : ⚡ Zero errors • Fast startup • Modern CLI • AI helpers • Security
    # Plugin mgr : zinit (turbo mode for 50-80% faster startup)
    # Prompt     : powerlevel10k (instant-prompt with zero warnings)
    # Platform   : Optimized for Linux Mint (Debian/Ubuntu compatible)
    # -----------------------------------------------------------------------------
    # QUICK INSTALL:
    # bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/zshrc/main/install.sh)"
    # 
    # MANUAL SETUP:
    # sudo apt update && sudo apt install -y zsh git curl jq fzf ripgrep bat eza \
    #     fd-find zoxide trash-cli xclip neovim btop
    # chsh -s $(which zsh)
    # -----------------------------------------------------------------------------

    ### 0 ▸ Pre-flight checks & instant prompt ###################################
    # Create necessary directories (suppress all errors)
    {
    mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" \
            "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" \
            "${XDG_DATA_HOME:-$HOME/.local/share}/zsh" \
            "$HOME/.local/bin"
    } &>/dev/null

    # Ensure quiet operation with no warning messages
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

    # Enable Powerlevel10k instant prompt (MUST BE FIRST)
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    ### 1 ▸ Zinit bootstrap (auto-install) #######################################
    ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
    if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}ZINIT%F{220} Plugin Manager…%f"
    command mkdir -p "${ZINIT_HOME:h}" && \
    command git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" && \
    print -P "%F{33}▓▒░ %F{34}ZINIT installation successful.%f" || \
    print -P "%F{160}▓▒░ ZINIT installation failed.%f"
    fi
    source "$ZINIT_HOME/zinit.zsh"

    ### 2 ▸ Core environment & settings ##########################################
    # Skip global compinit (zinit handles it)
    skip_global_compinit=1

    # Terminal and editor
    export TERM="${TERM:-xterm-256color}"
    export EDITOR="${EDITOR:-nvim}"
    export VISUAL="$EDITOR"
    export BROWSER="${BROWSER:-firefox}"

    # Language and locale
    export LANG="${LANG:-en_US.UTF-8}"
    export LC_ALL="${LC_ALL:-en_US.UTF-8}"

    # Pager configuration - FIXED for Linux Mint bat/batcat issue
    if command -v batcat &>/dev/null; then
    export PAGER="batcat --style=plain --paging=always"
    export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
    elif command -v bat &>/dev/null; then
    export PAGER="bat --style=plain --paging=always"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    else
    export PAGER="less -R"
    fi

    # History configuration (optimal settings)
    HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
    HISTSIZE=50000
    SAVEHIST=30000
    setopt EXTENDED_HISTORY          # Write timestamp to history
    setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
    setopt HIST_IGNORE_DUPS          # Don't record duplicates
    setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded duplicates
    setopt HIST_FIND_NO_DUPS         # Don't display duplicates
    setopt HIST_IGNORE_SPACE         # Don't record lines starting with space
    setopt HIST_SAVE_NO_DUPS         # Don't write duplicates
    setopt HIST_VERIFY               # Don't execute immediately on expansion
    setopt SHARE_HISTORY             # Share history between sessions

    # Shell options
    setopt AUTO_CD                   # Change directory without cd
    setopt AUTO_PUSHD                # Push directories onto stack
    setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
    setopt CDABLE_VARS               # Expand parameters in cd
    setopt NO_BEEP                   # Disable beep
    setopt INTERACTIVE_COMMENTS      # Allow comments in interactive mode
    setopt EXTENDED_GLOB             # Extended globbing
    setopt NO_NOMATCH                # Don't error on failed glob

    # Path configuration (remove duplicates)
    typeset -U path PATH
    path=("$HOME/.local/bin" "$HOME/bin" $path)
    export PATH

    ### 3 ▸ Plugin loading (optimized order with turbo mode) #####################
    # Theme - loaded immediately for instant prompt
    zinit ice depth=1
    zinit light romkatv/powerlevel10k

    # Essential plugins with turbo mode
    zinit wait lucid for \
        atinit"zicompinit; zicdreplay" \
            zdharma-continuum/fast-syntax-highlighting \
        atload"_zsh_autosuggest_start" \
            zsh-users/zsh-autosuggestions \
        blockf atpull'zinit creinstall -q .' \
            zsh-users/zsh-completions

    # Helper function for history-substring-search keybindings
    _bind_history_substring_search_keys() {
    # Check if widgets exist before binding, though atload should ensure this
    if zle -l | grep -q history-substring-search-up; then
        bindkey '^[[A' history-substring-search-up
    else
        bindkey '^[[A' up-line-or-history # Fallback if widget somehow not found
    fi
    if zle -l | grep -q history-substring-search-down; then
        bindkey '^[[B' history-substring-search-down
    else
        bindkey '^[[B' down-line-or-history # Fallback
    fi
    }

    # Additional plugins
    zinit wait"0b" lucid \
        atload'_bind_history_substring_search_keys' for \
        zsh-users/zsh-history-substring-search

    zinit wait"0b" lucid for \
        hlissner/zsh-autopair

    # OMZ snippets (only the essentials)
    zinit wait"0c" lucid for \
        OMZL::git.zsh \
        OMZL::key-bindings.zsh \
        OMZP::git

    ### 4 ▸ Autosuggestions configuration #######################################
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_USE_ASYNC=1

    ### 5 ▸ Completion system configuration ######################################
    # Completion styling
    zstyle ':completion:*' menu select
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

    ### 6 ▸ Key bindings #########################################################
    # Additional useful bindings
    bindkey '^[[H' beginning-of-line
    bindkey '^[[F' end-of-line
    bindkey '^[[3~' delete-char
    bindkey '^[[1;5C' forward-word
    bindkey '^[[1;5D' backward-word

    ### 7 ▸ Modern CLI aliases (with Linux Mint fixes) ###########################
    # Safety first
    alias rm='trash-put 2>/dev/null || rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
    alias mkdir='mkdir -pv'

    # CRITICAL FIX: bat/batcat for Linux Mint/Ubuntu/Debian
    if command -v batcat &>/dev/null; then
    alias bat='batcat'
    alias cat='batcat --style=plain --paging=never'
    alias catp='batcat --style=plain'
    alias catl='batcat --style=numbers,header --line-range :500'
    export BAT_THEME="Nord"
    elif command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias catp='bat --style=plain'
    alias catl='bat --style=numbers,header --line-range :500'
    export BAT_THEME="Nord"
    fi

    # Enhanced ls with fallbacks
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

    # Modern CLI replacements
    command -v procs &>/dev/null && alias ps='procs'
    command -v btop &>/dev/null && alias top='btop' || { command -v htop &>/dev/null && alias top='htop'; }
    command -v duf &>/dev/null && alias df='duf'
    command -v fd &>/dev/null && alias find='fd'
    command -v rg &>/dev/null && alias grep='rg'
    command -v delta &>/dev/null && git config --global core.pager delta

    # Navigation shortcuts
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias ~='cd ~'
    alias -- -='cd -'

    # Git shortcuts (most useful)
    alias g='git'
    alias gs='git status -sb'
    alias ga='git add'
    alias gc='git commit -v'
    alias gp='git push'
    alias gl='git pull'
    alias gd='git diff'
    alias gco='git checkout'
    alias glog='git log --oneline --decorate --graph'

    # System shortcuts
    alias update='sudo apt update && sudo apt upgrade'
    alias install='sudo apt install'
    alias search='apt search'
    alias reload='exec $SHELL -l'

    ### 8 ▸ FZF configuration ####################################################
    if command -v fzf &>/dev/null; then
    # Use fd or ripgrep for better performance
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    elif command -v rg &>/dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # Enhanced FZF options
    export FZF_DEFAULT_OPTS="
        --height 60%
        --layout=reverse
        --border=rounded
        --preview-window=right:60%:wrap
        --bind='ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort'
        --bind='ctrl-/:toggle-preview'
    "

    # Preview commands - Fixed for bat/batcat
    if command -v batcat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then ls -la {}; else batcat --color=always --line-range :500 {}; fi'"
    elif command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'if [ -d {} ]; then ls -la {}; else bat --color=always --line-range :500 {}; fi'"
    fi

    # Load FZF
    [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi

    ### 9 ▸ Essential helper functions ###########################################
    # Create directory and cd into it
    mkcd() {
    mkdir -p "$1" && cd "$1"
    }

    # Extract archives
    extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.tar.xz)    tar xJf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.zip)       unzip "$1"       ;;
        *.7z)        7z x "$1"        ;;
        *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
    }

    # Quick file finder with preview
    ff() {
    local file
    if command -v fzf &>/dev/null; then
        file=$(fzf --preview 'batcat --color=always {} 2>/dev/null || bat --color=always {} 2>/dev/null || cat {}')
        [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
    else
        echo "fzf not found. Install with: sudo apt install fzf"
    fi
    }

    # Project finder
    pj() {
    local dir
    local search_dirs=(~/projects ~/code ~/work ~/Documents/projects)
    local existing_dirs=()
    
    for d in "${search_dirs[@]}"; do
        [[ -d "$d" ]] && existing_dirs+=("$d")
    done
    
    if [[ ${#existing_dirs[@]} -eq 0 ]]; then
        echo "No project directories found. Create one of: ${search_dirs[*]}"
        return 1
    fi
    
    if command -v fzf &>/dev/null; then
        dir=$(find "${existing_dirs[@]}" -maxdepth 2 -type d -name ".git" 2>/dev/null | 
            sed 's/\/\.git$//' | sort -u | 
            fzf --preview "ls -la {}")
        [[ -n "$dir" ]] && cd "$dir"
    fi
    }

    # Backup file with timestamp
    backup() {
    [[ -z "$1" ]] && { echo "Usage: backup <file>"; return 1; }
    cp "$1" "$1.$(date +%Y%m%d_%H%M%S).bak"
    }

    # Change to directory and list contents
    chpwd() {
    [[ "$PWD" != "$HOME" ]] && ls
    }

    ### 10 ▸ Simplified AI helpers ###############################################
    # Gemini AI helper
    ai() {
    # Check dependencies
    if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
        echo "Error: curl and jq are required. Install with: sudo apt install curl jq" >&2
        return 1
    fi
    
    [[ -z "$GEMINI_API_KEY" ]] && {
        echo "Error: GEMINI_API_KEY not set. Add to ~/.secrets.zsh:" >&2
        echo "  export GEMINI_API_KEY='your-api-key-here'" >&2
        echo "Get your key from: https://makersuite.google.com/app/apikey" >&2
        return 1
    }
    
    local prompt="$*"
    [[ -z "$prompt" ]] && { echo "Usage: ai <your question>"; return 1; }
    
    local response=$(curl -sS "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$GEMINI_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "$(jq -n --arg text "$prompt" '{contents:[{parts:[{text:$text}]}]}')" \
        2>/dev/null)
    
    echo "$response" | jq -r '.candidates[0].content.parts[0].text // "Error: No response"' 2>/dev/null || echo "Error: Failed to parse response"
    }

    # Perplexity AI helper
    px() {
    # Check dependencies
    if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
        echo "Error: curl and jq are required. Install with: sudo apt install curl jq" >&2
        return 1
    fi

    [[ -z "$PERPLEXITY_API_KEY" ]] && {
        echo "Error: PERPLEXITY_API_KEY not set. Add to ~/.secrets.zsh:" >&2
        echo "  export PERPLEXITY_API_KEY='your-perplexity-api-key-here'" >&2
        echo "Get your key from: https://www.perplexity.ai/settings/api" >&2
        return 1
    }

    local prompt_text="$*"
    [[ -z "$prompt_text" ]] && { echo "Usage: px <your question>"; return 1; }

    local model_name="${PERPLEXITY_MODEL:-sonar-pro}"

    local request_body
    request_body=$(jq -n --arg prompt_content "$prompt_text" --arg model_name "$model_name" \
        '{model: $model_name, messages: [{role: "user", content: $prompt_content}]}')

    local response_json
    response_json=$(curl -sS --max-time 30 \
        -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
        -H 'Content-Type: application/json' \
        -d "$request_body" "https://api.perplexity.ai/chat/completions" 2>/dev/null)

    local cleaned_response_json
    cleaned_response_json=$(printf '%s' "$response_json" | awk '{
        gsub(/\r/, "\\r"); 
        gsub(/\n/, "\\n"); 
        gsub(/\t/, "\\t"); 
        print;
    }')

    local result_text
    result_text=$(printf '%s' "$cleaned_response_json" | jq -r '.choices[0].message.content' 2>/dev/null)

    if [[ -z "$result_text" || "$result_text" == "null" ]]; then
        result_text=$(printf '%s' "$response_json" | jq -r '.choices[0].message.content' 2>/dev/null)
    fi

    if [[ -z "$result_text" || "$result_text" == "null" ]]; then
        local error_message=$(printf '%s' "$response_json" | jq -r '.error.message // ""')
        if [[ -n "$error_message" ]]; then
            echo "Error from Perplexity API: $error_message" >&2
        else
            echo "Error: No valid response or failed to parse content from Perplexity API." >&2
            echo "Debug: Original Response: $response_json" >&2 # Uncommented for debugging
            echo "Debug: Cleaned Response: $cleaned_response_json" >&2 # Uncommented for debugging
        fi
        return 1
    fi
    
    printf '%s\n' "$result_text" | sed -e 's/\\n/\n/g' -e 's/\\t/\t/g' -e 's/\\r/\r/g'
    }

    # AI-powered command explainer
    explain() {
    [[ -z "$*" ]] && { echo "Usage: explain <command>"; return 1; }
    ai "Explain this shell command: $*"
    }

    # AI-powered command suggester
    suggest() {
    [[ -z "$*" ]] && { echo "Usage: suggest <what you want to do>"; return 1; }
    ai "Suggest a shell command to: $*. Give just the command, no explanation."
    }

    ### 11 ▸ Clipboard integration ###############################################
    if command -v xclip &>/dev/null; then
    alias copy='xclip -selection clipboard'
    alias paste='xclip -selection clipboard -out'
    alias cpwd='pwd | tr -d "\n" | xclip -selection clipboard'
    alias copylast='fc -ln -1 | xclip -selection clipboard'
    fi

    ### 12 ▸ Performance monitoring ##############################################
    # Shell startup profiling
    zsh-time() {
    time zsh -i -c exit
    }

    ### 13 ▸ External tool integration ###########################################
    # Zoxide (better cd)
    if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd j)"
    fi

    # direnv integration
    if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
    fi

    # nvm (lazy load for performance)
    if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    nvm() {
        unset -f nvm
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        nvm "$@"
    }
    fi

    ### 14 ▸ Load local configs ##################################################
    # Load secrets (API keys, etc.)
    [[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh || {
    echo "Tip: Create ~/.secrets.zsh for API keys (example content):"
    echo "  export GEMINI_API_KEY='your-gemini-key-here'"
    echo "  export PERPLEXITY_API_KEY='your-perplexity-key-here'"
    }

    # Load local customizations
    [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

    # Load Powerlevel10k configuration
    [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

    # =============================================================================
    # 🚀 Ultimate Z-Shell Configuration v12.0 - Complete!
    # =============================================================================
    # 
    # Next steps:
    # 1. Run 'p10k configure' to customize your prompt
    # 2. Create ~/.secrets.zsh with your API keys
    # 3. Test AI commands: ai "hello", explain ls, suggest "find large files"
    # 
    # Most useful commands:
    # - ff             : Find and edit files with preview
    # - pj             : Jump to projects
    # - extract <file> : Extract any archive
    # - backup <file>  : Create timestamped backup
    # - ai <question>  : Ask AI anything
    # - j <dir>        : Smart directory jump (if zoxide installed)
    # 
    # Performance: Run 'zsh-time' to measure startup time
    # =============================================================================