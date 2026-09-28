---
applyTo: "**/*.java, **/src/main/resources/templates/**/*.html"
description: SPDからSpring Boot（MVC + JPA）のコードを生成する規約。コントローラー・サービス・リポジトリ・エンティティ・フォームの記法と生成規則。
---

<!-- ===== SPRINGBOOT-JAVA v1.8.0 / 2026-09-28 =====
     このファイルは Spring Boot 版ワークスペース固有である。SE版・要件定義版には存在しない。
     テンプレート（.html）編集時にも読み込まれるのは、コントローラーとテンプレートが
     互いに依存するためである（copilot-instructions.md `## 11`）。 -->

# SPD → Spring Boot コード生成規約

## 20.1 適用範囲と前提

- **対象は Controller + Service + Thymeleaf の MVC 構成と、JPA によるデータアクセスである。**
- REST API（`@RestController`・JSON応答）は**当面の対象外**である。
  SPDに `REST` の指定があった場合は生成せず、`## 0.8` の報告の【確認事項】に載せること。
- ビルドは Maven、テンプレートエンジンは Thymeleaf を前提とする。
- このファイルは `spd-core.instructions.md` を**前提として上乗せする**ものである。
  SPDの記号・制御構造・`処理` の中身の読み方は、すべて `spd-core` に従う。

### 層の責務と依存方向

```
Controller  →  Service  →  Repository  →  （DB）
                  ↓
              Entity / Form
```

- **依存は上から下への一方向のみ**とする。
- **コントローラーからリポジトリを直接呼び出すコードを生成してはならない。**
  SPDにそう書かれていた場合も生成せず、`## 0.8` の報告の【確認事項】に載せること。
- 各層の責務は次のとおりである。

| 層 | 責務 | してはならないこと |
|---|---|---|
| Controller | HTTPの受け口、画面の選択、Modelへの受け渡し | 業務ロジック、DBアクセス |
| Service | 業務ロジック、トランザクション境界 | HTTPに依存する型（`Model`・`HttpServletRequest`）の使用 |
| Repository | 永続化 | 業務ロジック |
| Entity | テーブルとの対応 | 業務ロジック、画面用の項目 |
| Form | 画面の入力項目と入力検証 | 永続化アノテーション |

### 未記入判定の適用

`## 0.3`（SPDの未記入部分は生成しない）は、このファイルで定義する型にもそのまま適用する。
判定単位と「骨格の枝」は次のとおり読み替える。

| タイトル行 | 単位の種類 | 骨格の枝（条件Bを見る範囲） |
|---|---|---|
| `コントローラー: 名前` | 型定義 | `依存` |
| `サービス: 名前` | 型定義 | `依存`・`自動生成` |
| `リポジトリ: 名前` | 型定義 | `対象`・`主キー` |
| `エンティティ: 名前` | 型定義 | `フィールド`・`自動生成` |
| `フォーム: 名前` | 型定義 | `フィールド`・`自動生成` |

- `メソッド:`・`検索メソッド` の各枝は、**1つずつ独立に判定する**（`## 0.3.5`）。
- コントローラーの `メソッド:` は、`マッピング` があってもなくても**通常のメソッドとして判定する**。
  `処理` の枝が無ければ、`## 0.3.3` の条件Aにより未完成である。
- `依存：なし`・`関連：なし` は、`## 0.3.3` の `なし` と同じく**記入済み**として扱う。
- `依存` の別名 `インジェクション`（`## 20.2`）も、骨格の枝として `依存` と同じに扱う。

### マーカーの `@`

- SPDのマーカー（`@検証`・`@主キー` など、`@` で始まる指定）の `@` は、**半角 `@` と全角 `＠` のどちらで書いてもよい。**
  両者は同じマーカーとして読む（`＠主キー` は `@主キー` と同じ）。1つのSPDの中で混在してもよい。
- この規約の本文と表では、半角 `@` で表記する。
- **生成するJavaコードのアノテーションは、必ず半角 `@` で書く。**

---

## 20.2 コントローラー

### 記法

コントローラーのメソッドは、**一般の `メソッド:`（`spd-core` の `## 9.6.6`）と同じ形**で書く。
`目的`・`引数`・`戻り値`・`処理` を持ち、そこに `マッピング` を加えたものがハンドラーメソッドになる。
Javaで、マッピングのアノテーションが付いたメソッドがハンドラーになるのと同じである。

```
コントローラー：MemberController
│
├─目的：会員の一覧・登録を扱う
├─基底パス：/members
│
├─依存
│  └─会員サービス：MemberService memberService
│
├─メソッド：list
│  ├─目的：会員の一覧を表示する
│  ├─マッピング：GET
│  ├─引数
│  │    └─モデル：Model model
│  ├─戻り値：String、表示するテンプレート名
│  └─処理
│        ├─memberServiceのfindAllを呼び出した結果をmembersとしてテンプレートへ渡す
│        └─"member/list"を返す
│
├─メソッド：newForm
│  ├─目的：新規登録画面を表示する
│  ├─マッピング：GET /new
│  ├─引数
│  │    └─フォーム：MemberForm memberForm
│  ├─戻り値：String、表示するテンプレート名
│  └─処理
│        └─"member/form"を返す
│
└─メソッド：create
     ├─目的：入力された会員を登録する
     ├─マッピング：POST
     ├─引数
     │    ├─フォーム：@検証 MemberForm memberForm
     │    ├─検証結果：BindingResult result
     │    └─メッセージ：RedirectAttributes redirect
     ├─戻り値：String、表示するテンプレート名またはリダイレクト先
     └─処理
           ├─◇─resultにエラーがある
           │  └─"member/form"を返す
           ├─memberServiceのcreateをmemberFormを引数にして呼び出す
           ├─"登録しました"をフラッシュメッセージmessageとして渡す
           └─/membersへリダイレクトする
```

