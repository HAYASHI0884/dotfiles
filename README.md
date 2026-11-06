# dotfiles

## セットアップ

### 新しいマシンへの初回セットアップ

```bash
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply HAYASHI0884
```

このコマンド1つで以下が自動実行される：

1. chezmoi 本体をインストール
2. このリポジトリを `~/.local/share/chezmoi` に clone
3. 設定ファイルをホームディレクトリに展開
4. `run_once_before_install-packages.sh.tmpl` により必要なツールを一括インストール

初回実行時に以下を対話形式で確認する：

- Claude Code をインストールするか（`y/n`）
- Codex をインストールするか（`y/n`）

### 既存マシンでの設定更新

```bash
chezmoi update
```

## VS Code関連

拡張機能のリストは `vscode/vscode-extensions.txt` で管理する。
各コマンドはリポジトリのルートで実行する。

### VS Code（codeコマンドをインストールしてから実行）

- 拡張機能のリスト作成
  `code --list-extensions > vscode/vscode-extensions.txt`
- 拡張機能のインストール
  `cat vscode/vscode-extensions.txt | xargs -n 1 code --install-extension`

## 参考

- [WSL2 に zsh をインストールする方法](https://qiita.com/lvn-hayashi/items/f8122522319557c6a869)
- [WSL2 に Docker をインストールする方法](https://docs.docker.com/engine/install/ubuntu/)
