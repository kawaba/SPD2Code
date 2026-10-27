## 20.7 Spring Boot コード生成規約

`spd-core` の共通規約に、次を上乗せする。

### 入出力

**このワークスペースでは `System.out` / `System.err` を使わない。**
SE版の `Input` クラスによるコンソール入出力も**使用しない**（Web アプリには入力の受け口が無い）。

| SPDの記述 | 生成 |
|---|---|
| ログに出す／記録する | `log.info(...)`（下記のロガーを使う） |
| 警告としてログに出す | `log.warn(...)` |
| エラーとしてログに出す | `log.error(...)` |
| 画面に表示する | Model経由で渡し、テンプレート側で表示（`## 11.2`） |

```java
private static final Logger log = LoggerFactory.getLogger(MemberService.class);
```

- SPDに `コンソールに表示する` と書かれていた場合は、`log.info` に読み替え、
  その旨を行コメント1行で明示する。

### 例外処理

- `spd-core` の共通規則（握りつぶさない／try-with-resources を優先／`Optional` は
  `orElseThrow()`）はそのまま適用する。
- **コントローラー・サービスで `catch` して握りつぶすコードを生成しない。**
  業務的に想定される失敗（該当データなし等）は、SPDの記述に従って
  例外を投げるか、戻り値で表現する。
- `findById` の戻り値 `Optional` からの取り出しは、引数なしの `orElseThrow()` を既定とする。

### 骨格

- 型定義のタイトルが `コントローラー:`（`コントローラ:` も可）・`サービス:`・`リポジトリ:`・`エンティティ:`・`フォーム:` の
  いずれかであれば、このファイルの規約で生成する。
- それ以外のタイトル（`クラス:`・`レコード:` など）は、`spd-core` の `## 9.5` に従う通常の
  Javaの型として生成する。**Web層のアノテーションを勝手に付けてはならない。**
- **インデントは半角スペース4つとする。** タブは使わない。アノテーションは、それが付く宣言と
  同じ深さに置く（`@GetMapping` とメソッド宣言、`@Id` とフィールド宣言の字下げをそろえる）。

### パッケージ

**パッケージ名は、SPDのタイトル行の前に `※` のコメントで書く。**

```
※jp.kwebs.bookshop.entity
エンティティ：Book
├─目的：書籍を表すエンティティ
…
```
```java
package jp.kwebs.bookshop.entity;
```

- タイトル行より前にある `※` の行で、`※` の後（前後の空白を除く）がJavaのパッケージ名の形
  （英小文字で始まる語を `.` でつないだもの。`jp.kwebs.bookshop.entity`）であるものを、パッケージ名として読む。
  `※パッケージ：jp.kwebs.bookshop.entity` と書いてもよい。
- 書かれたパッケージ名を**そのまま** `package` 文にする。末尾の語（`entity` など）を下の表に合わせて直してはならない。
- この行は `package` 文になるので、`// …` の行コメントには転記しない（`spd-core` の `## 9.3` ルール6の例外）。
  ファイル冒頭に残すSPDブロックには、この行も原文のまま含める。
- 複数のSPDをまとめて与えられた場合は、SPDごとに、そのタイトル行の前の行を読む。
- テンプレート（`テンプレート:`）のSPDには書かない。書かれていても無視する。

**SPDにパッケージ名が無い場合**は、プロジェクトの基底パッケージ（`@SpringBootApplication` を付けたクラスのパッケージ）
から、次の表で決める。

| 型 | パッケージ |
|---|---|
| コントローラー | `<基底パッケージ>.controller` |
| サービス | `<基底パッケージ>.service` |
| リポジトリ | `<基底パッケージ>.repository` |
| エンティティ | `<基底パッケージ>.entity` |
| フォーム | `<基底パッケージ>.form` |

- **このスキルでは、SPDにパッケージ名が無い場合は `package` 文を書かずに生成する。** 生成を止めて尋ねてはならない。
  同じプロジェクトのクラスの import とファイルのパスの書き方は、`references/10-skill-operation.md` の `## 10.4`・`## 10.5` に従う。

### インポート処理

SPDにインポート文の明示がない場合は、次の優先順位で決定する。

1. **同一プロジェクト内のクラス**（エンティティ・フォーム・サービスなど）
2. **pom.xml に記載された依存ライブラリ**から選択する

   | 用途 | 代表的なインポート |
   |---|---|
   | コントローラー | `org.springframework.stereotype.Controller`、`org.springframework.web.bind.annotation.*` |
   | 画面への受け渡し | `org.springframework.ui.Model`、`org.springframework.web.servlet.mvc.support.RedirectAttributes` |
   | サービス | `org.springframework.stereotype.Service`、`org.springframework.transaction.annotation.Transactional` |
   | リポジトリ | `org.springframework.data.jpa.repository.JpaRepository` |
   | JPQL | `org.springframework.data.jpa.repository.Query`、`org.springframework.data.repository.query.Param` |
   | ページング | `org.springframework.data.domain.Page`、`org.springframework.data.domain.Pageable` |
   | エンティティ | `jakarta.persistence.*` |
   | 入力検証 | `jakarta.validation.Valid`、`jakarta.validation.constraints.*` |
   | 日付・時刻の入力 | `org.springframework.format.annotation.DateTimeFormat` |
   | ログ | `org.slf4j.Logger`、`org.slf4j.LoggerFactory` |

3. **Java 標準ライブラリ**（`java.*`）

- **依存ライブラリの正はプロジェクトの `pom.xml` である。** 上の表は代表例であり、
  `pom.xml` と食い違う場合は `pom.xml` を優先する。
- **pom.xml に存在しないライブラリは追加しないこと。** 必要な場合はユーザーに確認すること。
- **`javax.*` ではなく `jakarta.*` を使う。** Spring Boot 3 以降の前提である。

### SPDの残し方

`spd-core` の `## 9.10` と同じく、**与えられたSPD全体を1つのブロックコメント（`/* … */`）に
まとめ、そのファイルの冒頭（`package` 文と `import` 文の後・型定義の直前）に残す。**

- 複数の型（コントローラー・サービス・エンティティなど）のSPDがまとめて与えられた場合は、
  **各Javaファイルに、そのファイルで定義する型のSPDだけ**を冒頭に置く。
  1つのSPD群を複数ファイルに分けて生成するときの、唯一の例外である。
- テンプレート（`テンプレート:`）のSPDは、対応するテンプレートファイルの冒頭に
  Thymeleafのコメント（`<!--/* … */-->`）として残す（Thymeleaf 規約（`references/30-*.md`））。