### ノードの意味と生成規則

| ノード | 生成されるもの |
|---|---|
| タイトル `コントローラー：X` | `@Controller` を付けた `public class X` |
| `目的：…` | クラス宣言の直上の行コメント（`// …`） |
| `基底パス：/members` | クラスに `@RequestMapping("/members")` |
| `依存` | `private final` フィールド＋**コンストラクタインジェクション** |
| `メソッド：名前` | `spd-core` の `## 9.6.6` に従う通常のインスタンスメソッド |
| `マッピング：GET /new`（`メソッド` の子） | `@GetMapping("/new")` などのマッピング。これが付いたメソッドがハンドラーメソッドになる |

- タイトルは `コントローラ：X`（長音なし）と書いてもよい。`コントローラー：X` と同じに扱う。
- **`マッピング` は、必ず `メソッド` の子として書く。** コントローラーの直下に書かれた場合は、
  どのメソッドに付くのか決められないため生成せず、`## 0.8` の報告の【確認事項】に載せること
  （`spd-core` の `## 9.5.1` のとおり、項目の並び順には意味が無い）。
- `マッピング` の無い `メソッド` は、ハンドラーではない通常のメソッドとして生成する（アノテーションを付けない）。
- **ハンドラーメソッドの戻り値は `String` である。** 返す文字列が、表示するテンプレート名（`## 11.1`）
  またはリダイレクト先になる。`戻り値` が `String` 以外の場合は生成せず、`## 0.8` の報告の【確認事項】に載せること。

**`マッピング` の書式**

`マッピング：<HTTPメソッド> [<パス>]` と書く。パスは `基底パス` からの相対である。

| SPDの記述 | 生成 |
|---|---|
| `マッピング：GET` | `@GetMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため` |
| `マッピング：GET /` | `@GetMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため` |
| `マッピング：GET /{id}/edit` | `@GetMapping("/{id}/edit")` |
| `マッピング：POST` | `@PostMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため` |
| `マッピング：POST /{id}/delete` | `@PostMapping("/{id}/delete")` |

- **パスを省略した場合、または `/` だけの場合は、`基底パス` そのものに割り当てる。**
  HTTPメソッドにかかわらず、マッピングの引数を `{"", "/"}` とし、同じ行の末尾に
  行コメント `// 末尾の / の有無どちらでも受け付けるため` を付ける。
  Spring Boot 3 以降は末尾の `/` を区別するため、`@GetMapping` だけでは
  `/members/` へのアクセスが 404 になる。
- `基底パス` が無いコントローラーでも同じに生成する。
- **パスを明示した場合は、そのパスだけを書く。** 末尾に `/` を付けた別名を加えてはならない
  （`マッピング：GET /books` → `@GetMapping("/books")`。`{"/books", "/books/"}` としない）。
  `{"", "/"}` にするのは、パスを省略した場合と `/` だけの場合に限る。

**`引数` の書式**

`<説明>：<種別マーカー> <型> <変数名>` の形で書く。種別は説明の直後のノード名で判別する。

| SPDの記述 | 生成される引数 |
|---|---|
| `モデル：Model model` | `Model model` |
| `フォーム：MemberForm memberForm` | `MemberForm memberForm` |
| `フォーム：@検証 MemberForm memberForm` | `@Valid MemberForm memberForm` |
| `パス変数：Long id` | `@PathVariable Long id` |
| `パラメータ：String keyword` | `@RequestParam String keyword` |
| `パラメータ：String keyword = ""` | `@RequestParam(defaultValue = "") String keyword` |
| `検証結果：BindingResult result` | `BindingResult result` |
| `メッセージ：RedirectAttributes redirect` | `RedirectAttributes redirect` |
| `引数：なし` | 引数なし |

- **`フォーム` の変数名は、型名の先頭の1文字を小文字にしたものとする**（`MemberForm` → `memberForm`）。
  **`@ModelAttribute` は付けない。** Spring では、クラス型の引数は `@ModelAttribute` が付いているものとして
  扱われ、Model の属性名は型名の先頭を小文字にしたものになる。この規則により、変数名・Model の属性名・
  テンプレートの `受取り` の名前がすべて一致する（`## 11.3`）。
- SPDに別の変数名（`フォーム：MemberForm form` など）が書かれていた場合は、**名前を勝手に変えず**、
  そのメソッドを生成せずに `## 0.8` の報告の【確認事項】に載せること。
- **`@Valid` を付けた引数の直後には、必ず `BindingResult` を置く。**
  SPDに `検証結果` が書かれていない場合は補い、その旨を宣言の直前に行コメント1行で明示する。
- **`Model model` は、原則として `引数` に書く。** 書かれていなくても、`処理` に
  「〜をテンプレートへ渡す」がある場合は `Model model` を補い、その旨を宣言の直前に行コメント1行で明示する。
  `引数：なし` と書かれている場合も同じである。

**`処理` の中の Web 固有の表現**

| SPDの記述 | 生成 |
|---|---|
| `"member/form"を返す` | `return "member/form";` |
| `/membersへリダイレクトする` | `return "redirect:/members";` |
| `/members/{id}へリダイレクトする` | `return "redirect:/members/" + id;` |
| `"…"をフラッシュメッセージ<名前>として渡す` | `redirect.addFlashAttribute("<名前>", "…");` |
| `<名前>をテンプレートへ渡す` | `model.addAttribute("<名前>", <名前>);` |
| `<式>を<名前>としてテンプレートへ渡す` | `model.addAttribute("<名前>", <式>);` |

