## 20.3 サービス

### 記法

リポジトリを呼び出すだけの定型のメソッドは、**`自動生成`** で作る（下記「自動生成」）。
それ以外の処理だけを `メソッド：` で書く。

```
サービス：MemberService
│
├─目的：会員に関する業務処理を行う
│
├─インジェクション
│  └─会員リポジトリ：MemberRepository memberRepository
│
├─自動生成：MemberRepository
│     ├─全件検索
│     ├─新規作成
│     └─詰め替え
│
└─メソッド：countJoinedAfter
     ├─目的：指定した日より後に入会した会員の人数を数える
     ├─トランザクション：参照のみ
     ├─引数：基準日：LocalDate date
     ├─戻り値：long、会員の人数
     └─処理
           └─memberRepositoryのfindAllの結果のうち、joinedOnがdateより後の要素の数を返す
```

### 生成規則

| ノード | 生成されるもの |
|---|---|
| タイトル `サービス：X` | `@Service` を付けた `public class X` |
| `インジェクション` | `private final` フィールド＋コンストラクタインジェクション（`## 20.1` の「インジェクション」） |
| `自動生成：<リポジトリ型名>` | リポジトリを呼び出すだけの定型のメソッド（下記「自動生成」） |
| `メソッド：名前` | `spd-core` の `## 9.6.6` に従う通常のインスタンスメソッド |
| `トランザクション：更新あり` | `@Transactional` |
| `トランザクション：参照のみ` | `@Transactional(readOnly = true)` |

- **`トランザクション` ノードが無い場合は、アノテーションを付けない。** 勝手に補わない。
  データベースを読み書きする `メソッド：` には、`トランザクション` を書くことを勧める。
- `@Transactional` は `org.springframework.transaction.annotation.Transactional` を使う
  （`jakarta.transaction.Transactional` ではない）。
- サービスは HTTP に依存してはならない。SPDに `Model` や `HttpServletRequest` が現れた場合は
  生成せず、`## 0.8` の報告の【確認事項】に載せること。
- **メソッドは、SPDに書かれた順に並べる。** `自動生成` で作るメソッドは、`自動生成` の枝の位置に、
  下の表の順（`詰め替え` は最後）でまとめて置く。
- `主キーで検索` などで見つからないときは例外（`NoSuchElementException`）になる。
  見つからないときの扱いは当面の対象外である（`## 20.1`）。

### 自動生成（リポジトリを呼び出すだけのメソッド）

リポジトリを呼び出すだけの定型のメソッドは、`自動生成：<リポジトリ型名>` の下に項目名を並べて生成できる。

```
サービス：BookService
│
├─目的：本のデータベース操作
├─インジェクション
│    └─本のリポジトリ：BookRepository bookRepository
│
└─自動生成：BookRepository
      ├─全件検索
      ├─主キーで検索
      ├─新規作成
      ├─更新
      ├─削除
      ├─総件数
      ├─ページング
      ├─検索メソッド
      └─詰め替え
```

`BookRepository` が `対象：Book`・`主キー：Long` の場合、各項目から次のメソッドを生成する
（表の `E` は対象の型、`K` は主キーの型、`F` はフォームの型、`repo` はリポジトリの変数名）。

| 項目 | 生成するメソッド | 本体 | トランザクション |
|---|---|---|---|
| `全件検索` | `List<E> findAll()` | `return repo.findAll();` | `@Transactional(readOnly = true)` |
| `主キーで検索` | `E findById(K id)` | `return repo.findById(id).orElseThrow();` | `@Transactional(readOnly = true)` |
| `新規作成`（`新規作成 ← F`） | `E create(F f)` | 下記「フォームからの作成と更新」 | `@Transactional` |
| `更新`（`更新 ← F`） | `E update(F f)` | 下記「フォームからの作成と更新」 | `@Transactional` |
| `削除` | `void deleteById(K id)` | `repo.deleteById(id);` | `@Transactional` |
| `総件数` | `long countAll()` | `return repo.count();` | `@Transactional(readOnly = true)` |
| `ページング` | `Page<E> findAll(Pageable pageable)` | `return repo.findAll(pageable);` | `@Transactional(readOnly = true)` |
| `検索メソッド` | リポジトリの検索メソッドと同名・同シグネチャ | 下記「検索メソッドの移譲」 | `@Transactional(readOnly = true)` |
| `詰め替え`（`詰め替え：F`） | `private void copyFormToEntity(F f, E e)` と `public void copyEntityToForm(E e, F f)` の2つ | 下記「詰め替えメソッド」 | 付けない |

- **書かれた項目だけを生成する。** 上の表に無い項目名があれば、その項目だけを生成せず【確認事項】に載せる
  （ほかの項目は生成する）。`詰め替え` も、`新規作成`・`更新` があるからといって**暗黙に生成してはならない。**
