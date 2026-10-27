## 20.2 コントローラー

### 記法

コントローラーのメソッドは、**一般の `メソッド:`（`spd-core` の `## 9.6.6`）と同じ形**で書く。
`目的`・`引数`・`戻り値`・`処理` を持ち、そこに `マッピング` を加えたものがハンドラーメソッドになる。
Javaで、マッピングのアノテーションが付いたメソッドがハンドラーになるのと同じである。

```
コントローラー：MemberController
│
├─目的：会員の一覧・登録・削除を扱う
├─ベースパス：/members
│
├─インジェクション
│  └─会員サービス：MemberService memberService
│
├─メソッド：list
│  ├─目的：会員の一覧を表示する
│  ├─マッピング：GET
│  ├─引数
│  │    └─モデル：Model model
│  ├─戻り値：String、表示するテンプレート名
│  └─処理
│        ├─memberServiceを使って、全件を読み出した結果をmemberListとしてテンプレートに渡す
│        └─"member/list"を返す
│
├─メソッド：newForm
│  ├─目的：新規登録画面を表示する
│  ├─マッピング：GET /new
│  ├─引数：なし
│  ├─戻り値：String、表示するテンプレート名
│  └─処理
│        ├─空のMemberFormを作ってテンプレートに渡す
│        └─"member/form"を返す
│
├─メソッド：create
│  ├─目的：入力された会員を登録する
│  ├─マッピング：POST
│  ├─引数
│  │    └─入力内容：@検証 MemberForm memberForm
│  ├─戻り値：String、表示するテンプレート名またはリダイレクト先
│  └─処理
│        ├─◇─resultにエラーがある
│        │  └─"member/form"を返す
│        ├─memberServiceを使って、memberFormから会員を登録する
│        ├─"登録しました"をフラッシュメッセージとして渡す
│        └─ベースパスにリダイレクトする
│
└─メソッド：delete
     ├─目的：会員を削除する
     ├─マッピング：POST /{id}/delete
     ├─引数
     │    └─会員番号：@パス変数 Long id
     ├─戻り値：String、リダイレクト先
     └─処理
           ├─memberServiceを使って、idで会員を削除する
           └─ベースパスにリダイレクトする
```

### ノードの意味と生成規則

| ノード | 生成されるもの |
|---|---|
| タイトル `コントローラー：X` | `@Controller` を付けた `public class X` |
| `目的：…` | クラス宣言の直上の行コメント（`// …`） |
| `ベースパス：/members` | クラスに `@RequestMapping("/members")` |
| `インジェクション` | `private final` フィールド＋**コンストラクタインジェクション** |
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

`マッピング：<HTTPメソッド> [<パス>]` と書く。パスは `ベースパス` からの相対である。

| SPDの記述 | 生成 |
|---|---|
| `マッピング：GET` | `@GetMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため` |
| `マッピング：GET /` | `@GetMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため` |
| `マッピング：GET /{id}/edit` | `@GetMapping("/{id}/edit")` |
| `マッピング：POST` | `@PostMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため` |
| `マッピング：POST /{id}/delete` | `@PostMapping("/{id}/delete")` |

- **パスを省略した場合、または `/` だけの場合は、`ベースパス` そのものに割り当てる。**
  HTTPメソッドにかかわらず、マッピングの引数を `{"", "/"}` とし、同じ行の末尾に
  行コメント `// 末尾の / の有無どちらでも受け付けるため` を付ける。
  Spring Boot 3 以降は末尾の `/` を区別するため、`@GetMapping` だけでは
  `/members/` へのアクセスが 404 になる。
- `ベースパス` が無いコントローラーでも同じに生成する。
- **パスを明示した場合は、そのパスだけを書く。** 末尾に `/` を付けた別名を加えてはならない
  （`マッピング：GET /books` → `@GetMapping("/books")`。`{"/books", "/books/"}` としない）。
  `{"", "/"}` にするのは、パスを省略した場合と `/` だけの場合に限る。