- 「テンプレートへ渡す」は「画面へ渡す」と書いてもよい。同じに扱う。
- 「テンプレートへ渡す」の `<名前>` が、テンプレート側の `受取り` と照合する属性名である（`## 11.2`）。
- **フラッシュメッセージはリダイレクトと組で使う。** リダイレクトを伴わない
  `addFlashAttribute` を生成してはならない。

### 生成例

上の `create` から生成されるコード：

```java
@PostMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため
public String create(@Valid MemberForm memberForm,
                     BindingResult result,
                     RedirectAttributes redirect) {
    if (result.hasErrors()) {
        return "member/form";
    }
    memberService.create(memberForm);
    redirect.addFlashAttribute("message", "登録しました");
    return "redirect:/members";
}
```

### 依存の注入

```
├─依存
│  └─会員サービス：MemberService memberService
```
```java
private final MemberService memberService; // 会員サービス

public MemberController(MemberService memberService) {
    this.memberService = memberService;
}
```

- **フィールドへの `@Autowired` を生成してはならない。** 必ずコンストラクタインジェクションにする。
- 依存が1つでもある場合、コンストラクタは**必ず明示的に生成する**（`@RequiredArgsConstructor` などの
  Lombok は使わない。学習者が生成物を読めることを優先する）。
- **`インジェクション` は `依存` の別名**として受理し、黙って読み替える（依存性の注入＝Dependency Injection に由来する）。
  コントローラー・サービスのどちらでも使え、`インジェクション：なし` も `依存：なし` と同じく記入済みとして扱う。

---

## 20.3 サービス

### 記法

```
サービス：MemberService
│
├─目的：会員に関する業務処理を行う
│
├─依存
│  └─会員リポジトリ：MemberRepository memberRepository
│
├─メソッド：findAll
│  ├─目的：全会員を取得する
│  ├─引数：なし
│  ├─戻り値：List<Member>、全会員のリスト
│  └─処理
│        └─memberRepositoryのfindAllの結果を返す
│
└─メソッド：create
     ├─目的：会員を登録する
     ├─トランザクション：更新あり
     ├─引数
     │    └─入力フォーム：MemberForm form
     ├─戻り値：なし
     └─処理
           ├─Memberのインスタンスを作って変数memberに代入する
           ├─formのnameをmemberのnameに設定する
           └─memberRepositoryのsaveをmemberを引数にして呼び出す
```

### 生成規則

| ノード | 生成されるもの |
|---|---|
| タイトル `サービス：X` | `@Service` を付けた `public class X` |
| `依存` | `private final` フィールド＋コンストラクタインジェクション（`## 20.2` と同じ） |
| `メソッド：名前` | `spd-core` の `## 9.6.6` に従う通常のインスタンスメソッド |
| `トランザクション：更新あり` | `@Transactional` |
| `トランザクション：参照のみ` | `@Transactional(readOnly = true)` |

- **`トランザクション` ノードが無い場合は、アノテーションを付けない。** 勝手に補わない。
- `@Transactional` は `org.springframework.transaction.annotation.Transactional` を使う
  （`jakarta.transaction.Transactional` ではない）。
- サービスは HTTP に依存してはならない。SPDに `Model` や `HttpServletRequest` が現れた場合は
  生成せず、`## 0.8` の報告の【確認事項】に載せること。

### 自動生成（リポジトリを呼び出すだけのメソッド）

リポジトリを呼び出すだけの定型のメソッドは、`自動生成：<リポジトリ型名>` の下に項目名を並べて生成できる。

```
サービス：BookService
│
├─目的：本のデータベース操作
├─依存
│    └─本のリポジトリ：BookRepository bookRepository
│
└─自動生成：BookRepository
      ├─全件検索
      ├─主キーで検索
      ├─新規作成 ← BookForm
      ├─更新 ← BookForm
      ├─削除
      ├─総件数
      ├─ページング
      ├─詰め替え ← BookForm
      └─フォームへ詰め替え → BookForm
```

`BookRepository` が `対象：Book`・`主キー：Long` の場合、各項目から次のメソッドを生成する
（表の `E` は対象の型、`K` は主キーの型、`F` は `←`・`→` で指定したフォームの型、`repo` はリポジトリの変数名）。

| 項目 | 生成するメソッド | 本体 | トランザクション |
|---|---|---|---|
| `全件検索` | `List<E> findAll()` | `return repo.findAll();` | `@Transactional(readOnly = true)` |
| `主キーで検索` | `E findById(K id)` | `return repo.findById(id).orElseThrow();` | `@Transactional(readOnly = true)` |
| `新規作成 ← F` | `E create(F f)` | 下記「フォームからの詰め替え」 | `@Transactional` |
| `更新 ← F` | `E update(F f)` | 下記「フォームからの詰め替え」 | `@Transactional` |
| `削除` | `void deleteById(K id)` | `repo.deleteById(id);` | `@Transactional` |
| `総件数` | `long countAll()` | `return repo.count();` | `@Transactional(readOnly = true)` |
| `ページング` | `Page<E> findAll(Pageable pageable)` | `return repo.findAll(pageable);` | `@Transactional(readOnly = true)` |
| `詰め替え ← F` | `private void copyFormToEntity(F f, E e)` | 下記「詰め替えメソッド」 | 付けない |
| `フォームへ詰め替え → F` | `public void copyEntityToForm(E e, F f)` | 下記「詰め替えメソッド」 | 付けない |

- **書かれた項目だけを生成する。** 上の表に無い項目名があれば、不整合として指摘する。
  `詰め替え`・`フォームへ詰め替え` も、`新規作成`・`更新` があるからといって**暗黙に生成してはならない。**
