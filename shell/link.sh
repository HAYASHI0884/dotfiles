#!/bin/zsh

# スクリプトのディレクトリを取得（絶対パス）
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

files_and_paths=(
    "$PROJECT_ROOT/.zshrc":"$HOME/.zshrc"
    # "$PROJECT_ROOT/mcp/mcp.json":"$HOME/.cursor/mcp.json"
    "$PROJECT_ROOT/ghostty/config":"$HOME/.config/ghostty/config"
    "$PROJECT_ROOT/tmux/tmux.conf":"$HOME/.tmux.conf"
)

create_symlink() {
  local source_file=$(realpath "$1")
  local destination_path=$2

  backup_file="${destination_path}.bk.$(date +%Y%m%d%H%M%S)"     # 退避先のファイル名

  # すでに同名のシンボリックリンクが存在する場合はスキップ
  if [ -L "$destination_path" ]; then
    echo "スキップ: $destination_path は既にシンボリックリンクとして存在します"
    return
  fi

  # リンク先の親ディレクトリが無ければ作成
  mkdir -p "$(dirname "$destination_path")"

  if [ -e "$destination_path" ]; then
    mv "$destination_path" "$backup_file"
  fi

  ln -s "$source_file" "$destination_path"  # シンボリックリンクの作成
}

for entry in "${files_and_paths[@]}"; do
  IFS=":" read -r source_file destination_path <<< "$entry"
  create_symlink "$source_file" "$destination_path"
done
