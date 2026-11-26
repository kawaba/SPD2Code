## 20.10 設定ファイル（application.properties）

タイトルが `設定ファイル：application.properties` のSPDから、`src/main/resources/application.properties` を生成する。
扱うのはデータベースの設定で、対象のデータベースは **H2・PostgreSQL・MySQL** の3つである。

- 設定のキーを並べるのではなく、**日本語の項目名**で書く。項目名と設定のキーの対応は、この節の表で決まっている。
- ファイル名は `application.properties` だけを認める。`application-dev.properties` のようなプロファイル別のファイルや
  `application.yml` が書かれた場合は、生成せず【確認事項】に載せること。

### 記法

```
設定ファイル：application.properties
│
└─データベース設定
      ├─データベース：<H2／PostgreSQL／MySQL>
      │
      ├─接続
      │    ├─接続URL
      │    │    └─（データベースごとの項目。下の「接続URL」）
      │    │
      │    └─認証情報
      │          ├─ユーザー名：<値>
      │          └─パスワード：<値>　　　　　※パスワードが空なら「なし」
      │
      ├─JPA
      │    ├─スキーマ自動生成：<none／validate／update／create／create-drop>
      │    ├─SQL ログを表示する　　　　　　　※または「表示しない」
      │    ├─SQL を見やすく整形する　　　　　※または「整形しない」
      │    └─Open Session in View を有効にしない　※または「有効にする」
      │
      └─H2コンソール　　　　　　　　　　　※H2 のときだけ
            ├─H2コンソールを有効にする　　　※または「有効にしない」
            └─パス：/h2-console
```

- 見出し（`データベース設定`・`接続`・`接続URL`・`認証情報`・`JPA`・`H2コンソール`）は、設定のキーのプレフィックス
  （`spring.datasource`・`spring.jpa`・`spring.h2.console`）ごとに分けたものである。見出しそのものは出力しない。
- オン・オフの項目は **「〜する」「〜しない」** で書く。`有効化`・`無効化`・`表示` などの書き方は、規約に無い書き方として報告する。
- **書かなかった項目は出力しない**（Spring Boot の既定値になる）。必要な項目だけを書けばよい。
- 項目名の中の空白の有無は問わない（`SQLログを表示する` は `SQL ログを表示する` と同じ）。

### 接続URL

`接続URL` の下の項目は、`データベース` の値で決まる。

| データベース | 項目 | 省略したとき | 生成する URL |
|---|---|---|---|
| `H2` | `DB名`・`記録場所`（`インメモリー`／`ファイル`）・`保存先`（`ファイル` のときだけ） | `記録場所` は `インメモリー`、`保存先` は `./data` | `jdbc:h2:mem:<DB名>`<br>`jdbc:h2:file:<保存先>/<DB名>` |
| `PostgreSQL` | `ホスト名`・`ポート番号`・`DB名` | `localhost`・`5432` | `jdbc:postgresql://<ホスト名>:<ポート番号>/<DB名>` |
| `MySQL` | `ホスト名`・`ポート番号`・`DB名` | `localhost`・`3306` | `jdbc:mysql://<ホスト名>:<ポート番号>/<DB名>` |

- `DB名` は必ず書く。無い場合は生成せず【確認事項】に載せること（H2 のインメモリーで DB名を省くと、
  起動のたびに名前が変わり、H2コンソールから接続しにくいため）。
- そのデータベースに無い項目（H2 の `ホスト名`、PostgreSQL の `記録場所` など）は、生成せず【確認事項】に載せること。

### 項目と出力の対応

| SPDの項目 | 出力 |
|---|---|
| `データベース：…` | 出力しない（接続URL の形と、`H2コンソール` を書けるかどうかを決める） |
| `接続URL` の下の項目 | `spring.datasource.url=…`（上の表） |
| `ユーザー名：<値>` | `spring.datasource.username=<値>` |
| `パスワード：<値>` | `spring.datasource.password=<値>` |
| `パスワード：なし` | `spring.datasource.password=`（値を空にする） |
| `スキーマ自動生成：<値>` | `spring.jpa.hibernate.ddl-auto=<値>` |
| `SQL ログを表示する`／`表示しない` | `spring.jpa.show-sql=true`／`false` |
| `SQL を見やすく整形する`／`整形しない` | `spring.jpa.properties.hibernate.format_sql=true`／`false` |
| `Open Session in View を有効にする`／`有効にしない` | `spring.jpa.open-in-view=true`／`false` |
| `H2コンソールを有効にする`／`有効にしない` | `spring.h2.console.enabled=true`／`false` |
| `パス：<値>`（`H2コンソール` の下） | `spring.h2.console.path=<値>` |
| `<設定のキー>：<値>`（`spring.` などで始まるキー） | `<設定のキー>=<値>`（表に無い設定を、キーのまま書いたもの） |

### 生成規則