- `F f` の変数名は、型名の先頭を小文字にしたもの（`BookForm bookForm`）とする（`## 20.2` のフォームと同じ）。
  `E e` の変数名も同じく、型名の先頭を小文字にしたもの（`Book book`）とする。
- `主キーで検索` の `orElseThrow()` は引数なしとする（見つからなければ `NoSuchElementException`）。
- 自動生成したメソッドには、上の表のトランザクションを付ける。
  **`トランザクション` ノードが無ければ付けない、という規則（上の「生成規則」）の例外である。**
- 同じシグネチャのメソッドを `メソッド：` で書いた場合は、そちらを優先し、自動生成はしない（`spd-core` の `## 9.5.1`）。
- 各メソッドの直前に、`// 自動生成：<項目名>` の行コメントを1行付ける。

**リポジトリの指定**

- `自動生成：` の後のリポジトリ型名は、**`依存`（`インジェクション`）にある型でなければならない。**
  無い場合、または型名が書かれていない場合は、不整合として指摘する。`依存` を勝手に補ってはならない。
- 対象の型と主キーの型は、そのリポジトリの `対象`・`主キー`（`## 20.4`）、または生成済みの
  `JpaRepository<対象, 主キー>` から得る。見つからない場合は自動生成せず、`## 0.8` の報告の【確認事項】に載せること。
- `自動生成` は1つのサービスに**1回だけ**書ける（2つのリポジトリで自動生成するとメソッド名がぶつかるため）。

**フォームからの詰め替え（`新規作成`・`更新`）**

- `新規作成` と `更新` は `← フォーム型` が必須である。無い場合は、その項目を生成せず不整合として指摘する。
- フォームとエンティティのSPD（または生成済みのJavaファイル）を読み、**名前と型が同じフィールド**を、
  ゲッター・セッターで1つずつコピーする。主キーのフィールドはコピーしない。
- **フォームのフィールドのうち、エンティティに同じ名前・同じ型のフィールドが無いものが1つでもあれば**、
  その項目は生成せず、`## 0.8` の報告の【確認事項】に載せること。推測で型変換や検索を補ってはならない。
  このような場合は、`メソッド：` で処理を書いてもらう。
- `更新` では、フォームに**エンティティの主キーと同じ名前・同じ型のフィールド**が必要である。
  無い場合は生成せず、【確認事項】に載せること。
- 同じフォーム型の `詰め替え ← F` がある場合は、コピーを本体に書かず、`copyFormToEntity(f, e);` の呼び出し1行にする
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

`詰め替え ← BookForm` がある場合：

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

**詰め替えメソッド（`詰め替え`・`フォームへ詰め替え`）**

- `詰め替え ← F` はフォームからエンティティへ、`フォームへ詰め替え → F` はエンティティからフォームへ、
  **名前と型が同じフィールド**をゲッター・セッターで1つずつコピーするメソッドを生成する。
  `←`・`→` のフォーム型は必須である。無い場合は、その項目を生成せず不整合として指摘する。
- **どちらも、コピー先を引数で受け取り、戻り値は `void` とする。**
  `詰め替え` は、`更新` でDBから読んだエンティティに上書きするため、新しいインスタンスを返す形にしない
  （フォームに無いフィールドや関連が消えるため）。`フォームへ詰め替え` は、オーバーロード（下記）で
  戻り値の型だけが違うメソッドにならないよう、同じ形にそろえる。
- `copyFormToEntity` は**主キーをコピーしない**（`新規作成` の自動採番と `更新` の検索を壊さないため）。
  `copyEntityToForm` は**主キーもコピーする**（編集画面から `更新` に主キーを渡すため）。
- **フォームのフィールドのうち、エンティティに同じ名前・同じ型のフィールドが無いものが1つでもあれば**、
  その項目は生成せず、`## 0.8` の報告の【確認事項】に載せること（「フォームからの詰め替え」と同じ）。
  エンティティにだけあるフィールドは、どちらの向きでもコピーしない。
- `copyFormToEntity` はサービスの中からだけ呼ぶため `private` とし、`copyEntityToForm` は
  コントローラー（編集画面の表示）から呼ぶため `public` とする。どちらも DB にアクセスしないので、
  `@Transactional` を付けない。
- **フォーム型が違えば、同じ項目を複数書ける。** 同名のメソッドをオーバーロードとして生成する
  （`詰め替え ← BookCreateForm` と `詰め替え ← BookUpdateForm` → `copyFormToEntity` が2つ）。
  同じ項目に同じフォーム型が2回書かれていた場合は、不整合として指摘する。
- `詰め替え`・`フォームへ詰め替え` は、自動生成の他のメソッドの後に、この順で置く。

```java
// 自動生成：詰め替え
private void copyFormToEntity(BookForm bookForm, Book book) {
    book.setTitle(bookForm.getTitle());
    book.setPrice(bookForm.getPrice());
}

// 自動生成：フォームへ詰め替え
public void copyEntityToForm(Book book, BookForm bookForm) {
    bookForm.setId(book.getId());
    bookForm.setTitle(book.getTitle());
    bookForm.setPrice(book.getPrice());
}
```

---

## 20.4 リポジトリ

### 記法

```
リポジトリ：MemberRepository
│
├─目的：会員の永続化を行う
├─対象：Member
├─主キー：Long
│
└─検索メソッド
     ├─名前で検索：List<Member> findByName(String name)
     ├─名前の部分一致：List<Member> findByNameContaining(String keyword)
     └─番号の降順で全件：List<Member> findAllByOrderByUidDesc()
```

### 生成規則