- **`マッピング` のパスが `ベースパス` と同じ文字列で始まる場合**（`ベースパス：/date` に対して
  `マッピング：GET /date`・`マッピング：GET /date/new` など。`/dates` のように区切りの `/` が続かないものは当たらない）は、
  URL がベースパスを2回重ねたもの（`/date/date`）になる。パスはベースパスからの相対であることを書き忘れた誤りであることが多い。
  **SPDのとおりに生成し**（`@GetMapping("/date")`。パスを推測で直さない）、`## 0.8` の報告の【確認事項】に次の形で載せること。

  ```text
  - entry の `マッピング：GET /date` は、ベースパス `/date` からの相対なので、URL は `/date/date` になります。
    `/date` にする場合は、マッピングのパスを省いて `マッピング：GET` と書きます。
  ```

  マッピングのパスがベースパスと同じでなく、続きがある場合（`/date/new`）は、2行目を
  「`/date/new` にする場合は、`マッピング：GET /new` と書きます。」とする。

**`引数` の書式**

`<説明>：[<マーカー>] <型> <変数名>` の形で書く。`spd-core` の `引数`（`<説明>：<型> <変数名>`）に、
値の受け取り方を表すマーカーを加えたものである。**説明は自由に書いてよく、生成には影響しない**
（Javadoc の `@param` の説明になる）。マーカーの `@` は全角 `＠` でもよい（`## 20.1`）。

| SPDの記述 | 生成される引数 |
|---|---|
| `入力内容：@検証 MemberForm memberForm` | `@Valid MemberForm memberForm` |
| `入力内容：MemberForm memberForm` | `MemberForm memberForm` |
| `会員番号：@パス変数 Long id` | `@PathVariable Long id` |
| `キーワード：@パラメータ String keyword` | `@RequestParam String keyword` |
| `キーワード：@パラメータ String keyword = ""` | `@RequestParam(defaultValue = "") String keyword` |
| `モデル：Model model` | `Model model` |
| `検証結果：BindingResult result` | `BindingResult result` |
| `転送属性：RedirectAttributes redirectAttrs` | `RedirectAttributes redirectAttrs` |
| `引数：なし` | 引数なし（下の「補う引数」は補う） |

- `Model`・`BindingResult`・`RedirectAttributes` は**型で判別する。** マーカーは付けない。
- **ハンドラーメソッドで、マーカーの無い単純な型**（`String`・数値型とそのラッパークラス・`LocalDate` など）の引数は、
  値をパスから受け取るのかパラメータから受け取るのか決められないため、そのメソッドを生成せず、
  `## 0.8` の報告の【確認事項】に載せること。
  説明が `パス変数`・`パラメータ` でマーカーが無いもの（`パス変数：Long id`）も、これに当たる（`## 20.1` の「規約に無い書き方」）。
- **フォーム（クラス型）の変数名は、型名の先頭の1文字を小文字にしたものとする**（`MemberForm` → `memberForm`）。
  **`@ModelAttribute` は付けない。** Spring では、クラス型の引数は `@ModelAttribute` が付いているものとして
  扱われ、Model の属性名は型名の先頭を小文字にしたものになる。この規則により、変数名・Model の属性名・
  テンプレートの `受け取り` の名前がすべて一致する（`## 11.3`）。
- SPDに別の変数名（`入力内容：MemberForm form` など）が書かれていた場合は、**名前を勝手に変えず**、
  そのメソッドを生成せずに `## 0.8` の報告の【確認事項】に載せること。

**補う引数**

次の引数は、`引数` に書かれていなくても補う。**変数名は固定**であり、`処理` の中ではこの名前で参照する
（`resultにエラーがある` など）。

| 補う引数 | 補う条件 | 置く位置 |
|---|---|---|
| `BindingResult result` | `@検証` の引数があり、その直後に `BindingResult` が書かれていない | `@Valid` を付けた引数の**直後** |
| `Model model` | `処理` に「〜をテンプレートに渡す」がある | 引数の末尾 |
| `RedirectAttributes redirectAttrs` | `処理` に「〜をフラッシュメッセージ…として渡す」がある | 引数の末尾（`Model` の後） |

