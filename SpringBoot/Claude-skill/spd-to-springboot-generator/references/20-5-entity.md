## 20.5 エンティティ

### 記法

```
エンティティ：Member
│
├─目的：会員を表すエンティティ
├─テーブル：members
│
├─フィールド
│  ├─番号：@主キー @自動採番 Long id
│  ├─名前：@必須 String name
│  ├─メール：@一意 String email
│  ├─入会日：LocalDate joinedOn
│  └─タグ：@値コレクション Set<String> tags
│
├─関連
│  └─所属：多対一 Department department
│
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター
```

### フィールドのマーカー

マーカーの `@` は全角 `＠` で書いてもよい（`## 20.1`）。


| マーカー | 生成されるアノテーション |
|---|---|
| `@主キー` | `@Id` |
| `@自動採番` | `@GeneratedValue(strategy = GenerationType.IDENTITY)` |
| `@必須` | `@Column(nullable = false)` |
| `@一意` | `@Column(unique = true)` |
| `@桁数(N)` | `@Column(length = N)` |
| `@列名(x)` | `@Column(name = "x")` |
| `@値コレクション` | `@ElementCollection` |
| （マーカーなし） | アノテーションを付けない |

- 複数のマーカーは1つの `@Column` にまとめる（`@必須 @一意` → `@Column(nullable = false, unique = true)`）。
- `@主キー` が1つも無い場合は、生成せず `## 0.8` の報告の【確認事項】に載せること。
- `@値コレクション` は、要素が文字列・ラッパークラス・`@Embeddable` クラスである `List`・`Set`・`Map` のフィールドに付ける。
  要素がエンティティの場合は `フィールド` ではなく `関連` に書く。
- `@値コレクション` には `@CollectionTable`・`@Column` を付けず、テーブル名・列名はJPAの既定の命名に任せる。
  他のマーカー（`@必須`・`@一意` など）と組み合わせてはならない。組み合わされていた場合は生成せず、
  `## 0.8` の報告の【確認事項】に載せること。
- 日付・時刻のフィールドは `java.time` の型（`LocalDate`・`LocalDateTime`・`LocalTime` など）で書き、
  **アノテーションを付けない。** 型から保存形式が決まるため、`@Temporal` は不要である
  （`java.time` の型に付けると、Hibernate 6 では起動時にエラーになる）。
- SPDに `Date`・`Calendar`（`java.util.Date`・`java.sql.Date`・`java.util.Calendar`）が書かれていた場合は生成せず、
  `java.time` の型への書き換えを促す旨を `## 0.8` の報告の【確認事項】に載せること。

### 関連のマーカー

| SPDの記述 | 生成 |
|---|---|
| `所属：多対一 Department department` | `@ManyToOne(fetch = FetchType.LAZY)` + `@JoinColumn(name = "department_id")` |
| `受講：一対多 List<Enrollment> enrollments ※mappedBy=member` | `@OneToMany(mappedBy = "member")` |
| `詳細：一対一 MemberDetail detail` | `@OneToOne` |
| `資格：多対多 List<License> licenses` | `@ManyToMany` |

- **`多対一`・`一対一` は必ず `fetch = FetchType.LAZY` を付ける。** N+1問題を避けるためである。
- `一対多`・`多対多` は既定で遅延読み込みのため、`fetch` を書かない。
- `@JoinColumn` の既定の列名は `<フィールド名>_id` とする。`※列名=…` の指定があればそれに従う。

### その他

- クラスには `@Entity` を付ける。`テーブル` ノードがある場合は `@Table(name = "…")` も付ける。
- **JPAは引数なしコンストラクタを必要とする。** `自動生成` に `コンストラクタ：引数なし` が
  書かれていない場合でも補い、その旨を宣言の直前に行コメント1行で明示する。
- `自動生成` の各項目（ゲッター・セッター・toString・等値判定）は `spd-core` の `## 9.6.4` に従う。
- `等値判定` は主キーだけを対象にすることが望ましい。`←` の指定が無い場合は主キーを対象とし、
  その旨を行コメントで明示する。

