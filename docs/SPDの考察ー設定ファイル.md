# SPDの考察 ― 設定ファイル（application.properties）

Spring Boot の `application.properties` を SPD から生成する書き方の研究メモ。
今回はデータベース設定を扱う。

---

## 1. 検討対象の SPD（初版）

```
    設定ファイル：application.properties
    │
    └─データベース設定
          ├─前提条件
          │    ├─アクセス方式：Spring Data JPA
          │    └─フェーズ：開発フェーズ
          │
          ├─データベース：H2
          │
          ├─自動生成
          │    ├─接続URL （インメモリー）
          │    ├─ドライバークラス名
          │    ├─スキーマ自動生成・更新機能
          │    ├─SQL ログを表示する
          │    ├─SQL を見やすく整形する
          │    └─H2コンソールを有効化
          │
          └─認証情報
                ├─ユーザー名：sa
                └─パスワード：なし
```

---

## 2. 特別な変換規則なしで生成できるか

**生成できる。** 初版の SPD からは次の内容を生成できる。

```properties
# ===== データベース設定（H2 / Spring Data JPA / 開発フェーズ） =====

# 接続URL（インメモリー）
spring.datasource.url=jdbc:h2:mem:testdb
# ドライバークラス名
spring.datasource.driver-class-name=org.h2.Driver
# 認証情報
spring.datasource.username=sa
spring.datasource.password=

# スキーマ自動生成・更新機能
spring.jpa.hibernate.ddl-auto=update
# SQL ログを表示する
spring.jpa.show-sql=true
# SQL を見やすく整形する
spring.jpa.properties.hibernate.format_sql=true

# H2コンソールを有効化
spring.h2.console.enabled=true
```

ただし、**SPD に書かれておらず、生成時に推測で補った箇所が2つある**（DB名 `testdb` と `ddl-auto` の値）。SPD で確定させたい場合は、ここが修正ポイントになる。

---

## 3. 修正の提案

### 3.1 DB名（`testdb`）を明記する

「接続URL（インメモリー）」だけでは DB名が決まらない。Spring Boot 2.3 以降は URL を省略するとランダムな名前になり、H2 コンソールから接続しにくくなる。

→ `接続URL：インメモリー、DB名：testdb`

### 3.2 `ddl-auto` の値を明記する

「スキーマ自動生成・更新機能」は `create` / `create-drop` / `update` のどれとも読める。初版からは「更新」という語で `update` を選んだが、インメモリー DB では再起動のたびにデータが消えるので、`update` と `create-drop` で実際の違いはほとんどない。学習用なら意味がはっきりしている `create-drop` か `create` のほうが適切かもしれない。

→ `スキーマ自動生成：create（起動時に作成）` など

### 3.3 「自動生成」という見出し名

「生成時に標準値で補ってよい項目」という意味だと思われるが、Hibernate の「スキーマ自動生成」と紛らわしい。`標準設定` や `開発用設定` のような名前が考えられる。

---

## 4. 追加の提案（任意）

| 項目 | プロパティ | 理由 |
|---|---|---|
| H2コンソールのパス | `spring.h2.console.path=/h2-console` | 既定値だが、明記するとアクセスURLが分かりやすくなる |
| Open Session in View 無効化 | `spring.jpa.open-in-view=false` | 明示すると起動時の警告が消える。`false` にするとビュー描画中の意図しないSQL発行を防げるが、関連データは Service 層で取得しておく必要がある（未取得だと `LazyInitializationException`）※4.1 参照 |
| 初期データ投入 | `spring.jpa.defer-datasource-initialization=true` | `data.sql` を使う場合、Hibernate がテーブルを作った後に実行させるために必要 |
| SQLのバインド値の表示 | `logging.level.org.hibernate.orm.jdbc.bind=trace` | `show-sql` だけでは `?` の中身が見えない |

**注意**：Spring Security を導入すると、H2 コンソールがログイン認証と frame 制限でブロックされる。後でセキュリティ設定を扱うときに関わってくる。

### 4.1 Open Session in View の警告について

Spring Boot 2.0 以降、`spring.jpa.open-in-view` を設定していない Web アプリを起動すると、次のような警告が出る。

```
WARN 12345 --- [  restartedMain] JpaBaseConfiguration$JpaWebConfiguration : spring.jpa.open-in-view is enabled by default. Therefore, database queries may be performed during view rendering. Explicitly configure spring.jpa.open-in-view to disable this warning
```

> （訳）`spring.jpa.open-in-view` は既定で有効になっています。そのため、ビューの描画中にデータベースへの問い合わせが実行される可能性があります。この警告を消すには、`spring.jpa.open-in-view` を明示的に設定してください。

**表示される条件**

- Spring Data JPA を使った Web アプリ（Spring MVC）であること
- `spring.jpa.open-in-view` を**明示的に設定していない**こと

`true` と明示しても警告は消える。警告の目的は「無効にせよ」ではなく、「既定で有効になっていることを分かったうえで選べ」という点にある。

**Open Session in View とは**

HTTP リクエストの開始からレスポンスを返し終わるまで、JPA の EntityManager（DB接続）を開いたままにする仕組み。

- **有効（既定）**：Thymeleaf などのビューを描画している最中でも、遅延ロード（LAZY）の関連エンティティにアクセスでき、そのタイミングで SQL が発行される。手軽な反面、どこで SQL が発行されるのか見えにくく、N+1 問題の原因にもなる。また、リクエストの間ずっと DB 接続を占有する。
- **無効（`false`）**：トランザクション（Service メソッド）が終わると EntityManager が閉じる。その後で未取得の LAZY 関連にアクセスすると `LazyInitializationException` が発生する。必要なデータは、Service 層で `JOIN FETCH` や `@EntityGraph` を使って取得しておく必要がある。