```java
public interface MemberRepository extends JpaRepository<Member, Long> {
    List<Member> findByName(String name);          // 名前で検索
    List<Member> findByNameContaining(String keyword); // 名前の部分一致
    List<Member> findAllByOrderByUidDesc();        // 番号の降順で全件
}
```

- `対象` と `主キー` から `JpaRepository<対象, 主キー>` を組み立てる。
- **`interface` として生成する。** `@Repository` は付けない（Spring Data JPA が自動検出するため）。
- `検索メソッド` の各行は、`<説明>：<シグネチャ>` の形である。シグネチャは**そのまま**宣言にし、
  説明は行末の行コメントにする。本体は書かない。
- `検索メソッド` が無い、または `検索メソッド：なし` の場合は、メソッドを持たない空の
  インタフェースとして生成する（これは未記入ではない）。
- メソッド名がSpring Dataの命名規約に合わない場合は、**推測で `@Query` を補わず**、
  `## 0.8` の報告の【確認事項】に載せること。

---

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

---

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
| `メール形式` | `@Email` |
| `正の数` | `@Positive` |
| `過去の日付` | `@Past` |
| `未来の日付` | `@Future` |
| `"<正規表現>"に一致` | `@Pattern(regexp = "…")` |

- 対応表に無い表現は、**推測でアノテーションを作らず**、`## 0.8` の報告の
  【確認事項】に載せること。
- コレクションの `必須` を `@NotNull` にしてはならない。チェックボックスを1つも選ばずに送信すると、
  Spring は `null` ではなく空のコレクションを設定するため、`@NotNull` では検証が働かない。
- 正規表現は、Javaの文字列リテラルとして正しくなるよう、`\` を `\\` に、`"` を `\"` にして `regexp` に書く
  （`"^\d{3}$"に一致` → `@Pattern(regexp = "^\\d{3}$")`）。
- **メッセージ（`message = "…"`）は、SPDに明示された場合だけ付ける。**
  `必須("表題を入力してください")` → `@NotBlank(message = "表題を入力してください")`。
  1つの検証から2つのアノテーションができる場合（`N以上M以下`）は、両方に同じメッセージを付ける。
- 1つのフィールドに複数の検証がある場合、アノテーションは**SPDに書かれた順**に並べる。
- **フォームに永続化アノテーション（`@Entity`・`@Column` など）を付けてはならない。**
- 検証アノテーションは `jakarta.validation.constraints.*` を使う（`javax.*` ではない）。

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

---

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
- パッケージは次を既定とする。SPDに指定があればそれに従う。

| 型 | パッケージ |
|---|---|
| コントローラー | `<基底パッケージ>.controller` |
| サービス | `<基底パッケージ>.service` |
| リポジトリ | `<基底パッケージ>.repository` |
| エンティティ | `<基底パッケージ>.entity` |
| フォーム | `<基底パッケージ>.form` |

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
  Thymeleafのコメント（`<!--/* … */-->`）として残す（`thymeleaf.instructions.md`）。

---

## 20.8 生成時のチェックリスト（Spring Boot 固有）

`spd-core` の `## 9.9` に加えて、次を確認する。

- [ ] 依存を**コンストラクタインジェクション**で注入したか。フィールドに `@Autowired` を付けていないか（`## 20.2`）
- [ ] コントローラーからリポジトリを直接呼び出していないか（`## 20.1`）
- [ ] サービスに `Model` や `HttpServletRequest` を持ち込んでいないか（`## 20.3`）
- [ ] `マッピング` を `メソッド` の子としてだけ扱ったか。パスが省略または `/` だけのとき、マッピングの引数を `{"", "/"}` とし、行末に理由の行コメントを付けたか（`## 20.2`）
- [ ] パスを明示した `マッピング` に、末尾に `/` を付けた別名（`{"/books", "/books/"}` など）を加えていないか（`## 20.2`）
- [ ] `フォーム` の変数名を型名の先頭を小文字にしたもの（`memberForm`）にし、`@ModelAttribute` を付けていないか。違う名前を勝手に言い換えていないか（`## 20.2`）
- [ ] `@Valid` を付けた引数の**直後**に `BindingResult` を置いたか。SPDに無い場合は補い、行コメントで明示したか（`## 20.2`）
- [ ] 「〜をテンプレートへ渡す」があるのに `Model model` が無い場合、補って行コメントで明示したか（`## 20.2`）
- [ ] 「〜をテンプレートへ渡す」の名前を**言い換えずに**そのまま `addAttribute` の第1引数にしたか（`## 11.2`）
- [ ] `処理` の「"…"を返す」の文字列を**そのまま** `return` したか。`.html` を付けていないか（`## 11.1`）
- [ ] `addFlashAttribute` を、リダイレクトと**組で**使ったか（`## 20.2`）
- [ ] `トランザクション` ノードが無いのに `@Transactional` を勝手に付けていないか（`## 20.3`）
- [ ] `@Transactional` を `org.springframework.transaction.annotation` から取ったか（`## 20.3`）
- [ ] サービスの `自動生成` は、書かれた項目だけを表どおりのシグネチャ・トランザクションで生成したか。リポジトリが `依存` にあることを確かめたか。`新規作成`・`更新` で、同名・同型でないフィールドを推測で詰め替えていないか（`## 20.3`）
- [ ] `詰め替え`・`フォームへ詰め替え` を、書かれていないのに暗黙に生成していないか。`copyFormToEntity` は `private void`・主キーを除いてコピー、`copyEntityToForm` は `public void`・主キーも含めてコピーとし、同じフォーム型の `詰め替え` があるとき `新規作成`・`更新` からそれを呼び出したか（`## 20.3`）
- [ ] リポジトリを `interface` として生成し、`@Repository` を付けていないか（`## 20.4`）
- [ ] 命名規約に合わないリポジトリメソッドに、推測で `@Query` を補っていないか（`## 20.4`）
- [ ] エンティティに `@主キー` があったか。引数なしコンストラクタを補い、行コメントで明示したか（`## 20.5`）
- [ ] `多対一`・`一対一` の関連に `fetch = FetchType.LAZY` を付けたか（`## 20.5`）
- [ ] `@値コレクション` のフィールドに `@ElementCollection` だけを付けたか。全角 `＠` のマーカーも読み落としていないか（`## 20.1`・`## 20.5`）
- [ ] 日付・時刻のフィールドに `@Temporal` を付けていないか。`Date`・`Calendar` が書かれていた場合、生成せずに報告したか（`## 20.5`）
- [ ] フォームに永続化アノテーションを付けていないか。検証を `jakarta.validation.constraints.*` から取ったか（`## 20.6`）
- [ ] 検証の対応表に無い表現を、推測でアノテーション化していないか（`## 20.6`）
- [ ] フォームの検証をフィールドの行末（`@` の右）から読んだか。正規表現・メッセージの引用符の中の `、`・`,` で区切っていないか。`検証` の枝が書かれていた場合、生成せずに報告したか（`## 20.6`）
- [ ] コレクションの `必須` を `@NotEmpty` にしたか。メッセージはSPDに明示された場合だけ付けたか（`## 20.6`）
- [ ] フォームの `java.time` のフィールドに、型に合った `@DateTimeFormat` を付けたか（`## 20.6`）
- [ ] `System.out` / `System.err` / `Input` クラスを使っていないか（`## 20.7`）
- [ ] `javax.*` ではなく `jakarta.*` を使ったか（`## 20.7`）
- [ ] 各Javaファイルの冒頭に、**その型のSPDだけ**をブロックコメントとして残したか（`## 20.7`）
- [ ] REST API の指定があった場合、生成せずに報告したか（`## 20.1`）

