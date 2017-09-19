# fil_mk

## 概要

新規ファイル/ディレクトリの作成

## 使用方法

### fil_mk.sh

    新規ファイルを作成します。
    # fil_mk.sh -m モード -o オーナー:グループ ファイル名

    新規ディレクトリを作成します。
    # fil_mk.sh -d -m モード -o オーナー:グループ ディレクトリ名

### その他

* 上記で紹介したツールの詳細については、「ツール名 --help」を参照してください。

## 動作環境

OS:

* Linux
* Cygwin

依存パッケージ または 依存コマンド:

* make (インストール目的のみ)

## インストール

ソースからインストールする場合:

    (Linux, Cygwin の場合)
    # make install

fil_pkg.plを使用してインストールする場合:

[fil_pkg.pl](https://github.com/yuksiy/fil_tools_pl/blob/master/README.md#fil_pkgpl) を参照してください。

## インストール後の設定

環境変数「PATH」にインストール先ディレクトリを追加してください。

## 最新版の入手先

<https://github.com/yuksiy/fil_mk>

## License

MIT License. See [LICENSE](https://github.com/yuksiy/fil_mk/blob/master/LICENSE) file.

## Copyright

Copyright (c) 2006-2017 Yukio Shiiya