---

## 5. 削除の検討

- **ドライバークラス名**：URL から自動判別されるので省略できる。ただ、教材として何が設定されているかを見せたいなら、残す意味はある。

---

## 6. 改訂版 SPD の例

```
    設定ファイル：application.properties
    │
    └─データベース設定
          ├─前提条件
          │    ├─アクセス方式：Spring Data JPA
          │    └─フェーズ：開発フェーズ
          │
          ├─データベース：H2
          │
          ├─接続
          │    ├─接続URL：インメモリー、DB名：testdb
          │    ├─ドライバークラス名
          │    └─認証情報
          │          ├─ユーザー名：sa
          │          └─パスワード：なし
          │
          ├─JPA
          │    ├─スキーマ自動生成：create-drop
          │    ├─SQL ログを表示する
          │    ├─SQL を見やすく整形する
          │    └─Open Session in View を無効化
          │
          └─H2コンソール
                ├─有効化
                └─パス：/h2-console
```

---

## 7. 見出しをプロパティのプレフィックスに合わせる理由

`application.properties` の設定は、プレフィックスごとに役割が分かれている。

| プレフィックス | 役割 | DB製品への依存 |
|---|---|---|
| `spring.datasource.*` | どのDBに、どう接続するか | **強い**（URL・ドライバー・認証情報は製品ごとに違う） |
| `spring.jpa.*` | JPA/Hibernate の動作（スキーマ生成、SQLログなど） | **弱い**（ほぼどのDBでも同じ書き方） |
| `spring.h2.console.*` | H2 の管理画面 | **H2専用** |

SPD の見出しをこの区分に合わせておくと、DB を替えたときの影響範囲が見出し単位で分かる。

DB を切り替えたときに変わるのは「接続」だけではなく、正確には次の3点。

1. **接続**：差し替える（メインの変更）
2. **H2コンソール**：H2 専用なので削除する
3. **JPA のスキーマ自動生成**：値の見直しが必要。PostgreSQL はデータが残る DB なので、`create-drop` のままだと起動するたびにテーブルとデータが消える

それでも見出しが分かれていれば、「接続は差し替え、H2コンソールは削除、JPA は1項目だけ見直し」と見出し単位で判断できる。見出しが混ざっていると、1項目ずつ DB 依存かどうかを調べることになる。

---

## 8. H2 → PostgreSQL の比較

### 8.1 SPD の比較

```
【H2版】                                   【PostgreSQL版】
データベース設定                           データベース設定
├─前提条件                                 ├─前提条件
│  ├─アクセス方式：Spring Data JPA         │  ├─アクセス方式：Spring Data JPA        （同じ）
│  └─フェーズ：開発フェーズ                │  └─フェーズ：開発フェーズ               （同じ）
│                                          │
├─データベース：H2                         ├─データベース：PostgreSQL                ★変更
│                                          │
├─接続                                     ├─接続                                    ★差し替え
│  ├─接続URL：インメモリー、DB名：testdb   │  ├─接続URL：ホスト：localhost、
│  │                                       │  │         ポート：5432、DB名：testdb
│  ├─ドライバークラス名                    │  ├─ドライバークラス名
│  └─認証情報                              │  └─認証情報
│     ├─ユーザー名：sa                     │     ├─ユーザー名：postgres
│     └─パスワード：なし                   │     └─パスワード：postgres
│                                          │
├─JPA                                      ├─JPA
│  ├─スキーマ自動生成：create-drop         │  ├─スキーマ自動生成：update              ★値を見直し
│  ├─SQL ログを表示する                    │  ├─SQL ログを表示する                   （同じ）
│  ├─SQL を見やすく整形する                │  ├─SQL を見やすく整形する               （同じ）
│  └─Open Session in View を無効化         │  └─Open Session in View を無効化        （同じ）
│                                          │
└─H2コンソール                             （なし）                                  ★削除
   ├─有効化
   └─パス：/h2-console
```

### 8.2 生成される application.properties の比較

**H2版**

```properties
# ----- 接続 -----
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# ----- JPA -----
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.open-in-view=false

# ----- H2コンソール -----
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

**PostgreSQL版**

```properties
# ----- 接続 -----
spring.datasource.url=jdbc:postgresql://localhost:5432/testdb
spring.datasource.driver-class-name=org.postgresql.Driver
spring.datasource.username=postgres
spring.datasource.password=postgres

# ----- JPA -----
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.open-in-view=false
```

変わるのは「接続」の4行、`ddl-auto` の1行、H2コンソールの2行（削除）。JPA の残り3行はそのまま使える。

### 8.3 補足

- **方言（Dialect）の指定は不要**：Hibernate 6（Spring Boot 3）は接続先から DB を自動判別する。古い解説にある `spring.jpa.database-platform=...PostgreSQLDialect` はいらない。
- **application.properties だけでは完結しない**：`pom.xml`（または `build.gradle`）の依存関係も `com.h2database:h2` から `org.postgresql:postgresql` に替える必要がある。SPD で DB 製品を切り替えるなら、依存関係も同じ「データベース：PostgreSQL」から生成する前提にしておくと、切り替えが1か所で済む。
- **PostgreSQL 側の事前準備**：DB（`testdb`）とユーザーは、アプリの起動前に PostgreSQL 側で作っておく必要がある。H2 のインメモリーと違い、自動では作られない。
- **パスワードの扱い**：開発用なら平文でも構わないが、本番フェーズでは `spring.datasource.password=${DB_PASSWORD}` のように環境変数から読む形にするのが一般的。「前提条件：フェーズ」の値によって出力を切り替える規則にする手もある。