---

## 20.9 完全な変換例

### 与えられたSPD

```
エンティティ：Member
├─目的：会員を表すエンティティ
├─テーブル：members
├─フィールド
│  ├─番号：@主キー @自動採番 Long id
│  └─名前：@必須 @桁数(20) String name
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター

フォーム：MemberForm
├─目的：会員登録画面の入力項目
├─フィールド
│  └─名前：String name　＠必須、20文字以内
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター

リポジトリ：MemberRepository
├─目的：会員の永続化を行う
├─対象：Member
├─主キー：Long
└─検索メソッド：なし

サービス：MemberService
├─目的：会員に関する業務処理を行う
├─依存
│  └─会員リポジトリ：MemberRepository memberRepository
├─メソッド：findAll
│  ├─目的：全会員を取得する
│  ├─トランザクション：参照のみ
│  ├─引数：なし
│  ├─戻り値：List<Member>、全会員のリスト
│  └─処理
│        └─memberRepositoryのfindAllの結果を返す
└─メソッド：create
     ├─目的：会員を登録する
     ├─トランザクション：更新あり
     ├─引数
     │    └─入力フォーム：MemberForm form
     ├─戻り値：なし
     └─処理
           ├─Memberのインスタンスを作って変数memberに代入する
           ├─formのnameをmemberのnameに設定する
           └─memberRepositoryのsaveをmemberを引数にして呼び出す

コントローラー：MemberController
├─目的：会員の一覧・登録を扱う
├─基底パス：/members
├─依存
│  └─会員サービス：MemberService memberService
├─メソッド：list
│  ├─目的：会員の一覧を表示する
│  ├─マッピング：GET
│  ├─引数
│  │    └─モデル：Model model
│  ├─戻り値：String、表示するテンプレート名
│  └─処理
│        ├─memberServiceのfindAllを呼び出した結果をmembersとしてテンプレートへ渡す
│        └─"member/list"を返す
└─メソッド：create
     ├─目的：入力された会員を登録する
     ├─マッピング：POST
     ├─引数
     │    ├─フォーム：@検証 MemberForm memberForm
     │    ├─検証結果：BindingResult result
     │    └─メッセージ：RedirectAttributes redirect
     ├─戻り値：String、表示するテンプレート名またはリダイレクト先
     └─処理
           ├─◇─resultにエラーがある
           │  └─"member/form"を返す
           ├─memberServiceのcreateをmemberFormを引数にして呼び出す
           ├─"登録しました"をフラッシュメッセージmessageとして渡す
           └─/membersへリダイレクトする
```

### 生成されるコード

**Member.java**

```java
package com.example.app.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/*
エンティティ：Member
├─目的：会員を表すエンティティ
├─テーブル：members
├─フィールド
│  ├─番号：@主キー @自動採番 Long id
│  └─名前：@必須 @桁数(20) String name
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター
*/

// 会員を表すエンティティ
@Entity
@Table(name = "members")
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // 番号

    @Column(nullable = false, length = 20)
    private String name; // 名前

    // 自動生成：コンストラクタ：引数なし
    public Member() {
    }

    // 自動生成：ゲッター
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    // 自動生成：セッター
    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

**MemberService.java**

```java
package com.example.app.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.app.entity.Member;
import com.example.app.form.MemberForm;
import com.example.app.repository.MemberRepository;

/*
サービス：MemberService
├─目的：会員に関する業務処理を行う
├─依存
│  └─会員リポジトリ：MemberRepository memberRepository
├─メソッド：findAll
│  ├─目的：全会員を取得する
│  ├─トランザクション：参照のみ
│  ├─引数：なし
│  ├─戻り値：List<Member>、全会員のリスト
│  └─処理
│        └─memberRepositoryのfindAllの結果を返す
└─メソッド：create
     ├─目的：会員を登録する
     ├─トランザクション：更新あり
     ├─引数
     │    └─入力フォーム：MemberForm form
     ├─戻り値：なし
     └─処理
           ├─Memberのインスタンスを作って変数memberに代入する
           ├─formのnameをmemberのnameに設定する
           └─memberRepositoryのsaveをmemberを引数にして呼び出す
*/

