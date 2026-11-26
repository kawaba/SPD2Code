## 20.7 共通の生成規約（入出力・例外・パッケージ・インポート・SPDの残し方）

`spd-core` の共通規約に、次を上乗せする。

### 入出力

**このワークスペースでは `System.out` / `System.err` を使わない。**
SE版の `Input` クラスによるコンソール入出力も**使用しない**（Web アプリには入力の受け口が無い）。

| SPDの記述 | 生成 |
|---|---|
| `"<メッセージ>"をログに出す`・`記録する` | `log.info(...)` |
| `"<メッセージ>"を警告としてログに出す` | `log.warn(...)` |
| `"<メッセージ>"をエラーとしてログに出す` | `log.error(...)` |
| `"<メッセージ>"を例外<変数>とともにエラーとしてログに出す` | `log.error("…", <変数>)`（`警告として` なら `log.warn`） |
| 画面に表示する | Model経由で渡し、テンプレート側で表示（`## 11.2`） |

**ロガーは自動で補う。**

- メソッドの `処理` に、上の表のログの行が1つでもあれば、クラスに次のフィールドを補う。
  `フィールド` に書かなくてよい。
  ```java
  // SPDに無いため Logger log を補った
  private static final Logger log = LoggerFactory.getLogger(MemberService.class);
  ```
- `getLogger` の引数は、生成するクラス自身とする。フィールドの先頭（インジェクションのフィールドより前）に置く。
- SPDの `フィールド` に `Logger` 型のフィールドが書かれていれば、補わずにそれを使う（名前が `log` でなくてもその名前で呼ぶ）。
- ログの行が無ければ、ロガーは補わない。
- コントローラー・サービスのほか、`処理` を持つ型（`クラス:` など）でも同じに扱う。

**メッセージの書き方**

- メッセージは `"…"` で囲む。**値は、メッセージの中に `{…}` で Java の式を書いて埋め込む。**
  `{…}` の部分を SLF4J のプレースホルダー `{}` にし、式を書かれた順に後ろの引数に並べる。
  ```
  ├─"会員 {member.getId()} を登録した"をログに出す
  ├─"{memberForm.getName()} さんの登録で {result.getErrorCount()} 件のエラーがあった"を警告としてログに出す
  ```
  ```java
  log.info("会員 {} を登録した", member.getId());
  log.warn("{} さんの登録で {} 件のエラーがあった", memberForm.getName(), result.getErrorCount());
  ```
- **文字列の `+` でつないだ形（`"会員 " + member.getId() + " を登録した"`）は生成しない。**
- `{…}` の中は、`処理` のほかの行と同じく Java の式として読む。`{member.id}` のような Thymeleaf の書き方は使えない
  （`member.id` は Java ではフィールドを直接読む式になり、`private` のフィールドには使えない）。
  式として成り立たない場合は、その行を生成せず【確認事項】に載せること。
- **例外を一緒に記録するとき**は、`例外<変数>とともに` と書く。例外は最後の引数にする
  （SLF4J は、最後の引数が例外ならスタックトレースを出す）。
  ```
  ├─"会員 {id} の削除に失敗した"を例外eとともにエラーとしてログに出す
  ```
  ```java
  log.error("会員 {} の削除に失敗した", id, e);
  ```
- メッセージを `"…"` で囲まずに書いた行（`登録した会員のidをログに出す`）は、推測で文を作らず、
  生成せず【確認事項】に載せること。

- SPDに `コンソールに表示する`・`コンソールに出力する` と書かれていた場合は、`log.info` などに読み替えず、
  その行を生成せず【確認事項】に載せ、`"…"をログに出す` と書くよう案内すること。

### 例外処理

`spd-core` の共通規則（握りつぶさない／try-with-resources を優先）はそのまま適用する。

**生成するもの**

- SPDの `処理` に書かれた `〜を投げる`・`try`・`catch` は、`spd-core` のとおりに生成する。

**生成しないもの**

- **SPDに書かれていない `catch` を補ってはならない。** コントローラー・サービスで例外を受け止めて握りつぶすコードも生成しない。
- `@ExceptionHandler`・`@ControllerAdvice` による例外の受け止めと、データが見つからないときの画面の切り替え
  （404 の画面・一覧へ戻すなど）は、当面の対象外である（`## 20.1`）。

**「見つからない」の2つの場合**

データが見つからない場合は、次の2つで扱いが違う。

| 場合 | 例 | 使うもの | 見つからないとき |
|---|---|---|---|
| **利用者が入力した条件で探す** | 表題・名前で検索する画面 | `List` を返す検索メソッド（`## 20.4`） | **空のリスト**が返る。例外にはならない。テンプレートの条件表示で「見つかりませんでした」と表示する |
| **アプリが渡した主キーで探す** | 一覧のリンクから開く編集・削除、更新の送信 | サービスの `主キーで検索`（`findById(id).orElseThrow()`） | **異常として** `NoSuchElementException` が投げられ、エラーの画面になる |

- 後者で見つからないのは、他の利用者による削除・URL の書き換え・プログラムの誤りなどの異常な場合に限られるため、
  処理を止めてエラーの画面を出す。
