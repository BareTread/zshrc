# 🚀 Ultimate Z-Shell Configuration

The most useful, performant, and user-friendly Zsh configuration for Linux Mint (and other Debian-based systems).

![Zsh Version](https://img.shields.io/badge/zsh-5.8+-blue.svg)
![Linux Mint](https://img.shields.io/badge/Linux_Mint-21+-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## ✨ Features

- **⚡ Lightning Fast**: Startup time under 100ms with Zinit turbo mode
- **🎨 Beautiful**: Powerlevel10k prompt with instant prompt
- **🛠️ Modern CLI Tools**: Automatic setup of bat, eza, fzf, ripgrep, and more
- **🤖 AI Integration**: Built-in AI assistant powered by Gemini
- **🔧 Smart Fallbacks**: Works perfectly even if optional tools aren't installed
- **📦 Zero Errors**: Thoroughly tested on Linux Mint with proper error handling

## 🚀 Quick Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/zshrc/main/install.sh)"
```

## 📋 Manual Installation

1. **Install required packages**:
```bash
sudo apt update && sudo apt install -y zsh git curl jq fzf ripgrep bat fd-find trash-cli xclip neovim
```

2. **Download the configuration**:
```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/zshrc/main/.zshrc -o ~/.zshrc
```

3. **Set Zsh as default shell**:
```bash
chsh -s $(which zsh)
```

4. **Log out and log back in**

## 🎯 Most Useful Commands

| Command | Description |
|---------|-------------|
| `ff` | Find files with preview and edit |
| `pj` | Jump to project directories |
| `extract <file>` | Extract any archive format |
| `backup <file>` | Create timestamped backup |
| `ai "question"` | Ask AI anything |
| `explain <cmd>` | Get AI explanation of command |
| `suggest "task"` | Get command suggestion from AI |
| `mkcd <dir>` | Create directory and cd into it |
| `j <partial-name>` | Smart jump to directory (zoxide) |

## 🎨 Prompt Customization

Run `p10k configure` to customize your prompt appearance.

## 🤖 AI Setup

1. Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Add to `~/.secrets.zsh`:
```bash
export GEMINI_API_KEY='your-api-key-here'
```

## 🐛 Troubleshooting

### bat command not found
On Linux Mint/Ubuntu, bat is installed as `batcat`. This config automatically handles this.

### Slow startup
Run `zsh-time` to measure startup time. Should be under 100ms.

### Missing icons in ls
Install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/)

## 🔧 Customization

- Personal settings: Create `~/.zshrc.local`
- API keys and secrets: Create `~/.secrets.zsh`
- Machine-specific configs won't be overwritten by updates

## 📊 Performance

Typical startup times:
- With all plugins: ~80ms
- Minimal (no optional tools): ~30ms

## 🤝 Contributing

Contributions are welcome! Please:
1. Keep it lightweight
2. Test on Linux Mint/Ubuntu
3. Maintain backwards compatibility

## 📜 License

MIT License - feel free to use and modify!

## 🙏 Credits

- [Zinit](https://github.com/zdharma-continuum/zinit) - Plugin manager
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Prompt theme
- [bat](https://github.com/sharkdp/bat) - Better cat
- [eza](https://github.com/eza-community/eza) - Better ls
- All the amazing open source tools that make this possible

---

Made with ❤️ for the Linux Mint community