- 項目の右に `※…` の注記（シグネチャのメモなど）が書かれていても、生成には使わない。生成するシグネチャは上の表で決まる。
- `F f` の変数名は、型名の先頭を小文字にしたもの（`BookForm bookForm`）とする（`## 20.2` のフォームと同じ）。
  `E e` の変数名も同じく、型名の先頭を小文字にしたもの（`Book book`）とする。
- `主キーで検索` の `orElseThrow()` は引数なしとする（見つからなければ `NoSuchElementException`）。
- 自動生成したメソッドには、上の表のトランザクションを付ける。
  **`トランザクション` ノードが無ければ付けない、という規則（上の「生成規則」）の例外である。**
- 同じシグネチャのメソッドを `メソッド：` で書いた場合は、そちらを優先し、自動生成はしない（`spd-core` の `## 9.5.1`）。
- 各メソッドの直前に、`// 自動生成：<項目名>` の行コメントを1行付ける。

**フォームの型（`F`）**

- `新規作成`・`更新`・`詰め替え` のフォームの型は、**省略すると「対象のエンティティ名＋`Form`」とする**（`Book` → `BookForm`）。
- 別の名前のフォームを使うときは、`新規作成 ← BookCreateForm`・`更新 ← BookUpdateForm`・`詰め替え：BookCreateForm` のように書く。
- フォームの型のSPD（または生成済みのファイル）が見つからない場合は、推測で補わず、その項目を生成せず【確認事項】で添付を求める。
- 以前の `詰め替え ← F`・`フォームに詰め替え → F` は、規約に無い書き方として報告し、`詰め替え`（または `詰め替え：F`）を案内する（`## 20.1`）。

**リポジトリの指定**

- `自動生成：` の後のリポジトリ型名は、**`インジェクション` にある型でなければならない。**
  無い場合、または型名が書かれていない場合は、`自動生成` 全体を生成せず【確認事項】に載せる。`インジェクション` を勝手に補ってはならない。
- 対象の型と主キーの型は、そのリポジトリの `対象`・`主キー`（`## 20.4`）、または生成済みの
  `JpaRepository<対象, 主キー>` から得る。見つからない場合は自動生成せず、`## 0.8` の報告の【確認事項】に載せること。
- `自動生成` は1つのサービスに**1回だけ**書ける（2つのリポジトリで自動生成するとメソッド名がぶつかるため）。

**検索メソッドの移譲（`検索メソッド`）**

リポジトリのメソッドを呼び出してその結果を返すだけのメソッドを、`spd-core` の `移譲メソッド`（`## 9.6.8`）と
同じ考え方で生成する。

| SPDの記述 | 対象 |
|---|---|
| `検索メソッド` | リポジトリのSPDの `検索メソッド` の全行と、`メソッド：`（JPQL。`## 20.4`）のすべて |
| `検索メソッド ← findByTitle, searchByPriceAndTitle` | `←` で名前を指定したものだけ（区切りは `,` または `、`） |

- **対象は、リポジトリのSPD（または生成済みのリポジトリ）に書かれたメソッドだけ**である。
  `JpaRepository` から継承したメソッド（`findAll`・`count` など）は含まない。それらは上の表の他の項目で生成する。
- 生成するメソッドは、リポジトリのメソッドと**同名・同シグネチャ**（戻り値の型・引数の型と名前が同じ）とし、
  本体は `return repo.<同名>(<引数>);` の1文だけにする。
- `←` で指定した名前がリポジトリに無い場合は、その名前の移譲だけを生成せず【確認事項】に載せる。
- 同じシグネチャのメソッドがサービスに `メソッド：` で書かれている場合は、その1つだけ移譲を生成しない（エラーにはしない）。
- 直前の行コメントは、`// 自動生成：検索メソッド（<リポジトリでの説明>）` とする。
  リポジトリの `メソッド：` の場合は、説明にその `目的` を使う。

```java
// 自動生成：検索メソッド（表題で検索）
@Transactional(readOnly = true)
public List<Book> findByTitle(String title) {
    return bookRepository.findByTitle(title);
}

// 自動生成：検索メソッド（価格と表題で検索する）
@Transactional(readOnly = true)
public List<Book> searchByPriceAndTitle(Integer price, String title) {
    return bookRepository.searchByPriceAndTitle(price, title);
}
```

**フォームからの作成と更新（`新規作成`・`更新`）**

- フォームとエンティティのSPD（または生成済みのJavaファイル）を読み、**名前と型が同じフィールド**を、
  ゲッター・セッターで1つずつコピーする。主キーのフィールドはコピーしない。
