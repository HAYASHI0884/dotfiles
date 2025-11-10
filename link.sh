#!/bin/zsh

files_and_paths=(
    ".zshrc":"$HOME/.zshrc"
)

create_symlink() {
  local source_file=$(realpath $1)
  local destination_path=$2

  backup_file="${destination_path}.bk"     # 退避先のファイル名

  if [ -e "$destination_path" ]; then
    mv "$destination_path" "$backup_file"
  fi

  ln -s "$source_file" "$destination_path"  # シンボリックリンクの作成
}

for entry in "${files_and_paths[@]}"; do
  IFS=":" read -r source_file destination_path <<< "$entry"
  create_symlink "$source_file" "$destination_path"
done