- **値はSPDに書かれたまま出力する。** `スキーマ自動生成` の値を日本語から言い換えたり、別の値を選んだりしない。
  `none`・`validate`・`update`・`create`・`create-drop` 以外が書かれた場合は、その行を出力せず【確認事項】に載せること。
- **ドライバークラス名（`spring.datasource.driver-class-name`）と Hibernate の dialect は出力しない。**
  Spring Boot が接続URLから判定するためである。SPDに `ドライバークラス名` などが書かれていた場合は、
  その行を出力せず【確認事項】に載せること。
- `データベース` が `H2` でないのに `H2コンソール` がある場合は、その枝を出力せず【確認事項】に載せること。
- `データベース` が無い、または H2・PostgreSQL・MySQL 以外の場合は、ファイルを生成せず【確認事項】に載せること。
- この表に無い日本語の項目名は、推測でキーに読み替えず、その行を出力せず【確認事項】に載せること
  （`## 20.1` の「規約に無い書き方」）。表に無い設定は、`<設定のキー>：<値>` の形で書けばよい。
- **出力の順序はSPDの順とする。** `接続`・`JPA`・`H2コンソール` などの見出しが変わるところに空行を1行入れる。
- **`※` のコメントは、その直後の項目（行末の `※` はその行の項目）の前の行に、`# <コメント>` として出力する。**
- 値に `\`・`:`・`=` などの properties の特殊文字が含まれていても、エスケープせずに書かれたまま出力する（パスワードなど）。
  問題になりそうな場合は【確認事項】で知らせる。

### 未記入の判定

設定ファイルのSPDは、**ファイル全体を1つの単位**として判定する（`## 0.3`）。

- 条件A：タイトル行の下に枝が1つも無い、または `データベース設定` の下に枝が無い。
- 条件B：`★` を含む行などのマーカー（`## 0.3.4`）がある。**値が空の項目（`DB名：`・`パスワード：`）もマーカーと同じく未記入とする。**
  パスワードが空であることは `パスワード：なし` と書く。
- 未完成の場合は、SPDのコメントの下に `# application.properties：SPDが未記入のため生成していません` の1行だけを置く。
- `未記入判定:` の行には `application.properties=記入済み` のように書く。

### SPDの残し方

**与えられたSPD全体を、ファイルの先頭に、各行の頭に `# ` を付けたコメントとして原文のまま残す。**
SPDの下に空行を1行置き、続けて設定を書く。

### 依存関係

ドライバーの依存関係は `pom.xml` に必要だが、SPDからは生成しない。
データベースに対応する依存関係（H2：`com.h2database:h2`、PostgreSQL：`org.postgresql:postgresql`、
MySQL：`com.mysql:mysql-connector-j`）が、参照できる `pom.xml` に無い場合は、【確認事項】で知らせる。
`pom.xml` が参照できない場合は、必要な依存関係を【確認事項】に1行で書く。

### 生成例

```
設定ファイル：application.properties
│
└─データベース設定
      ├─データベース：H2
      │
      ├─接続
      │    ├─接続URL
      │    │    ├─DB名：bookstore
      │    │    └─記録場所：インメモリー
      │    │
      │    └─認証情報
      │          ├─ユーザー名：sa
      │          └─パスワード：なし
      │
      ├─JPA
      │    ├─スキーマ自動生成：create-drop
      │    ├─SQL ログを表示する
      │    ├─SQL を見やすく整形する
      │    │
      │    │  ※トランザクションが終わると EntityManager が閉じる
      │    └─Open Session in View を有効にしない
      │
      └─H2コンソール
            ├─H2コンソールを有効にする
            └─パス：/h2-console
```

`src/main/resources/application.properties`

```properties
# 設定ファイル：application.properties
# │
# └─データベース設定
#       ├─データベース：H2
#       │
#       ├─接続
#       │    ├─接続URL
#       │    │    ├─DB名：bookstore
#       │    │    └─記録場所：インメモリー
#       │    │
#       │    └─認証情報
#       │          ├─ユーザー名：sa
#       │          └─パスワード：なし
#       │
#       ├─JPA
#       │    ├─スキーマ自動生成：create-drop
#       │    ├─SQL ログを表示する
#       │    ├─SQL を見やすく整形する
#       │    │
#       │    │  ※トランザクションが終わると EntityManager が閉じる
#       │    └─Open Session in View を有効にしない
#       │
#       └─H2コンソール
#             ├─H2コンソールを有効にする
#             └─パス：/h2-console

spring.datasource.url=jdbc:h2:mem:bookstore
spring.datasource.username=sa
spring.datasource.password=

spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
# トランザクションが終わると EntityManager が閉じる
spring.jpa.open-in-view=false

spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

PostgreSQL・MySQL では、`接続URL` の下を `ホスト名`・`ポート番号`・`DB名` にし、`H2コンソール` を書かない。

```
      ├─接続
      │    ├─接続URL
      │    │    ├─ホスト名：localhost
      │    │    ├─ポート番号：5432
      │    │    └─DB名：bookstore
```

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/bookstore
```

