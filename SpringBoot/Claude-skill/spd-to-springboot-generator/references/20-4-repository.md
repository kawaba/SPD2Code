## 20.4 リポジトリ

### 記法

```
リポジトリ：BookRepository
│
├─目的：書籍の永続化を行う
├─対象：Book
├─主キー：Long
│
├─検索メソッド
│    ├─表題で検索：List<Book> findByTitle(String title)
│    ├─表題の部分一致：List<Book> findByTitleContaining(String keyword)
│    └─価格の降順で全件：List<Book> findAllByOrderByPriceDesc()
│
└─メソッド：searchByPriceAndTitle
      ├─目的：価格と表題で検索する
      ├─引数
      │    ├─上限価格：@パラメータ Integer price
      │    └─表題のキーワード：@パラメータ String title
      ├─戻り値：List<Book>、書籍のリスト
      └─JPQL：価格がprice以下で表題にtitleを含む書籍を検索し、価格の昇順に並べて返す
```

### 生成規則

```java
public interface BookRepository extends JpaRepository<Book, Long> {
    List<Book> findByTitle(String title);               // 表題で検索
    List<Book> findByTitleContaining(String keyword);   // 表題の部分一致
    List<Book> findAllByOrderByPriceDesc();             // 価格の降順で全件

    /**
     * 価格と表題で検索する
     *
     * @param price 上限価格
     * @param title 表題のキーワード
     * @return 書籍のリスト
     */
    // JPQL：価格がprice以下で表題にtitleを含む書籍を検索し、価格の昇順に並べて返す
    @Query("SELECT b FROM Book b WHERE b.price <= :price AND b.title LIKE CONCAT('%', :title, '%') ORDER BY b.price ASC")
    List<Book> searchByPriceAndTitle(@Param("price") Integer price, @Param("title") String title);
}
```

- `対象` と `主キー` から `JpaRepository<対象, 主キー>` を組み立てる。
- **`interface` として生成する。** `@Repository` は付けない（Spring Data JPA が自動検出するため）。
- `検索メソッド` が無い、または `検索メソッド：なし` の場合は、その部分のメソッドを生成しない（これは未記入ではない）。
  `メソッド：` も無ければ、メソッドを持たない空のインタフェースになる。

### 検索メソッド（命名規約によるメソッド）

- `検索メソッド` の各行は、`<説明>：<シグネチャ>` の形である。シグネチャは**そのまま**宣言にし、
  説明は行末の行コメントにする。本体は書かない。
- メソッド名がSpring Dataの命名規約に合わない場合は、**推測で `@Query` を補わず**、
  `## 0.8` の報告の【確認事項】に載せること。命名規約で書けない検索は、下の `メソッド：` と `JPQL` で書く。

### JPQL によるメソッド（`メソッド：` ＋ `JPQL`）

リポジトリの `メソッド：` は、`目的`・`引数`・`戻り値` を持ち、**`処理` の代わりに `JPQL` を書く。**
JPQL が処理の本体に当たるからである。

| ノード | 生成されるもの |
|---|---|
| `メソッド：名前` | インタフェースの抽象メソッド（`spd-core` の `## 9.6.6` と同じ Javadoc を付ける） |
| `引数` の各行 | 引数。**マーカーの有無にかかわらず `@Param("<変数名>")` を付ける** |
| `JPQL：<自然文>` | 自然文から組み立てた `@Query("…")`。直前に `// JPQL：<自然文>` の行コメントを付ける |
| `JPQL："<JPQL文>"` | 引用符の中をそのまま `@Query("…")` にする |

- **`JPQL` の指示は特別なものとして扱い、自然文から必ず `@Query` を生成する。**
  `検索メソッド` の「推測で `@Query` を補わない」という規則の例外である。
- **引数名は、エンティティ（`対象`）のフィールド名と同じにしなければならない。** 自然文の中の引数名は、
  同じ名前のフィールドとの条件として読む（`価格がprice以下` → `b.price <= :price`）。
  引数名と同じ名前のフィールドがエンティティに無い場合は、そのメソッドを生成せず、【確認事項】に載せること。
- **引数の型は、同じ名前のフィールドの型と同じにする。** 違う場合（`Integer` のフィールドに `BigDecimal` の引数など）は
  生成せず、【確認事項】に載せること（Hibernate 6 は、パラメータの型が合わないと実行時に例外を投げる）。
- 自然文の中の条件・並び順が、フィールドや引数に対応づけられない場合も、生成せず【確認事項】に載せること。
- 同じフィールドに2つの条件を付ける場合（下限と上限など）のように、引数名をフィールド名にそろえられない検索は、
  `JPQL："…"` と JPQL 文を直接書いてもらう。直接書かれた JPQL 文は、名前の照合をせずにそのまま使う。
- JPQL の中では、エンティティのクラス名とフィールド名を使う（テーブル名・列名ではない）。
  別名はエンティティ名の先頭の1文字を小文字にしたもの（`Book` → `b`）とする。
- `引数` の `@パラメータ` は、コントローラーでは `@RequestParam` だが、**リポジトリでは `@Param` になる。**
  リポジトリでは書かなくても `@Param` を付けるが、読み手のために書くことを勧める。
- `JPQL` の代わりに `処理` が書かれていた場合は、生成せず【確認事項】に載せること（インタフェースには処理を書けない）。

**自然文の読み方**

| 自然文 | JPQL |
|---|---|
| `priceがX以下`・`以上`・`より小さい`・`より大きい` | `b.price <= :X`・`>=`・`<`・`>` |
| `titleがXと等しい`・`titleがX` | `b.title = :X` |
| `titleにXを含む` | `b.title LIKE CONCAT('%', :X, '%')` |
| `titleがXで始まる`・`Xで終わる` | `b.title LIKE CONCAT(:X, '%')`・`LIKE CONCAT('%', :X)` |
| `〜かつ〜`・`〜で〜`（条件の連結） | `AND` |
| `〜または〜` | `OR` |
| `priceの昇順に並べる`・`降順` | `ORDER BY b.price ASC`・`DESC` |
| `件数を返す` | `SELECT COUNT(b) FROM …` |

- 表の `price`・`title` は例であり、フィールドは日本語の説明（エンティティのSPDの `価格：Integer price` の `価格`）で書いてもよい。
  引数は必ず変数名で書く。
- `LIKE %:title%` の形（Spring Data 独自の拡張）は生成しない。標準の `CONCAT` を使う。

