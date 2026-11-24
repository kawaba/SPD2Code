## 20.6 フォーム

### 記法

```
フォーム：BookForm
│
├─目的：書籍の入力フォーム
│
├─フィールド
│    ├─主キー：Long id
│    ├─表題：String title　　　　　＠必須("表題を入力してください")、20文字以内
│    ├─発行日：LocalDate issuedOn　＠過去の日付
│    ├─価格：Integer price　　　　 ＠正の数
│    ├─ISBN：String isbn　　　　　 ＠"^[0-9-]{10,17}$"に一致
│    └─メディア：List<String> mediaTypes　＠必須
│
└─自動生成
      ├─コンストラクタ：引数なし
      ├─ゲッター
      └─セッター
```

**フィールドの検証は、そのフィールドの行の末尾に書く。**

- 変数名の後に `@`（全角 `＠` でもよい。`## 20.1`）を書き、その右に検証を並べる。
  検証が無いフィールドには `@` を書かない。
- 検証の区切りは `、` または `,` とする。1行の中で混在してもよい。
- `@` の前後と区切りの前後の空白は、半角・全角・個数を問わず無視する。位置をそろえるために空白を入れてよい。
- **エンティティのマーカー（`## 20.5`）は型の前に書くが、フォームの検証は変数名の後に書く。**
  エンティティのマーカーは1語ずつアノテーションに対応するが、検証は「20文字以内」のような句であり、
  区切って並べる方が読みやすいためである。
- **正規表現は `"` で囲む**（`"^[0-9-]{10,17}$"に一致`）。引用符の中の `、`・`,` は区切りとみなさない。
- **メッセージは、検証の直後の `()` の中に `"` で囲んで書く**（`必須("表題を入力してください")`）。
  括弧は全角 `（）` でもよい。引用符の中の `、`・`,`・括弧は区切りとみなさない。
  括弧の内側で引用符の外にある空白（`（ "…" ）`）も無視する。
- **`検証` の枝は廃止した。** フォームに `検証` の枝が書かれていた場合は生成せず、
  検証を各フィールドの行の末尾へ移すよう `## 0.8` の報告の【確認事項】に載せること。

### 検証の対応表

| SPDの記述 | 生成されるアノテーション |
|---|---|
| `必須`（`String` の場合） | `@NotBlank` |
| `必須`（`List`・`Set`・`Map` の場合） | `@NotEmpty` |
| `必須`（上記以外） | `@NotNull` |
| `N文字以内` | `@Size(max = N)` |
| `N文字以上` | `@Size(min = N)` |
| `N文字以上M文字以内` | `@Size(min = N, max = M)` |
| `N以上` | `@Min(N)` |
| `M以下` | `@Max(M)` |
| `N以上M以下` | `@Min(N)` + `@Max(M)` |
| `N以上`（N が小数） | `@DecimalMin("N")` |
| `M以下`（M が小数） | `@DecimalMax("M")` |
| `N以上M以下`（N・M のどちらかが小数） | `@DecimalMin("N")` + `@DecimalMax("M")` |
| `N超`・`Nより大きい` | `@DecimalMin(value = "N", inclusive = false)` |
| `M未満` | `@DecimalMax(value = "M", inclusive = false)` |
| `N以上M未満` | `@DecimalMin("N")` + `@DecimalMax(value = "M", inclusive = false)` |
| `N超M以下`・`Nより大きくM以下` | `@DecimalMin(value = "N", inclusive = false)` + `@DecimalMax("M")` |
| `N超M未満`・`Nより大きくM未満` | `@DecimalMin(value = "N", inclusive = false)` + `@DecimalMax(value = "M", inclusive = false)` |
| `整数N桁以内` | `@Digits(integer = N, fraction = 0)` |
| `整数N桁・小数M桁以内` | `@Digits(integer = N, fraction = M)` |
| `正の数` | `@Positive` |
| `正の数または0` | `@PositiveOrZero` |
| `負の数` | `@Negative` |
| `負の数または0` | `@NegativeOrZero` |
| `trueである` | `@AssertTrue` |
| `falseである` | `@AssertFalse` |
| `過去の日付` | `@Past` |
| `今日以前の日付` | `@PastOrPresent` |
| `未来の日付` | `@Future` |
| `今日以降の日付` | `@FutureOrPresent` |
| `値なし` | `@Null` |
| `メール` | `@Email` |
| `URL` | `@URL` |
| `クレジットカード番号` | `@CreditCardNumber` |
| `ISBN` | `@ISBN` |
| `ISBN-10` | `@ISBN(type = ISBN.Type.ISBN_10)` |
| `"<正規表現>"に一致` | `@Pattern(regexp = "…")` |

