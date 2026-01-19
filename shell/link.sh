#!/bin/zsh

# スクリプトのディレクトリを取得（絶対パス）
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

files_and_paths=(
    "$PROJECT_ROOT/.zshrc":"$HOME/.zshrc"
    "$PROJECT_ROOT/serena_config.yml":"$HOME/.serena/serena_config.yml"
    "$PROJECT_ROOT/mcp.json":"$HOME/.cursor/mcp.json"
    "$PROJECT_ROOT/.claude.json":"$HOME/.claude.json"
)

create_symlink() {
  local source_file=$(realpath "$1")
  local destination_path=$2

  backup_file="${destination_path}.bk.$(date +%Y%m%d%H%M%S)"     # 退避先のファイル名

  if [ -e "$destination_path" ]; then
    mv "$destination_path" "$backup_file"
  fi

  ln -s "$source_file" "$destination_path"  # シンボリックリンクの作成
}

for entry in "${files_and_paths[@]}"; do
  IFS=":" read -r source_file destination_path <<< "$entry"
  create_symlink "$source_file" "$destination_path"
done
