# Alin’s Ultimate Z‑Shell (v7 - Now with AI!)

THIS is my attempt at Creating a lightweight and powerful config for zsh for the average user.
Especially useful for lifelong windows users transitioning to linux.

Your terminal, finally in the fast lane **and supercharged with AI**.
This repo ships a single, self‑contained **`~/.zshrc`** that boots in well under 100 ms, embraces modern Rust‑powered CLI tools, **integrates powerful AI helper functions,** and keeps the learning curve flat for beginners.

---

### ✨ Highlights

| Pillar                          | What you get                                                                                   | Why it matters                                                                                                                                       |
| ------------------------------- | ---------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **⚡ Instant prompt**            | Powerlevel10k’s *instant‑prompt* shows a usable cursor before the shell even finishes loading. | You can start typing while plugins hydrate in the background. ([Reddit][1])                                                                          |
| **🚀 zinit Turbo**              | All plugins lazy‑load after ZLE is ready.                                                      | Typical startup drops 50‑80 % vs. synchronous managers. ([Reddit][2])                                                                                |
| **🎨 fast‑syntax‑highlighting** | Async syntax colouring with negligible overhead.                                               | Faster than the legacy highlighter on large histories. ([GitHub][3])                                                                                 |
| **🧠 AI Integration**          | Direct terminal access to Google Gemini & Perplexity AI.                                      | Query powerful AI models, get web-searches, and stream responses without leaving Zsh.                                                                 |
| **🏃 Modern CLI stack**         | `eza`, `bat`, `ripgrep`, `fd`, `erdtree`, `procs`, `sd`, `git‑delta`.                          | Each is faster & more ergonomic than its Unix ancestor. ([GitHub][4], [GitHub][5], [GitHub][6], [Reddit][7], [GitHub][8], [GitHub][9], [GitHub][10]) |
| **🧭 Smarter navigation**       | `zoxide` ← frecency‑based `cd`; `fzf` everywhere; `Atuin` for fuzzy, encrypted history.        | Jump to any dir or command with a few keystrokes. ([GitHub][11], [GitHub][12], [atuin.sh][13])                                                       |
| **🗑️ Safe deletes**            | `rm` is aliased to `trash-put` from **trash‑cli**.                                             | Accidents are reversible. ([Ask Ubuntu][14])                                                                                                         |
| **📦 Per‑project envs**         | **direnv** hooks load `.envrc` automatically.                                                  | Keep API keys out of global scope. ([direnv][15])                                                                                                    |

---

## 🚀 Quick install

1.  **Clone the repo**:
    ```bash
    # Replace <your-user> with your GitHub username if you fork it
    # Or use your actual repository URL
    git clone https://github.com/<your-user>/ultimate-zsh.git 
    cd ultimate-zsh
    ```

2.  **Backup existing `.zshrc`** (optional but recommended):
    ```bash
    cp ~/.zshrc ~/.zshrc.bak 2>/dev/null || true
    ```

3.  **Copy the config**:
    ```bash
    # Assuming the zshrc file in the repo is named 'zshrc' or '.zshrc'
    # If you are in the cloned 'ultimate-zsh' directory:
    cp zshrc ~/.zshrc 
    # Or if the file in the repo is .zshrc:
    # cp .zshrc ~/.zshrc
    ```

4.  **Install dependencies** (Example for Mint/Ubuntu):
    ```bash
    sudo apt update && sudo apt install -y \
      zsh git curl fzf ripgrep bat eza fd-find procs erdtree sd \
      zoxide direnv trash-cli xclip atuin git-delta jq
    ```
    *(Note: `jq` is required for the AI helper functions.)*

