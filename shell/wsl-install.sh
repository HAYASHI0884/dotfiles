#!/bin/zsh

set -e

# スクリプトのディレクトリを取得（絶対パス）
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# カラー出力用の変数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# インストール結果を記録
INSTALLED=()
SKIPPED=()
FAILED=()

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# コマンドが存在するかチェック
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ディレクトリが存在するかチェック
dir_exists() {
    [ -d "$1" ]
}

# brewのインストール
install_brew() {
    log_info "Checking for Homebrew (Linuxbrew)..."
    if command_exists brew; then
        log_warn "Homebrew is already installed. Skipping."
        SKIPPED+=("brew")
        return 0
    fi

    log_info "Installing Homebrew (Linuxbrew)..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_success "Homebrew installed successfully"
        INSTALLED+=("brew")

        # shellenvを設定（このセッション用）
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
        return 0
    else
        log_error "Failed to install Homebrew"
        FAILED+=("brew")
        return 1
    fi
}

# brewでツールをインストール
install_with_brew() {
    local tool=$1
    log_info "Checking for $tool..."

    if command_exists "$tool"; then
        log_warn "$tool is already installed. Skipping."
        SKIPPED+=("$tool")
        return 0
    fi

    # brewが利用可能かチェック
    if ! command_exists brew; then
        log_error "Homebrew is not installed. Please install Homebrew first."
        FAILED+=("$tool")
        return 1
    fi

    log_info "Installing $tool with Homebrew..."
    if brew install "$tool"; then
        log_success "$tool installed successfully"
        INSTALLED+=("$tool")
        return 0
    else
        log_error "Failed to install $tool"
        FAILED+=("$tool")
        return 1
    fi
}

# curl経由でインストール（汎用関数）
# 使用例: install_with_curl "tool_name" "check_command" "https://example.com/install.sh"
install_with_curl() {
    local name=$1
    local check_cmd=$2
    local url=$3

    log_info "Checking for $name..."

    if command_exists "$check_cmd"; then
        log_warn "$name is already installed. Skipping."
        SKIPPED+=("$name")
        return 0
    fi

    log_info "Installing $name..."
    if curl -fsSL "$url" | bash; then
        log_success "$name installed successfully"
        INSTALLED+=("$name")
        return 0
    else
        log_error "Failed to install $name"
        FAILED+=("$name")
        return 1
    fi
}

# nvmのインストール
install_nvm() {
    log_info "Checking for nvm..."

    if dir_exists "$HOME/.nvm"; then
        log_warn "nvm is already installed. Skipping."
        SKIPPED+=("nvm")
        return 0
    fi

    log_info "Installing nvm..."
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash; then
        log_success "nvm installed successfully"
        INSTALLED+=("nvm")
        return 0
    else
        log_error "Failed to install nvm"
        FAILED+=("nvm")
        return 1
    fi
}

# oh-my-zshのインストール
install_ohmyzsh() {
    log_info "Checking for Oh My Zsh..."

    if dir_exists "$HOME/.oh-my-zsh"; then
        log_warn "Oh My Zsh is already installed. Skipping."
        SKIPPED+=("oh-my-zsh")
        return 0
    fi

    log_info "Installing Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        log_success "Oh My Zsh installed successfully"
        INSTALLED+=("oh-my-zsh")
        return 0
    else
        log_error "Failed to install Oh My Zsh"
        FAILED+=("oh-my-zsh")
        return 1
    fi
}

# oh-my-zshプラグインのインストール
install_ohmyzsh_plugin() {
    local plugin=$1
    local repo=$2
    local plugin_dir="$ZSH_CUSTOM/plugins/$plugin"

    log_info "Checking for Oh My Zsh plugin: $plugin..."

    if dir_exists "$plugin_dir"; then
        log_warn "$plugin plugin is already installed. Skipping."
        SKIPPED+=("$plugin")
        return 0
    fi

    # ZSH_CUSTOMが設定されていない場合はデフォルト値を使用
    if [ -z "$ZSH_CUSTOM" ]; then
        ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
    fi

    log_info "Installing $plugin plugin..."
    if git clone "$repo" "$plugin_dir" 2>/dev/null; then
        log_success "$plugin plugin installed successfully"
        INSTALLED+=("$plugin")
        return 0
    else
        log_error "Failed to install $plugin plugin"
        FAILED+=("$plugin")
        return 1
    fi
}

# zshのインストール（apt経由）
install_zsh() {
    log_info "Checking for zsh..."

    if command_exists zsh; then
        log_warn "zsh is already installed. Skipping."
        SKIPPED+=("zsh")
        return 0
    fi

    log_info "Installing zsh with apt..."
    if sudo apt-get update && sudo apt-get install -y zsh; then
        log_success "zsh installed successfully"
        INSTALLED+=("zsh")
        return 0
    else
        log_error "Failed to install zsh"
        FAILED+=("zsh")
        return 1
    fi
}