- **`引数` に書かれていれば、書かれた変数名を使う**（補わない）。`引数：なし` と書かれていても補う。
- `@Valid` を付けた引数の直後には、必ず `BindingResult` を置く（Spring の要件）。
  書かれた `BindingResult` が直後に無い場合は、直後へ移す。
- `RedirectAttributes` は、`処理` にフラッシュメッセージが無ければ補わない。
- **補った引数ごとに、メソッドのアノテーションの直前（Javadoc の後）に行コメントを1行付ける**
  （`// SPDに無いため BindingResult result を補った`）。Javadoc の `@param` にも載せ、説明は
  `result` が「検証結果」、`model` が「モデル」、`redirectAttrs` が「リダイレクト先へ渡す属性」とする。

**`処理` の中の Web 固有の表現**

| SPDの記述 | 生成 |
|---|---|
| `"member/form"を返す` | `return "member/form";` |
| `/membersへリダイレクトする` | `return "redirect:/members";` |
| `/members/{id}へリダイレクトする` | `return "redirect:/members/" + id;` |
| `ベースパスにリダイレクトする` | `return "redirect:/members";`（`ベースパス` の値） |
| `ベースパス（"/members"）にリダイレクトする` | 同上 |
| `"…"をフラッシュメッセージとして渡す` | `redirectAttrs.addFlashAttribute("message", "…");` |
| `"…"をフラッシュメッセージ<名前>として渡す` | `redirectAttrs.addFlashAttribute("<名前>", "…");` |
| `<名前>をテンプレートに渡す` | `model.addAttribute("<名前>", <名前>);` |
| `<式>を<名前>としてテンプレートに渡す` | `model.addAttribute("<名前>", <式>);` |
| `<式>を"<名前>"という名前でテンプレートに渡す` | `model.addAttribute("<名前>", <式>);` |
| `空の<フォーム型>を作ってテンプレートに渡す` | `model.addAttribute("<型名の先頭を小文字>", new <フォーム型>());` |
| `<変数>を<フォーム型>型の変数<名前>に詰め替える` | `var <名前> = new <フォーム型>();` ＋ `<サービス>.copyEntityToForm(<変数>, <名前>);` |

- 「テンプレートに渡す」は「テンプレートへ渡す」「画面に渡す」「画面へ渡す」と書いてもよい。同じに扱う。
- 「テンプレートに渡す」の `<名前>` が、テンプレート側の `受け取り` と照合する属性名である（`## 11.2`）。
- **フラッシュメッセージの名前を省略した場合は `message` とする。** テンプレート側は `message` で受け取る。
- **フラッシュメッセージはリダイレクトと組で使う。** リダイレクトを伴わない
  `addFlashAttribute` を生成してはならない。
- **`ベースパスにリダイレクトする`** は、`ベースパス` の値へのリダイレクトにする。
  `ベースパス` が無いコントローラーで使われた場合、または括弧の中の値が `ベースパス` と違う場合は、
  そのメソッドを生成せず、`## 0.8` の報告の【確認事項】に載せること。
- **`空の<フォーム型>を作ってテンプレートに渡す`** の属性名は、フォームの変数名と同じ規則
  （型名の先頭を小文字）で決める（`## 11.3`）。
- **`詰め替える`** は、`インジェクション` にあるサービスのうち、`自動生成` に `フォームに詰め替え → <フォーム型>`
  （`## 20.3`）を持つものの `copyEntityToForm` を呼び出す。該当するサービスが無い、または2つ以上ある場合は、
  そのメソッドを生成せず【確認事項】に載せること。**コントローラーでフィールドを1つずつコピーするコードを生成してはならない。**
- `"…"を返す` の文字列は、テンプレート名としてそのまま使う。**`/` で始まっていた場合は生成せず**、
  【確認事項】に載せること（`## 11.1`）。