- 対応表に無い表現は、**推測でアノテーションを作らず**、`## 0.8` の報告の
  【確認事項】に載せること。
- コレクションの `必須` を `@NotNull` にしてはならない。チェックボックスを1つも選ばずに送信すると、
  Spring は `null` ではなく空のコレクションを設定するため、`@NotNull` では検証が働かない。
- **`boolean`・`Boolean` の `必須` は、チェックを強制しない。** `th:field` のチェックボックスは、
  チェックしないと `false` を送るため、`必須`（`@NotNull`）では検証が働かない。
  チェックを求める場合（利用規約への同意など）は `trueである`（`@AssertTrue`）と書く。
- **小数の判定**：`N以上`・`M以下`・`N以上M以下` は、N・M に小数点が無ければ `@Min`・`@Max` を、
  あれば `@DecimalMin`・`@DecimalMax` を生成する。`@DecimalMin`・`@DecimalMax` の値は文字列で書く。
  `超`・`より大きい`・`未満` は、整数でも `@DecimalMin`・`@DecimalMax` に `inclusive = false` を付けて生成する
  （`M未満` を `@Max(M-1)` のように読み替えない）。N・M には負の数（`-10以上`）も書ける。
- `正の数または0` は `0以上`（`@Min(0)`）とほぼ同じ働きをするが、`double` にも使える。どちらを書いてもよい。
- `今日以前の日付`・`今日以降の日付` の「今日」は、`LocalDateTime`・`LocalTime` では現在の時刻を意味する。
- **`値なし`（`@Null`）は、`String` には使えない。** 空の入力欄は `null` ではなく `""` を送るため、
  何も入力しなくても検証に失敗する。`String` 以外の型か、画面に置かない項目にだけ使う。
  `String` の `値なし` は生成せず、【確認事項】に載せること。
- `@Length`（Hibernate Validator）は使わない。文字数の検証は `@Size` で生成する。
- 正規表現は、Javaの文字列リテラルとして正しくなるよう、`\` を `\\` に、`"` を `\"` にして `regexp` に書く
  （`"^\d{3}$"に一致` → `@Pattern(regexp = "^\\d{3}$")`）。
- **メッセージ（`message = "…"`）は、SPDに明示された場合だけ付ける。**
  `必須("表題を入力してください")` → `@NotBlank(message = "表題を入力してください")`。
  1つの検証から2つのアノテーションができる場合（`N以上M以下`）は、両方に同じメッセージを付ける。
- 1つのフィールドに複数の検証がある場合、アノテーションは**SPDに書かれた順**に並べる。
- **フォームに永続化アノテーション（`@Entity`・`@Column` など）を付けてはならない。**
- 検証アノテーションは `jakarta.validation.constraints.*` を使う（`javax.*` ではない）。
  ただし `@URL`・`@CreditCardNumber`・`@ISBN` は Hibernate Validator のもので、
  `org.hibernate.validator.constraints.*` から取る（`spring-boot-starter-validation` に含まれる）。

### 日付・時刻のフィールド

**フォームの `java.time` のフィールドには、検証の有無にかかわらず `@DateTimeFormat` を必ず付ける。**
付けないと、`<input type="date">` などが送る ISO 形式の値（`2026-09-28`）を変換できず、バインドエラーになる。

| 型 | 生成されるアノテーション | 対応する入力欄 |
|---|---|---|
| `LocalDate` | `@DateTimeFormat(iso = DateTimeFormat.ISO.DATE)` | `<input type="date">` |
| `LocalDateTime` | `@DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)` | `<input type="datetime-local">` |
| `LocalTime` | `@DateTimeFormat(iso = DateTimeFormat.ISO.TIME)` | `<input type="time">` |

- `@DateTimeFormat` は `org.springframework.format.annotation.DateTimeFormat` を使う。
- 検証アノテーションの後、フィールド宣言の直前に置く。
- エンティティには付けない（エンティティは画面から直接バインドしないため）。
- `Date`・`Calendar` の扱いはエンティティと同じく、生成せずに報告する（`## 20.5`）。

### 生成例

上の `BookForm` のフィールド部分：

```java
private Long id; // 主キー

@NotBlank(message = "表題を入力してください")
@Size(max = 20)
private String title; // 表題

@Past
@DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
private LocalDate issuedOn; // 発行日

@Positive
private Integer price; // 価格

@Pattern(regexp = "^[0-9-]{10,17}$")
private String isbn; // ISBN

@NotEmpty
private List<String> mediaTypes; // メディア
```