# Claude Code用スキルを ~/.claude/skills/<name> に配置（ツール本体のバージョンに合わせて生成し、差分がある場合のみ更新）
# 生成関数は一時ディレクトリをカレントとして実行され、その中に .claude/skills/<name>/ を作成すること
# 使用例: install_skill "skill_name" "required_command" generator_function
install_skill() {
    local name=$1
    local required_cmd=$2
    local generator=$3
    local target_dir="$HOME/.claude/skills/$name"
    local tmp_dir

    log_info "Checking for $name skill..."

    if ! command_exists "$required_cmd"; then
        log_error "$required_cmd is not installed. Please install $required_cmd first."
        FAILED+=("$name-skill")
        return 1
    fi

    tmp_dir=$(mktemp -d)
    if ! (cd "$tmp_dir" && "$generator") >/dev/null || [ ! -d "$tmp_dir/.claude/skills/$name" ]; then
        rm -rf "$tmp_dir"
        log_error "Failed to generate $name skill"
        FAILED+=("$name-skill")
        return 1
    fi

    if [ -d "$target_dir" ] && diff -r "$tmp_dir/.claude/skills/$name" "$target_dir" >/dev/null 2>&1; then
        rm -rf "$tmp_dir"
        log_warn "$name skill is already up to date. Skipping."
        SKIPPED+=("$name-skill")
        return 0
    fi

    log_info "Installing $name skill to $target_dir..."
    mkdir -p "$(dirname "$target_dir")"
    rm -rf "$target_dir"
    mv "$tmp_dir/.claude/skills/$name" "$target_dir"
    rm -rf "$tmp_dir"
    log_success "$name skill installed successfully"
    INSTALLED+=("$name-skill")
    return 0
}

# herdrのスキルを生成（herdr --skill の出力を SKILL.md として保存）
generate_herdr_skill() {
    mkdir -p .claude/skills/herdr
    herdr --skill > .claude/skills/herdr/SKILL.md
}

# playwright-cliのスキルを生成（カレントディレクトリの .claude/skills/playwright-cli/ に出力される）
generate_playwright_cli_skill() {
    playwright-cli install --skills
}

# Claude CodeのMCPサーバーを登録（登録内容は claude-mcp.sh で管理）
setup_claude_mcp() {
    log_info "Checking for Claude Code..."

    if ! command_exists claude && [ ! -x "$HOME/.local/bin/claude" ]; then
        log_warn "Claude Code is not installed. Skipping MCP setup."
        SKIPPED+=("claude-mcp")
        return 0
    fi

    if zsh "$SCRIPT_DIR/claude-mcp.sh"; then
        INSTALLED+=("claude-mcp")
        return 0
    else
        log_error "Failed to set up Claude Code MCP servers"
        FAILED+=("claude-mcp")
        return 1
    fi
}

# メイン処理
main() {
    echo "=========================================="
    echo "  Dotfiles Installation Script"
    echo "=========================================="
    echo ""

    # zshのインストール（最初に必要）
    install_zsh

    # brewのインストール（他のツールの前提条件）
    install_brew

    # brewの環境変数を設定（このセッション用）
    if command_exists brew; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
    fi

    # brewでインストール可能なもの
    install_with_brew "nvim"
    install_with_brew "gh"
    install_with_brew "mise"
    install_with_brew "ctop"
    install_with_brew "peco"
    install_with_brew "lazygit"
    install_with_brew "git-delta"
    install_with_brew "uv"
    install_with_brew "tmux"
    install_with_brew "herdr"
    install_with_brew "playwright-cli"

    # Claude Code用スキルの配置
    install_skill "herdr" "herdr" generate_herdr_skill
    install_skill "playwright-cli" "playwright-cli" generate_playwright_cli_skill

    # nvmのインストール（gitから）
    install_nvm

    # curl経由でインストールするツール
    install_with_curl "claude-code" "claude" "https://claude.ai/install.sh"

    # oh-my-zshのインストール
    install_ohmyzsh

    # oh-my-zshプラグインのインストール
    if dir_exists "$HOME/.oh-my-zsh"; then
        export ZSH="$HOME/.oh-my-zsh"
        export ZSH_CUSTOM="$ZSH/custom"

        install_ohmyzsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
        install_ohmyzsh_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
    fi

    # Claude CodeのMCPサーバーを登録
    setup_claude_mcp

    # サマリー表示
    echo ""
    echo "=========================================="
    echo "  Installation Summary"
    echo "=========================================="

    if [ ${#INSTALLED[@]} -gt 0 ]; then
        echo -e "${GREEN}Installed:${NC}"
        for item in "${INSTALLED[@]}"; do
            echo "  - $item"
        done
        echo ""
    fi

    if [ ${#SKIPPED[@]} -gt 0 ]; then
        echo -e "${YELLOW}Skipped (already installed):${NC}"
        for item in "${SKIPPED[@]}"; do
            echo "  - $item"
        done
        echo ""
    fi

    if [ ${#FAILED[@]} -gt 0 ]; then
        echo -e "${RED}Failed:${NC}"
        for item in "${FAILED[@]}"; do
            echo "  - $item"
        done
        echo ""
    fi

    echo "=========================================="
}

# スクリプト実行
main "$@"