**サービスの呼び出し（メソッド名の省略）**

`処理` の中でサービスを呼び出すときは、**文脈から推測できる場合はメソッド名を書かず**、何をするかを書く。

```
├─memberServiceを使って、全件を読み出した結果をmemberListとしてテンプレートに渡す
├─memberServiceを使って、memberFormから会員を登録する
└─memberServiceを使って、idで会員を削除する
```
```java
model.addAttribute("memberList", memberService.findAll());
memberService.create(memberForm);
memberService.deleteById(id);
```

- **呼び出すメソッドは、そのサービスのSPD（または生成済みのサービス）に実在するものから選ぶ。**
  候補は、`自動生成` の項目（`全件検索` → `findAll()`、`削除` → `deleteById` など。`## 20.3`）と、
  `メソッド：` の `目的`、`検索メソッド` の移譲元の説明である。書かれた動作と意味が合うものを1つ選ぶ。
- 引数は、`処理` に書かれた変数（`memberFormから`・`idで`）を、選んだメソッドの引数の型と照らして渡す。
- **候補が無い、または2つ以上あって決められない場合は、推測でメソッドを作らず**、そのメソッドを生成せずに
  `## 0.8` の報告の【確認事項】に載せること。サービスにメソッドを勝手に追加してはならない。
- メソッド名を書いた場合（`memberServiceのfindAllを呼び出す`）は、それに従う。書かれた名前がサービスに無い場合は
  【見つからない名前】に載せること。

**リストの名前**

- **結果がリスト（`List`）になる値の名前は、`～s`（複数形）ではなく `～List` とする**（`memberList`・`bookList`）。
  これはSPDを書く側の規則である。テンプレートの `受け取り` も同じ名前で書く（`## 11.2`）。
- 生成時には、SPDに書かれた名前を**そのまま使い、書き換えない**（`members` と書かれていても `memberList` に直さない。`## 11.2`）。

### 生成例

上の `create` から生成されるコード：

```java
/**
 * 入力された会員を登録する
 *
 * @param memberForm 入力内容
 * @param result 検証結果
 * @param redirectAttrs リダイレクト先へ渡す属性
 * @return 表示するテンプレート名またはリダイレクト先
 */
// SPDに無いため BindingResult result を補った
// SPDに無いため RedirectAttributes redirectAttrs を補った
@PostMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため
public String create(@Valid MemberForm memberForm,
                     BindingResult result,
                     RedirectAttributes redirectAttrs) {
    if (result.hasErrors()) {
        return "member/form";
    }
    memberService.create(memberForm);
    redirectAttrs.addFlashAttribute("message", "登録しました");
    return "redirect:/members";
}
```

`newForm` と `delete`：

```java
/**
 * 新規登録画面を表示する
 *
 * @param model モデル
 * @return 表示するテンプレート名
 */
// SPDに無いため Model model を補った
@GetMapping("/new")
public String newForm(Model model) {
    model.addAttribute("memberForm", new MemberForm());
    return "member/form";
}

/**
 * 会員を削除する
 *
 * @param id 会員番号
 * @return リダイレクト先
 */
@PostMapping("/{id}/delete")
public String delete(@PathVariable Long id) {
    memberService.deleteById(id);
    return "redirect:/members";
}
```

### インジェクション

```
├─インジェクション
│  └─会員サービス：MemberService memberService
```
```java
private final MemberService memberService; // 会員サービス

public MemberController(MemberService memberService) {
    this.memberService = memberService;
}
```

- **フィールドへの `@Autowired` を生成してはならない。** 必ずコンストラクタインジェクションにする。
- インジェクションが1つでもある場合、コンストラクタは**必ず明示的に生成する**（`@RequiredArgsConstructor` などの
  Lombok は使わない。学習者が生成物を読めることを優先する）。
- コントローラー・サービスのどちらでも使える。`インジェクション：なし` は記入済みとして扱う。

