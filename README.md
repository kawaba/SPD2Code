# SPDからプログラムのソースコードを生成するルール

## SPD関連リンク

| リポジトリ | 内容 |
|---|---|
| [SPDエディター](https://github.com/kawaba/spd-editor) | SPDを作成するエディターです |
| [SPD Editor for VS Code](https://github.com/kawaba/vscode-spd-extension) | SPDエディタのVS Code用拡張機能です |
| [SPD Editor for Eclipse](https://github.com/kawaba/eclipse-spd-plugin) | SPDエディタのEclipse用プラグインです |
| [Autosetup VS Code for C](https://github.com/kawaba/portable-c-vscode) | VS CodeによるC開発環境の自動セットアップスクリプトです |
| [Autosetup VS Code for Python](https://github.com/kawaba/autosetup-vscode-python-book) | VS CodeによるPython開発環境の自動セットアップスクリプトです |
| [Autosetup Eclipse for Java](https://github.com/kawaba/auto-setup-eclipse) | Eclipse（Java）を自動セットアップするスクリプトです |
## SPDの書き方（入門書）

SPDの書き方を、言語ごとに説明した入門書をウェブで公開しています。

目次：https://kawaba.github.io/SPD2Code/docs/html/

・[Java用のSPDの書き方](https://kawaba.github.io/SPD2Code/docs/html/Java%E7%94%A8%E3%81%AESPD%E3%81%AE%E6%9B%B8%E3%81%8D%E6%96%B9.html)

・[Python用のSPDの書き方](https://kawaba.github.io/SPD2Code/docs/html/Python%E7%94%A8%E3%81%AESPD%E3%81%AE%E6%9B%B8%E3%81%8D%E6%96%B9.html)

・[C用のSPDの書き方](https://kawaba.github.io/SPD2Code/docs/html/C%E7%94%A8%E3%81%AESPD%E3%81%AE%E6%9B%B8%E3%81%8D%E6%96%B9.html)

・[SpringBoot用のSPDの書き方](https://kawaba.github.io/SPD2Code/docs/html/SpringBoot%E7%94%A8%E3%81%AESPD%E3%81%AE%E6%9B%B8%E3%81%8D%E6%96%B9.html)

・[SPDによるテンプレートの書き方](https://kawaba.github.io/SPD2Code/docs/html/SPD%E3%81%AB%E3%82%88%E3%82%8B%E3%83%86%E3%83%B3%E3%83%97%E3%83%AC%E3%83%BC%E3%83%88%E3%81%AE%E6%9B%B8%E3%81%8D%E6%96%B9.html)（Spring Boot の Thymeleaf テンプレート）

## ルールとスキルの使い方

AIエージェントごとに、ルールやスキルの設置方法と使い方を説明しています。

| 言語 | Claude SKILL | Gemini SKILL | GitHub Copilot |
|---|---|---|---|
| Java | [HowToClaude](https://kawaba.github.io/SPD2Code/Java/Claude-skill/HowToClaude.html) | [HowToGemini](https://kawaba.github.io/SPD2Code/Java/Gemini-skill/HowToGemini.html) | 下の「ルールファイルの使い方」の表2 |
| Python | [HowToClaude](https://kawaba.github.io/SPD2Code/Python/Claude-skill/HowToClaude.html) | [HowToGemini](https://kawaba.github.io/SPD2Code/Python/Gemini-skill/HowToGemini.html) | 下の「ルールファイルの使い方」の表3 |
| C | [HowToClaude](https://kawaba.github.io/SPD2Code/C/Claude-skill/HowToClaude.html) | [Geminiのskillとして設置する方法](C/Gemini-skill/Gemini%E3%81%AEskill%E3%81%A8%E3%81%97%E3%81%A6%E8%A8%AD%E7%BD%AE%E3%81%99%E3%82%8B%E6%96%B9%E6%B3%95.md) | 下の「ルールファイルの使い方」の表1 |
| Spring Boot | [HowToClaude](https://kawaba.github.io/SPD2Code/SpringBoot/Claude-skill/HowToClaude.html) | [HowToGemini](https://kawaba.github.io/SPD2Code/SpringBoot/Gemini-skill/HowToGemini.html) | [README](SpringBoot/GitHub-Copilot/README.md) |


## このリポジトリについて

AIエージェントが、SPDからプログラム言語のソースコードを生成するためのルールです。<br>
Python版は安定版です。Java版は**SpringBoot**用のルールを追加しました（2026年内に完成予定です）。

## 対象とするAIエージェント

・GitHub Copilot

・Gemini SKILL

・Claude SKILL（claude.ai のウェブ版。Spring Boot 用・Python 用・Java 用・C 用）

## フォルダとファイル
　各言語別のフォルダには、Gemini-skillフォルダとGitHub-Copilotフォルダがあり、次のようなルールファイルが置かれています。

      SPD2Code
      │
      ├─docs
      │  └─html ┬─index.html（入門書の目次）
      │          ├─Java用のSPDの書き方.html
      │          ├─Python用のSPDの書き方.html
      │          ├─C用のSPDの書き方.html
      │          ├─SpringBoot用のSPDの書き方.html
      │          └─SPDによるテンプレートの書き方.html
      │
      ├─C
      │  ├─Claude-skill ┬─spd-to-c-generator.zip（claude.ai に登録するファイル）
      │  │               ├─spd-to-c-generator（zip の中身）
      │  │               ├─HowToClaude.html
      │  │               └─build（Gemini SKILL のファイルから Claude SKILL を作る変換スクリプト）
      │  │
      │  ├─Gemini-skill ┬─SKILL.md
      │  │               └─Geminiのskillとして設置する方法.md
      │  │
      │  └─GitHub-Copilot──copilot-instructions.md
      │
      ├─Java
      │  ├─Claude-skill ┬─spd-to-java-generator.zip（claude.ai に登録するファイル）
      │  │               ├─spd-to-java-generator（zip の中身）
      │  │               ├─HowToClaude.html
      │  │               └─build（Gemini SKILL のファイルから Claude SKILL を作る変換スクリプト）
      │  │
      │  ├─Gemini-skill ┬─SKILL.md
      │  │               ├─HowToGemini.html
      │  │               ├─ガイドライン.txt
      │  │               └─pom.xml
      │  │
      │  └─GitHub-Copilot──copilot-instructions.md
      │
      ├─Python
      │  ├─Claude-skill ┬─spd-to-python-generator.zip（claude.ai に登録するファイル）
      │  │               ├─spd-to-python-generator（zip の中身）
      │  │               ├─requirements-to-python-generator.zip（claude.ai に登録するファイル）
      │  │               ├─requirements-to-python-generator（zip の中身）
      │  │               ├─HowToClaude.html
      │  │               └─build（Gemini SKILL のファイルから Claude SKILL を作る変換スクリプト）
      │  │
      │  ├─Gemini-skill ┬─HowToGemini.html
      │  │               ├─spd-to-python-generator ┬─SKILL.md
      │  │               │                          └─spd-pattern-python-code.md
      │  │               └─requirements-to-python-generator──SKILL.md
      │  │
      │  └─GitHub-Copilot──copilot-instructions.md
      │
      └─SpringBoot
          ├─Claude-skill ┬─spd-to-springboot-generator.zip（claude.ai に登録するファイル）
          │               ├─spd-to-springboot-generator（zip の中身）
          │               ├─HowToClaude.html
          │               └─build（Gemini SKILL のファイルから Claude SKILL を作る変換スクリプト）
          │
          ├─Gemini-skill ┬─SKILL.md
          │               ├─HowToGemini.html
          │               ├─ガイドライン-共通.txt
          │               ├─ガイドライン-SpringBoot.txt
          │               ├─ガイドライン-Thymeleaf.txt
          │               ├─pom.xml
          │               └─build（SKILL.md とナレッジを作る変換スクリプト）
          │
          └─GitHub-Copilot┬──copilot-instructions.md
                           └──instructions ┬─spd-core.instructions.md
                                           ├─springboot-java.instructions.md
                                           └─thymeleaf.instructions.md

## ルールファイルの使い方

どのファイルもUTF-8でエンコードしています。内容を確認したい場合は、WindowsではUTF-8対応のエディタで開いてください（メモ帳がいいと思います）。
Copilotでは、.githubという名前のフォルダを作って、その中にcopilot-instructions.mdファイルを置きます。置く場所は開発環境によって違います。

- VS Code（C・Python）：ワークスペースのフォルダの直下（workspace/.github/）に置きます。ワークスペースごとに有効になります。
- Eclipse（Java・Spring Boot）：プロジェクトのフォルダの直下（workspace/project/.github/）に置きます。プロジェクトごとに有効になります。プロジェクトが複数あるときは、それぞれのプロジェクトに置きます。Eclipse の workspace フォルダの直下に置いても読まれません。

Gemini SKILLでは、各言語の Gemini-skill フォルダにある `HowToGemini.html`（C は `Geminiのskillとして設置する方法.md`）の手順に従って、ファイルをAIのチャットにアップロードし、スキルとして登録します。

**表1**

| 言語 | AI | ファイル名 | 設置方法 |
|---|---|---|---|
| C | Copilot | copilot-instructions.md | workspace/.github/ フォルダに置く |
| | Gemini SKILL | SKILL.md | `Geminiのskillとして設置する方法.md` の手順で、スキルとして登録する |
| | Claude SKILL | spd-to-c-generator.zip | `HowToClaude.html` の手順で、zip を解凍せずにそのまま claude.ai に登録する |

登録の詳細は `C/Gemini-skill/Geminiのskillとして設置する方法.md` を見てください。

C の Claude SKILL は、claude.ai（ウェブ版）で使います。無料プランでも使えますが、設定の「機能」で「ファイルの作成と編集」をオンにする必要があります（スキルの登録は、claude.ai の画面の左側のメニューの「プラグイン」で行います）。使い方は Gemini SKILL と同じで、SPDからのコード生成のほか、SPDのない依頼（コードの提案、要件定義からの仕様書作成）にも使えます。登録と使い方の詳細は `C/Claude-skill/HowToClaude.html` を見てください。規約の一部は節ごとのファイルに分けてあり、AIは必要なファイルだけを読みます。スキルのファイルは、Gemini SKILL の `SKILL.md` から `C/Claude-skill/build/build-claude.ps1` で作ります。Gemini SKILL のファイルを直したら、このスクリプトを実行してください。

**表2**

| 言語 | AI | ファイル名 | 設置方法 |
|---|---|---|---|
| Java | Copilot | copilot-instructions.md | workspace/project/.github/ フォルダに置く |
| | Gemini SKILL | SKILL.md / ガイドライン.txt / pom.xml | `HowToGemini.html` の手順で、3ファイルをまとめてスキルとして登録する |
| | Claude SKILL | spd-to-java-generator.zip | `HowToClaude.html` の手順で、zip を解凍せずにそのまま claude.ai に登録する |

登録の詳細は `Java/Gemini-skill/HowToGemini.html` を見てください。

Java の Claude SKILL は、claude.ai（ウェブ版）で使います。無料プランでも使えますが、設定の「機能」で「ファイルの作成と編集」をオンにする必要があります（スキルの登録は、claude.ai の画面の左側のメニューの「プラグイン」で行います）。使い方は Gemini SKILL と同じです。登録と使い方の詳細は `Java/Claude-skill/HowToClaude.html` を見てください。変換ルールは節ごとのファイルに分けてあり、AIは必要なファイルだけを読みます。スキルのファイルは、Gemini SKILL のファイルから `Java/Claude-skill/build/build-claude.ps1` で作ります。Gemini SKILL のファイルを直したら、このスクリプトを実行してください。

**表3**

| 言語 | AI | ファイル名 | 設置方法 |
|---|---|---|---|
| Python | Copilot | copilot-instructions.md | workspace/.github/ フォルダに置く |
| | Gemini SKILL | spd-to-python-generator フォルダの SKILL.md / spd-pattern-python-code.md | `HowToGemini.html` の手順で、2ファイルをまとめてスキルとして登録する（SPDからのコード生成） |
| | Gemini SKILL | requirements-to-python-generator フォルダの SKILL.md | `HowToGemini.html` の手順で、スキルとして登録する（要件定義からの仕様書・コード生成） |
| | Claude SKILL | spd-to-python-generator.zip | `HowToClaude.html` の手順で、zip を解凍せずにそのまま claude.ai に登録する（SPDからのコード生成） |
| | Claude SKILL | requirements-to-python-generator.zip | `HowToClaude.html` の手順で、zip を解凍せずにそのまま claude.ai に登録する（要件定義からの仕様書・コード生成） |

Python の Gemini SKILL は2つあります。SPDからコードを生成するスキルと、要件定義から仕様書とコードを生成するスキルです。登録の詳細は `Python/Gemini-skill/HowToGemini.html` を見てください。

Python の Claude SKILL も、Gemini SKILL と同じ2つです。claude.ai（ウェブ版）で使います。無料プランでも使えますが、設定の「機能」で「ファイルの作成と編集」をオンにする必要があります（スキルの登録は、claude.ai の画面の左側のメニューの「プラグイン」で行います）。登録と使い方の詳細は `Python/Claude-skill/HowToClaude.html` を見てください。SPDからコードを生成するスキルの変換パターン集は節ごとのファイルに分けてあり、AIは必要なファイルだけを読みます。スキルのファイルは、Gemini SKILL のファイルから `Python/Claude-skill/build/build-claude.ps1` で作ります。Gemini SKILL のファイルを直したら、このスクリプトを実行してください。

**表4**

| 言語 | AI | ファイル名 | 設置方法 |
|---|---|---|---|
| Spring Boot | Copilot | copilot-instructions.md / instructions フォルダ | workspace/project/.github/ フォルダに置く |
| | Gemini SKILL | SKILL.md / ガイドライン-共通.txt / ガイドライン-SpringBoot.txt / ガイドライン-Thymeleaf.txt / pom.xml | `HowToGemini.html` の手順で、5ファイルをまとめてスキルとして登録する |
| | Claude SKILL | spd-to-springboot-generator.zip | `HowToClaude.html` の手順で、zip を解凍せずにそのまま claude.ai に登録する |

Spring Boot の Gemini SKILL は、1回に1ファイルずつ生成し、生成済みのファイルをチャットに添付して次のファイルを作る使い方を想定しています。登録と使い方の詳細は `SpringBoot/Gemini-skill/HowToGemini.html` を見てください。スキルのファイルは、Copilot 版の規約から `SpringBoot/Gemini-skill/build/build-skill.ps1` で作っています。

Spring Boot の Claude SKILL は、claude.ai（ウェブ版）で使います。無料プランでも使えますが、設定の「機能」で「ファイルの作成と編集」をオンにする必要があります（スキルの登録は、claude.ai の画面の左側のメニューの「プラグイン」で行います）。使い方は Gemini SKILL と同じです。登録と使い方の詳細は `SpringBoot/Claude-skill/HowToClaude.html` を見てください。変換ルールは節ごとのファイルに分けてあり、AIは必要なファイルだけを読みます。スキルのファイルは、`build-skill.ps1` を実行すると、続けて `SpringBoot/Claude-skill/build/build-claude.ps1` が Gemini SKILL のファイルから作ります。

（注）pom.xmlファイルはサンプルです。Java SEベースのプログラムをコンパイル・リンクできます。AIエージェントはimport文を自動生成するために、pom.xmlファイルを読みます。

## ルールファイルをセットアップ済みの開発環境
自分でルールファイルを設置するのではなく、設置済みの開発環境が必要な場合は、以下の自動セットアップスクリプトを利用すると簡単です。
10分前後でポータブルな開発環境を自動セットアップします。

Python：Windows用：[autosetup-vscode-python-book](https://github.com/kawaba/autosetup-vscode-python-book)

Python：Mac用：[autosetup-vscode-python-book-mac](https://github.com/kawaba/autosetup-vscode-python-book-mac)

Java：[auto-setup-eclipse](https://github.com/kawaba/auto-setup-eclipse)

C：[portable-c-vscode](https://github.com/kawaba/portable-c-vscode)