// 会員に関する業務処理を行う
@Service
public class MemberService {

    private final MemberRepository memberRepository; // 会員リポジトリ

    public MemberService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    /**
     * 全会員を取得する
     *
     * @return 全会員のリスト
     */
    @Transactional(readOnly = true)
    public List<Member> findAll() {
        return memberRepository.findAll();
    }

    /**
     * 会員を登録する
     *
     * @param form 入力フォーム
     */
    @Transactional
    public void create(MemberForm form) {
        var member = new Member();
        member.setName(form.getName());
        memberRepository.save(member);
    }
}
```

**MemberController.java**

```java
package com.example.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.app.form.MemberForm;
import com.example.app.service.MemberService;

import jakarta.validation.Valid;

/*
コントローラー：MemberController
├─目的：会員の一覧・登録を扱う
├─基底パス：/members
├─依存
│  └─会員サービス：MemberService memberService
├─メソッド：list
│  ├─目的：会員の一覧を表示する
│  ├─マッピング：GET
│  ├─引数
│  │    └─モデル：Model model
│  ├─戻り値：String、表示するテンプレート名
│  └─処理
│        ├─memberServiceのfindAllを呼び出した結果をmembersとしてテンプレートへ渡す
│        └─"member/list"を返す
└─メソッド：create
     ├─目的：入力された会員を登録する
     ├─マッピング：POST
     ├─引数
     │    ├─フォーム：@検証 MemberForm memberForm
     │    ├─検証結果：BindingResult result
     │    └─メッセージ：RedirectAttributes redirect
     ├─戻り値：String、表示するテンプレート名またはリダイレクト先
     └─処理
           ├─◇─resultにエラーがある
           │  └─"member/form"を返す
           ├─memberServiceのcreateをmemberFormを引数にして呼び出す
           ├─"登録しました"をフラッシュメッセージmessageとして渡す
           └─/membersへリダイレクトする
*/

// 会員の一覧・登録を扱う
@Controller
@RequestMapping("/members")
public class MemberController {

    private final MemberService memberService; // 会員サービス

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    /**
     * 会員の一覧を表示する
     *
     * @param model モデル
     * @return 表示するテンプレート名
     */
    @GetMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため
    public String list(Model model) {
        model.addAttribute("members", memberService.findAll());
        return "member/list";
    }

    /**
     * 入力された会員を登録する
     *
     * @param memberForm フォーム
     * @param result 検証結果
     * @param redirect メッセージ
     * @return 表示するテンプレート名またはリダイレクト先
     */
    @PostMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため
    public String create(@Valid MemberForm memberForm,
                         BindingResult result,
                         RedirectAttributes redirect) {
        if (result.hasErrors()) {
            return "member/form";
        }
        memberService.create(memberForm);
        redirect.addFlashAttribute("message", "登録しました");
        return "redirect:/members";
    }
}
```

**MemberRepository.java**（SPDは同様に冒頭へ残す。以下は本体のみ）

```java
public interface MemberRepository extends JpaRepository<Member, Long> {
}
```

**MemberForm.java**（同上）

```java
// 会員登録画面の入力項目
public class MemberForm {

    @NotBlank
    @Size(max = 20)
    private String name; // 名前

    // 自動生成：コンストラクタ：引数なし
    public MemberForm() {
    }

