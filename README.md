# dotfiles

## シェルスクリプト

### install.sh

- 必要なツールを一括インストールするスクリプト。
- 既にインストール済みのツールは自動的にスキップされる。

### link.sh

設定ファイルのシンボリックリンクを作成するスクリプト。

## cursor関連

- 拡張機能のリスト作成（cursorコマンドをインストールしてから実行）
  `cursor --list-extensions > cursor/cursor-extensions.txt`
- 拡張機能のインストール（cursorコマンドをインストールしてから実行）
  `cat cursor-extensions.txt | xargs -n 1 cursor --install-extension`
- 設定ファイル置き場(Windows)
  `C:\Users\{User名}\AppData\Roaming\Cursor\User`

## 参考

- [WSL2 に zsh をインストールする方法](https://qiita.com/lvn-hayashi/items/f8122522319557c6a869)
- [WSL2 に Docker をインストールする方法](https://docs.docker.com/engine/install/ubuntu/)
- [cursorコマンドをインストールする方法](https://qiita.com/tacarzen/items/03f118a3a0fd37134052)
