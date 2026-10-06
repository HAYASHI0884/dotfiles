#!/bin/zsh

# Claude CodeのMCPサーバーをユーザースコープ（~/.claude.json、全プロジェクト共通）に登録するスクリプト
# 実行のたびに削除→登録し直すため、実行後は main() 内の定義と一致する

set -e

# カラー出力用の変数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 登録結果を記録
CONFIGURED=()
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

# claudeコマンドのパスを取得（PATHに無い場合はネイティブインストールの配置先を探す）
find_claude() {
    if command -v claude >/dev/null 2>&1; then
        command -v claude
    elif [ -x "$HOME/.local/bin/claude" ]; then
        echo "$HOME/.local/bin/claude"
    else
        return 1
    fi
}

# MCPサーバーを登録（同名のサーバーがあれば削除してから登録し直す）
# 使用例: add_mcp "server_name" command [args...]
add_mcp() {
    local name=$1
    shift

    log_info "Configuring MCP server: $name..."

    "$CLAUDE" mcp remove "$name" --scope user >/dev/null 2>&1 || true

    if "$CLAUDE" mcp add --scope user "$name" -- "$@" >/dev/null; then
        log_success "$name configured successfully"
        CONFIGURED+=("$name")
    else
        log_error "Failed to configure $name"
        FAILED+=("$name")
    fi
}

# メイン処理
main() {
    echo "=========================================="
    echo "  Claude Code MCP Setup Script"
    echo "=========================================="
    echo ""

    if ! CLAUDE=$(find_claude); then
        log_error "Claude Code is not installed. Please install Claude Code first."
        exit 1
    fi

    # MCPサーバーの定義（追加・変更はここで行う）
    add_mcp "context7" npx -y @upstash/context7-mcp
    add_mcp "drawio" npx -y @drawio/mcp

    # サマリー表示
    echo ""
    echo "=========================================="
    echo "  MCP Setup Summary"
    echo "=========================================="

    if [ ${#CONFIGURED[@]} -gt 0 ]; then
        echo -e "${GREEN}Configured:${NC}"
        for item in "${CONFIGURED[@]}"; do
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

    [ ${#FAILED[@]} -eq 0 ]
}

# スクリプト実行
main "$@"