- **フォームのフィールドのうち、エンティティに同じ名前・同じ型のフィールドが無いものが1つでもあれば**、
  その項目は生成せず、`## 0.8` の報告の【確認事項】に載せること。推測で型変換や検索を補ってはならない。
  このような場合は、`メソッド：` で処理を書いてもらう。
- `更新` では、フォームに**エンティティの主キーと同じ名前・同じ型のフィールド**が必要である。
  無い場合は生成せず、【確認事項】に載せること。
- 同じフォーム型の `詰め替え` がある場合は、コピーを本体に書かず、`copyFormToEntity(f, e);` の呼び出し1行にする
  （下の2つ目の例）。無い場合は、コピーを本体に直接書く（下の1つ目の例）。

`詰め替え` が無い場合：

```java
// 自動生成：新規作成
@Transactional
public Book create(BookForm bookForm) {
    var book = new Book();
    book.setTitle(bookForm.getTitle());
    book.setPrice(bookForm.getPrice());
    return bookRepository.save(book);
}

// 自動生成：更新
@Transactional
public Book update(BookForm bookForm) {
    var book = bookRepository.findById(bookForm.getId()).orElseThrow();
    book.setTitle(bookForm.getTitle());
    book.setPrice(bookForm.getPrice());
    return bookRepository.save(book);
}
```

`詰め替え` がある場合：

```java
// 自動生成：新規作成
@Transactional
public Book create(BookForm bookForm) {
    var book = new Book();
    copyFormToEntity(bookForm, book);
    return bookRepository.save(book);
}

// 自動生成：更新
@Transactional
public Book update(BookForm bookForm) {
    var book = bookRepository.findById(bookForm.getId()).orElseThrow();
    copyFormToEntity(bookForm, book);
    return bookRepository.save(book);
}
```

**詰め替えメソッド（`詰め替え`）**

- `詰め替え` の1項目から、**両方向の2つのメソッド**を生成する。どちらも、**名前と型が同じフィールド**を
  ゲッター・セッターで1つずつコピーする。
  - `copyFormToEntity(F f, E e)`：フォームからエンティティへ（`新規作成`・`更新` が使う）
  - `copyEntityToForm(E e, F f)`：エンティティからフォームへ（コントローラーの編集画面の表示が使う。`## 20.2` の `詰め替える`）
- **どちらも、コピー先を引数で受け取り、戻り値は `void` とする。**
  `copyFormToEntity` は、`更新` でDBから読んだエンティティに上書きするため、新しいインスタンスを返す形にしない
  （フォームに無いフィールドや関連が消えるため）。`copyEntityToForm` は、オーバーロード（下記）で
  戻り値の型だけが違うメソッドにならないよう、同じ形にそろえる。
- `copyFormToEntity` は**主キーをコピーしない**（`新規作成` の自動採番と `更新` の検索を壊さないため）。
  `copyEntityToForm` は**主キーもコピーする**（編集画面から `更新` に主キーを渡すため）。
- **フォームのフィールドのうち、エンティティに同じ名前・同じ型のフィールドが無いものが1つでもあれば**、
  2つとも生成せず、`## 0.8` の報告の【確認事項】に載せること（「フォームからの作成と更新」と同じ）。
  エンティティにだけあるフィールドは、どちらの向きでもコピーしない。
- `copyFormToEntity` はサービスの中からだけ呼ぶため `private` とし、`copyEntityToForm` は
  コントローラーから呼ぶため `public` とする。どちらも DB にアクセスしないので、`@Transactional` を付けない。
  `新規作成`・`更新` が無いと `copyFormToEntity` は使われないが、そのまま生成する（IDE の「使われていない」という警告は無視してよい）。
- **フォーム型が違えば、`詰め替え` を複数書ける。** 同名のメソッドをオーバーロードとして生成する
  （`詰め替え：BookCreateForm` と `詰め替え：BookUpdateForm` → 2つずつ）。
  同じフォーム型が2回書かれていた場合は、2回目を生成せず【確認事項】に載せる。
- 行コメントは、`// 自動生成：詰め替え（フォーム → エンティティ）`・`// 自動生成：詰め替え（エンティティ → フォーム）` とする。

```java
// 自動生成：詰め替え（フォーム → エンティティ）
private void copyFormToEntity(BookForm bookForm, Book book) {
    book.setTitle(bookForm.getTitle());
    book.setPrice(bookForm.getPrice());
}

// 自動生成：詰め替え（エンティティ → フォーム）
public void copyEntityToForm(Book book, BookForm bookForm) {
    bookForm.setId(book.getId());
    bookForm.setTitle(book.getTitle());
    bookForm.setPrice(book.getPrice());
}
```

