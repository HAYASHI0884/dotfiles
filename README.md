# dotfiles

## シェルスクリプト

### mac-install.sh / wsl-install.sh

- 必要なツールを一括インストールするスクリプト。環境に応じて使い分ける。
  - `mac-install.sh`: macOS（Apple Silicon）用
  - `wsl-install.sh`: WSL2（Ubuntu）用
- 既にインストール済みのツールは自動的にスキップされる。

### link.sh

設定ファイルのシンボリックリンクを作成するスクリプト。

### claude-mcp.sh

- Claude CodeのMCPサーバーをユーザースコープ（`~/.claude.json`、全プロジェクト共通）に登録するスクリプト。
- MCPサーバーの追加・変更は、スクリプト内の `add_mcp` の行を編集する。
- 実行のたびに削除→登録し直すため、実行後はスクリプトの定義内容と一致する。
- `mac-install.sh` / `wsl-install.sh` からも呼び出される（Claude Code未インストール時はスキップ）。

## VS Code / Cursor関連

拡張機能のリストは、VS Codeは `vscode/vscode-extensions.txt`、Cursorは `cursor/cursor-extensions.txt` で管理する。
各コマンドはリポジトリのルートで実行する。

### VS Code（codeコマンドをインストールしてから実行）

- 拡張機能のリスト作成
  `code --list-extensions > vscode/vscode-extensions.txt`
- 拡張機能のインストール
  `cat vscode/vscode-extensions.txt | xargs -n 1 code --install-extension`

### Cursor（cursorコマンドをインストールしてから実行）

- 拡張機能のリスト作成
  `cursor --list-extensions > cursor/cursor-extensions.txt`
- 拡張機能のインストール
  `cat cursor/cursor-extensions.txt | xargs -n 1 cursor --install-extension`
- 設定ファイル置き場(Windows)
  `C:\Users\{User名}\AppData\Roaming\Cursor\User`

## 参考

- [WSL2 に zsh をインストールする方法](https://qiita.com/lvn-hayashi/items/f8122522319557c6a869)
- [WSL2 に Docker をインストールする方法](https://docs.docker.com/engine/install/ubuntu/)
- [cursorコマンドをインストールする方法](https://qiita.com/tacarzen/items/03f118a3a0fd37134052)
- [codeコマンドをインストールする方法（macOS）](https://code.visualstudio.com/docs/setup/mac#_configure-path-with-vs-code)
