# SPDからプログラムのソースコードを生成するルール

AIエージェントが、SPDからプログラム言語のソースコードを生成するためのルールです。<br>
Python版は安定版です。Java版は2026年内にSpringBoot用のルールを追加します。

## 対象とするAIエージェント

・GitHub Copilot

・Gemini Gem


## フォルダとファイル
　各言語別のフォルダには、Gemini_GemフォルダとGitHub-Copilotフォルダがあり、次のようなルールファイルが置かれています。

      SPD2Code
      │
      ├─C
      │  ├─Gemin_Gem ────カスタム指示.md
      │  │
      │  └─GitHub-Copilot──copilot-instructions.md
      │
      ├─Java
      │  ├─Gemin_Gem ┬───カスタム指示.md
      │  │            ├───ガイドライン.txt
      │  │            └───pom.xml
      │  │
      │  └─GitHub-Copilot──copilot-instructions.md
      │
      ├─Python
      │  ├─Gemin_Gem ┬───カスタム指示.md
      │  │            └───spd-pattern-python-code.md
      │  │
      │  └─GitHub-Copilot──copilot-instructions.md
      │
      └─SpringBoot
          ├─Gemini-Gem ┬───カスタム指示.md
          │             ├───ガイドライン-共通.txt
          │             ├───ガイドライン-SpringBoot.txt
          │             ├───ガイドライン-Thymeleaf.txt
          │             ├───pom.xml
          │             └───build（ナレッジを作る変換スクリプト）
          │
          └─GitHub-Copilot┬──copilot-instructions.md
                           └──instructions ┬─spd-core.instructions.md
                                           ├─springboot-java.instructions.md
                                           └─thymeleaf.instructions.md

## ルールファイルの使い方

どのファイルもUTF-8でエンコードしています。内容を確認したい場合は、WindowsではUTF-8対応のエディタで開いてください（メモ帳がいいと思います）。
Copilotでは、作業しているワークスペースに.githubという名前のフォルダを作って、その中にcopilot-instructions.mdファイルを置きます。ワークスペースごとに有効になります。

GeminiのGemでは、Gem作成時に表示される「カスタム指示」欄に、カスタム指示.mdファイルの内容を、テキストとして貼り付けます。メモ帳などで開いて、すべて選択→コピーとして、CTRL+Vでカスタム指示欄に貼り付けるといいでしょう。それ以外は、知識欄にファイルとしてアップロードします。

**表1**

| 言語 | AI | ファイル名 | 設置方法 |
|---|---|---|---|
| C | Copilot | copilot-instructions.md | workspace/.github/ フォルダに置く |
| | Gem | カスタム指示.md | カスタム指示欄にテキストを貼り付ける |

**表2**

| 言語 | AI | ファイル名 | 設置方法 |
|---|---|---|---|
| Java | Copilot | copilot-instructions.md | workspace/project/.github/ フォルダに置く |
| | Gem | カスタム指示.md | カスタム指示欄にテキストを貼り付ける |
| | Gem | ガイドライン.txt / pom.xml | 知識欄にファイルをアップロード |

**表3**

| 言語 | AI | ファイル名 | 設置方法 |
|---|---|---|---|
| Python | Copilot | copilot-instructions.md | workspace/.github/ フォルダに置く |
| | Gem | カスタム指示 | カスタム指示欄にテキストを貼り付ける |
| | Gem | spd-pattern-python-code.md | 知識欄にファイルをアップロード |

**表4**

| 言語 | AI | ファイル名 | 設置方法 |
|---|---|---|---|
| Spring Boot | Copilot | copilot-instructions.md / instructions フォルダ | workspace/project/.github/ フォルダに置く |
| | Gem | カスタム指示.md | カスタム指示欄にテキストを貼り付ける（先頭の `<!-- … -->` を除く） |
| | Gem | ガイドライン-共通.txt / ガイドライン-SpringBoot.txt / ガイドライン-Thymeleaf.txt / pom.xml | 知識欄にファイルをアップロード |

Spring Boot の Gem は、1回に1ファイルずつ生成し、生成済みのファイルをチャットに添付して次のファイルを作る使い方を想定しています。詳しくは `SpringBoot/Gemini-Gem/ファイルの使い方（Shift-JIS）.txt` を見てください。Gem のファイルは、Copilot 版の規約から `SpringBoot/Gemini-Gem/build/build-gem.ps1` で作っています。

（注）pom.xmlファイルはサンプルです。Java SEベースのプログラムをコンパイル・リンクできます。AIエージェントはimport文を自動生成するために、pom.xmlファイルを読みます。

## ルールファイルをセットアップ済みの開発環境
自分でルールファイルを設置するのではなく、設置済みの開発環境が必要な場合は、以下の自動セットアップスクリプトを利用すると簡単です。
10分前後でポータブルな開発環境を自動セットアップします。

Python：Windows用：[autosetup-vscode-python-book](https://github.com/kawaba/autosetup-vscode-python-book)

Python：Mac用：[autosetup-vscode-python-book-mac](https://github.com/kawaba/autosetup-vscode-python-book-mac)

Java：[auto-setup-eclipse](https://github.com/kawaba/auto-setup-eclipse)

C：[portable-c-vscode](https://github.com/kawaba/portable-c-vscode)