    // 自動生成：ゲッター／セッター
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

---

## 更新履歴

| バージョン | 更新日 | 変更内容 |
|---|---|---|
| 1.0.0 | 2026-09-19 | 初版。SPDの型定義タイトルに `コントローラ:`／`サービス:`／`リポジトリ:`／`エンティティ:`／`フォーム:` を新設し、それぞれの記法と生成規則を規定（`## 20.2`〜`## 20.6`）。`処理メソッド:`・`割付`・`引数`（パス変数／パラメータ／フォーム／検証結果／メッセージ）・`受渡し`・`画面` のノードを定義。層の責務と依存方向、未記入判定の適用範囲を明記（`## 20.1`）。SE版 `## 9.7` の環境依存部を Spring Boot 向けに置き換え（`## 20.7`。`System.out`／`Input` を禁止しロガーへ、インポート表を Spring／JPA／Bean Validation に差し替え、`jakarta.*` を明示）。Spring Boot 固有のチェックリスト21項目（`## 20.8`）と完全な変換例（`## 20.9`）を追加 |
| 1.1.0 | 2026-09-26 | `処理メソッド:` の `画面` ノードを `テンプレート` に改称（`thymeleaf.instructions.md` のタイトル `テンプレート:` と同じ語にそろえるため。`## 20.2`・`## 20.8`・`## 20.9`）。`処理` の中の `<名前>をテンプレートへ渡す` は、従来の `<名前>を画面へ渡す` と書いてもよいことを明記（`## 20.2`） |
| 1.2.0 | 2026-09-26 | コントローラーのメソッドを一般の `メソッド:`（`spd-core` の `## 9.6.6`）と同じ形に統一。`処理メソッド:` を廃止し、`メソッド:` の子に `マッピング` を置いたものをハンドラーメソッドとする。`割付` を `マッピング` に改称し、パスを省略した場合は基底パスに割り当てる規則を追加。`受渡し`・`テンプレート` ノードを廃止し、`処理` の「〜をテンプレートへ渡す」「"…"を返す」と `戻り値` で表す形に変更。`<式>を<名前>としてテンプレートへ渡す` の書き方を追加。`Model model` は原則として `引数` に書き、無い場合は「テンプレートへ渡す」から補う規則に変更。`マッピング` の有無にかかわらず通常のメソッドとして未完成判定を行うことを明記（`## 20.1`）。型定義タイトルを `コントローラー:` に改め、`コントローラ:` も受け付ける。地の文の「コントローラ」も「コントローラー」に統一（`## 20.1`・`## 20.2`・`## 20.7`〜`## 20.9`） |
| 1.3.0 | 2026-09-26 | `マッピング` のパスを省略した場合、または `/` だけの場合は、HTTPメソッドにかかわらず `@GetMapping({"", "/"})` などを生成し、行末に `// 末尾の / の有無どちらでも受け付けるため` を付ける規則に変更（Spring Boot 3 以降は末尾の `/` を区別するため。`## 20.2`）。チェックリスト（`## 20.8`）と生成例（`## 20.2`・`## 20.9`）に反映 |
| 1.4.0 | 2026-09-26 | パスを明示した `マッピング` には末尾に `/` を付けた別名を加えず、そのパスだけを書く規則を追加（`{"", "/"}` はパス省略時と `/` だけの場合に限る。`## 20.2`）。チェックリストに対応する項目を追加し22項目に（`## 20.8`）。Javaコードのインデントを半角スペース4つとし、アノテーションを宣言と同じ深さに置く規則を追加（`## 20.7`） |
| 1.5.0 | 2026-09-26 | コントローラーの `フォーム` 引数の変数名を、型名の先頭を小文字にしたもの（`memberForm`）に統一し、`@ModelAttribute` を付けずに生成する規則に変更（`## 20.2`）。従来の `@ModelAttribute MemberForm form` では Model の属性名が型名由来の `memberForm` になり、テンプレートの `${form}` と一致しない不具合があったため。別の変数名が書かれた場合は生成せず報告する。生成例（`## 20.2`・`## 20.9`）を修正し、`ModelAttribute` のインポートを削除。チェックリストに1項目追加し23項目に（`## 20.8`） |
| 1.6.0 | 2026-09-27 | マーカーの `@` は半角・全角（`＠`）のどちらで書いてもよく、生成するアノテーションは必ず半角とする規約を追加（`## 20.1`）。要素が文字列・ラッパークラス・埋め込み型のコレクションを表すフィールドのマーカー `@値コレクション`（→ `@ElementCollection`）を追加し、テーブル名・列名は既定に任せ、他のマーカーとは組み合わせない規則を追加（`## 20.5`）。日付・時刻のフィールドは `java.time` の型でアノテーションを付けずに書き、`Date`・`Calendar` は生成せず報告する規則を追加（`@Temporal` は `java.time` の型には不要で、Hibernate 6 では付けるとエラーになるため。`## 20.5`）。チェックリストに2項目追加し25項目に（`## 20.8`）。`インジェクション` を `依存` の別名として受理する規則を追加（`## 20.1`・`## 20.2`）。サービスの `自動生成：<リポジトリ型名>` を新設し、`全件検索`・`主キーで検索`・`新規作成 ← フォーム`・`更新 ← フォーム`・`削除`・`総件数`・`ページング` から、リポジトリを呼び出すだけのメソッドを決まったシグネチャとトランザクションで生成する規則を追加（`新規作成`・`更新` は同名・同型のフィールドだけを詰め替え、対応しないフィールドがあれば生成せず報告。`## 20.3`）。サービスの骨格の枝に `自動生成` を追加（`## 20.1`）。インポート表に `Page`・`Pageable` を追加（`## 20.7`）。チェックリストに1項目追加し26項目に（`## 20.8`） |
| 1.7.0 | 2026-09-28 | サービスの `自動生成` に `詰め替え ← フォーム`（→ `private void copyFormToEntity(F f, E e)`）と `フォームへ詰め替え → フォーム`（→ `public void copyEntityToForm(E e, F f)`）を追加（`## 20.3`）。どちらも同名・同型のフィールドだけをコピーし、`copyFormToEntity` は主キーを除き、`copyEntityToForm` は主キーも含める。書かれた場合だけ生成し、`新規作成`・`更新` から暗黙には生成しない。同じフォーム型の `詰め替え` があれば、`新規作成`・`更新` はコピーを直接書かずにそれを呼び出す。フォーム型が違えば複数書け、オーバーロードとして生成する（そのため、どちらもコピー先を引数で受け取る `void` の形にそろえた）。チェックリストに1項目追加し27項目に（`## 20.8`） |
| 1.8.0 | 2026-09-28 | フォームの検証を、`検証` の枝ではなく各フィールドの行末に `@`（`＠`）に続けて `、`・`,` 区切りで書く記法に変更し、`検証` の枝を廃止（書かれていた場合は生成せず報告。`## 20.1`・`## 20.6`）。エンティティのマーカーは前置、フォームの検証は後置であることを明記。正規表現は `"` で囲み、メッセージは検証の直後の `()` に `"` で囲んで書く規則を追加。`@` や区切りの前後の空白（全角を含む）は無視する。コレクションの `必須` を `@NotEmpty` に対応させた（空のコレクションがバインドされ、`@NotNull` では働かないため）。フォームの `java.time` のフィールドに、型に応じた `@DateTimeFormat(iso = …)` を必ず付ける規則を追加し、インポート表に `DateTimeFormat` を追加（`## 20.7`）。完全な変換例（`## 20.9`）のフォームを新しい記法に書き換え。チェックリストに3項目追加し30項目に（`## 20.8`） |