- **利用者が主キーそのもの（会員番号など）を入力して探す画面**は前者に当たる。サービスの `主キーで検索` は使わず、
  `List<Member> findByMemberNo(String memberNo)` のような検索メソッドを書いてもらう。
  入力された値で `主キーで検索` を呼ぶ `処理` を見つけた場合は、生成したうえで【確認事項】にこのことを書く。
- `Optional` からの取り出しは、引数なしの `orElseThrow()` を既定とする。

### 骨格

- 型定義のタイトルが `コントローラー:`（`コントローラ:` も可）・`サービス:`・`リポジトリ:`・`エンティティ:`・`フォーム:` の
  いずれかであれば、このファイルの規約で生成する。
- タイトルが `設定ファイル:` のSPDは、Javaのコードではなく `application.properties` を生成する（`## 20.10`）。
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
- **表に無い型**（`クラス:`・`レコード:`・`インタフェース:` など、`spd-core` の `## 9.5` で生成する型）は、
  パッケージを決められないので、SPDのタイトル行の前の `※` の行で書いてもらう。
  書かれていない場合は、上の「基底パッケージも分からない場合」と同じに扱う（推測で `dto`・`util` などを作らない）。

### インポート処理

**import 文の書き方**

- **使うクラスを1つずつ import する。** `jakarta.persistence.*` のようなワイルドカードは使わない。
- 使わないクラスの import は書かない。同じパッケージのクラスと `java.lang` のクラスは import しない。
- **並べ方は、VS Code の「インポートの整理」（Organize Imports）と同じにする。** 生成後に整理し直しても順が変わらないようにするためである。
  1. `java.*`
  2. `javax.*`
  3. `org.*`
  4. `com.*`
  5. そのほか（`jakarta.*`・`jp.*` など）
  - グループの間は空行を1つ入れ、グループの中はアルファベット順に並べる。
  - 同じプロジェクトのクラスも、パッケージ名に従って上のどこかのグループに入る（`com.example.app.entity.Member` は4、`jp.kwebs.bookshop.entity.Book` は5）。

**どこから import するか**

SPDにインポート文の明示がない場合は、次の優先順位で決定する。

1. **同一プロジェクト内のクラス**（エンティティ・フォーム・サービスなど）
2. **pom.xml に記載された依存ライブラリ**から選択する

   | 用途 | 主なパッケージ |
   |---|---|
   | コントローラー | `org.springframework.stereotype`（`Controller`）、`org.springframework.web.bind.annotation`（`GetMapping`・`PostMapping`・`RequestMapping`・`PathVariable`・`RequestParam`） |
   | 画面への受け渡し | `org.springframework.ui`（`Model`）、`org.springframework.web.servlet.mvc.support`（`RedirectAttributes`）、`org.springframework.validation`（`BindingResult`） |
   | サービス | `org.springframework.stereotype`（`Service`）、`org.springframework.transaction.annotation`（`Transactional`） |
   | リポジトリ | `org.springframework.data.jpa.repository`（`JpaRepository`） |
   | JPQL | `org.springframework.data.jpa.repository`（`Query`）、`org.springframework.data.repository.query`（`Param`） |
   | ページング | `org.springframework.data.domain`（`Page`・`Pageable`） |
   | エンティティ | `jakarta.persistence`（`Entity`・`Table`・`Id`・`GeneratedValue`・`GenerationType`・`Column` など） |
   | 入力検証 | `jakarta.validation`（`Valid`）、`jakarta.validation.constraints`（`NotBlank`・`Size` など）、`org.hibernate.validator.constraints`（`URL`・`CreditCardNumber`・`ISBN`） |
   | 日付・時刻の入力 | `org.springframework.format.annotation`（`DateTimeFormat`） |
   | ログ | `org.slf4j`（`Logger`・`LoggerFactory`） |

3. **Java 標準ライブラリ**（`java.*`）

- **依存ライブラリの正はプロジェクトの `pom.xml` である。** 上の表は代表例であり、
  `pom.xml` と食い違う場合は `pom.xml` を優先する。
- **pom.xml に存在しないライブラリは追加しないこと。** 必要な場合はユーザーに確認すること。
- **`javax.*` ではなく `jakarta.*` を使う。** Spring Boot 3 以降の前提である。

### SPDの残し方

`spd-core` の `## 9.10` と同じく、**与えられたSPD全体を1つのブロックコメント（`/* … */`）に
まとめ、そのファイルの先頭（`package` 文・`import` 文より前）に残す。** SPDブロックの下に、`package` 文・`import` 文・型定義の順に書く。

- 複数の型（コントローラー・サービス・エンティティなど）のSPDがまとめて与えられた場合は、
  **各Javaファイルに、そのファイルで定義する型のSPDだけ**を冒頭に置く。
  1つのSPD群を複数ファイルに分けて生成するときの、唯一の例外である。
- テンプレート（`テンプレート:`）のSPDは、対応するテンプレートファイルの冒頭に
  Thymeleafのコメント（`<!--/* … */-->`）として残す（Thymeleaf 規約（`references/30-*.md`））。
- 設定ファイル（`設定ファイル:`）のSPDは、`application.properties` の先頭に `# ` のコメントとして残す（`## 20.10`）。