5.  **Set up API Keys for AI Helpers**:
    *   Create a `~/.secrets.zsh` file (if it doesn't exist). This file should **not** be committed to Git. Add your API keys:
        ```zsh
        # ~/.secrets.zsh
        export GEMINI_API_KEY="YOUR_GEMINI_API_KEY_HERE"
        export PERPLEXITY_API_KEY="YOUR_PERPLEXITY_API_KEY_HERE"
        ```
    *   Ensure this file is sourced by your `.zshrc`. The provided `.zshrc` should contain a line like:
        `[[ -f ~/.secrets.zsh ]] && source ~/.secrets.zsh`

6.  **Make Zsh your login shell**:
    ```bash
    chsh -s "$(which zsh)"
    ```

7.  **Open a new terminal** – enjoy the speed and the new AI commands!

> **Tip:** On first launch zinit will auto‑clone plugins; subsequent starts are instant.

---

## 🤖 AI Helper Functions

This configuration includes powerful functions to interact with AI models directly from your terminal.

*   **`ai "prompt"`**:
    *   Sends your prompt to the Google Gemini API.
    *   Default model: `gemini-2.0-flash` (can be overridden with `GEMINI_MODEL` environment variable).
*   **`q "prompt"`**:
    *   Sends your prompt to the Google Gemini API with real-time streaming of the response.
*   **`px "prompt"`**:
    *   Sends your prompt to Perplexity AI for web-enabled search queries.
    *   Uses the `sonar-pro` model by default.
*   **Flexible Input**: All AI commands support:
    *   Direct arguments (e.g., `ai "What is the weather?"`).
    *   Piped input (e.g., `echo "Some text" | q "Summarize this"`).
    *   Combined piped input and arguments (e.g., `cat file.txt | px "What are the key points regarding AI?"`).
*   **Debugging**:
    *   Set `AIDEBUG=1` before a command (e.g., `AIDEBUG=1 ai "test"`) for verbose debug output.

### Usage Examples:

**Google Gemini (`ai` and `q`)**
```zsh
# Basic query
ai "What is the capital of Japan?"

# Streaming query
q "Write a short poem about coding."

# Using piped input
echo "The Z shell is a powerful tool." | ai "Explain this in simple terms."

# Debugging
AIDEBUG=1 q "Why is the sky blue?"
```

**Perplexity AI (`px`)**
```zsh
# Web-enabled search
px "What are the latest developments in quantum computing?"

# Piped input with a question
cat report.txt | px "Summarize the main findings of this document."

# Debugging
AIDEBUG=1 px "Who won the last F1 race?"
```

---

## 🛠️ Plugin & tool overview

(Your existing content for this section is great, I've kept it as is.)

| Component                    | Purpose                                           |
| ---------------------------- | ------------------------------------------------- |
| **zinit**                    | Lazy plugin manager with Turbo mode               |
| **Powerlevel10k**            | Theme with async Git info & instant prompt        |
| **fast‑syntax‑highlighting** | Lightweight Zsh syntax colours                    |
| **zsh‑autosuggestions**      | Fish‑style command prediction                     |
| **fzf‑bin**                  | Pre‑compiled fuzzy finder + key‑bindings          |
| **zoxide**                   | Frecency‑based `cd` (`j <dir>` or `zi <pattern>`) |
| **Atuin**                    | SQLite + encrypted history search (`Ctrl‑R`)      |
| **hlissner/zsh‑autopair**    | Automatic bracket/quote closing                   |

---

## 🎯 Key bindings & Aliases (Standard)

(AI command aliases `ai`, `q`, `px` are detailed in the "AI Helper Functions" section above.)

| Binding / Alias    | Action                                                |
| ------------------ | ----------------------------------------------------- |
| `Ctrl‑R` (Atuin)   | Fuzzy search entire history                           |
| `Ctrl‑T` / `Alt‑C` | Fuzzy‑open files / dirs via ripgrep                   |
| `j src`            | Jump to most‑visited directory matching *src*         |
| `rgi pattern`      | Interactive ripgrep → open in editor                  |
| `mkcd newdir`      | Make & `cd` into *newdir*                             |
| `serve 9000`       | Quick local web server on port 9000                   |
| `please`           | Rerun previous command with `sudo`                    |
| `rm`               | Sends files to system trash, **not** permanent delete |

---

## 📈 Benchmarks

(Your existing content for this section is great, I've kept it as is.)

| Shell manager          | Cold‑start time (Dell XPS 13, Mint 21) |
| ---------------------- | -------------------------------------- |
| Oh My Zsh (15 plugins) | **420 ms**                             |
| zinit Turbo (same set) | **92 ms**                              |
| *This config*          | **< 70 ms** (after zinit compile)      |

---

## 🤝 Contributing

(Your existing content for this section is great, I've kept it as is.)

1. Fork the repo and create a branch.
2. Make your change—keep comments clear and commits atomic.
3. Open a PR; describe *why* the tweak helps speed or usability.
4. All merged code is auto‑linted by `shellcheck` and `zunit`.

---

## 📜 License

(Your existing content for this section is great, I've kept it as is.)

MIT — do whatever you like, just credit the original authors of the individual plugins and CLI tools.

---

### 🙏 Credits

(Your existing content for this section is great, I've kept it as is, including your links.)

Huge thanks to every OSS maintainer whose work makes the terminal a joy:
\[zinit] ([Reddit][2]), \[Powerlevel10k] ([Reddit][1]), \[fast‑syntax‑highlighting] ([GitHub][3]), \[zoxide] ([GitHub][11]), \[fzf] ([GitHub][12]), \[Atuin] ([atuin.sh][13]), \[ripgrep] ([GitHub][6]), \[bat] ([GitHub][5]), \[eza] ([GitHub][4]), \[delta] ([GitHub][10]) and many more.

[1]: https://www.reddit.com/r/zsh/comments/dk53ow/new_powerlevel10k_feature_instant_prompt/?utm_source=chatgpt.com "New Powerlevel10k Feature: Instant Prompt : r/zsh - Reddit"
[2]: https://www.reddit.com/r/zinit/comments/orincv/how_can_i_use_turbo_mode_to_speed_up_my_zsh/?utm_source=chatgpt.com "How can I use turbo mode to speed up my zsh startup? : r/zinit - Reddit"
[3]: https://github.com/zdharma-continuum/fast-syntax-highlighting?utm_source=chatgpt.com "zdharma-continuum/fast-syntax-highlighting - GitHub"
[4]: https://github.com/eza-community/eza?utm_source=chatgpt.com "eza-community/eza: A modern alternative to ls - GitHub"
[5]: https://github.com/sharkdp/bat?utm_source=chatgpt.com "sharkdp/bat: A cat(1) clone with wings. - GitHub"
[6]: https://github.com/BurntSushi/ripgrep?utm_source=chatgpt.com "ripgrep recursively searches directories for a regex pattern ... - GitHub"
[7]: https://www.reddit.com/r/rust/comments/11ioq1n/erdtree_v120_a_modern_multithreaded_alternative/?utm_source=chatgpt.com "erdtree v1.2.0, a modern multi-threaded alternative to `du` and `tree ..."
[8]: https://github.com/dalance/procs?utm_source=chatgpt.com "dalance/procs: A modern replacement for ps written in Rust - GitHub"
[9]: https://github.com/chmln/sd?utm_source=chatgpt.com "chmln/sd: Intuitive find & replace CLI (sed alternative) - GitHub"
[10]: https://github.com/dandavison/delta?utm_source=chatgpt.com "dandavison/delta: A syntax-highlighting pager for git, diff, grep, and ..."
[11]: https://github.com/ajeetdsouza/zoxide?utm_source=chatgpt.com "ajeetdsouza/zoxide: A smarter cd command. Supports all major shells."
[12]: https://github.com/junegunn/fzf?utm_source=chatgpt.com "junegunn/fzf: :cherry_blossom: A command-line fuzzy finder - GitHub"
[13]: https://atuin.sh/?utm_source=chatgpt.com "Atuin - Magical Shell History"
[14]: https://askubuntu.com/questions/468721/how-can-i-empty-the-trash-using-terminal?utm_source=chatgpt.com "How can I empty the trash using terminal? - Ask Ubuntu"
[15]: https://direnv.net/?utm_source=chatgpt.com "direnv – unclutter your .profile | direnv"
