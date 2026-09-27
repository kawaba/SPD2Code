---
applyTo: "**/src/main/resources/templates/**/*.html, **/*.java"
description: SPDのテンプレート定義（`テンプレート:`）からThymeleafテンプレートを生成する規約。構成ノードとth属性の対応表、フォーム・繰り返し・条件表示・レイアウト。
---

<!-- ===== THYMELEAF v1.3.0 / 2026-09-26 =====
     このファイルは Spring Boot 版ワークスペース固有である。
     `.java` 編集時にも読み込まれるのは、コントローラーが渡す属性名とテンプレートが
     参照する名前を一致させる必要があるためである（copilot-instructions.md `## 11`）。 -->

# SPD（テンプレート定義）→ Thymeleafテンプレート生成規約

## 30.1 適用範囲とファイル配置

- **タイトルが `テンプレート：…` のSPDだけ**がこのファイルの対象である。
- 生成先は `src/main/resources/templates/<テンプレート名>.html` とする。
  テンプレート名はSPDのタイトルに書かれた文字列をそのまま使い、`.html` は付けない（`## 11.1`）。

```
テンプレート：member/list
→ src/main/resources/templates/member/list.html
```

- Web層のJavaコードの規約は `springboot-java.instructions.md` にある。
  **コントローラーとテンプレートを同時に生成する場合は、両方の規約を適用すること。**

### 未記入判定の適用

`## 0.3`（SPDの未記入部分は生成しない）を適用する。

| 判定単位 | 骨格の枝（条件Bを見る範囲） |
|---|---|
| `テンプレート: 名前` | `構成` |

- `構成` の枝が無い、または中身が空／`★` マーカーを含む場合、そのテンプレートは**未完成**である。
  テンプレートファイルを生成せず、`## 0.8` の報告に載せること。
- `受取り：なし`・`レイアウト：なし` は、記入済みとして扱う。

---

## 30.2 テンプレートSPDの記法

```
テンプレート：member/list
│
├─目的：会員の一覧を表示する
├─レイアウト：layout/base
├─タイトル：会員一覧
│
├─受取り
│  ├─members：List<Member>
│  └─message：String　※任意
│
└─構成
     ├─見出し：会員一覧
     ├─条件表示：messageがある
     │  └─通知：message
     ├─表：membersの各要素をmとする
     │  ├─列：番号 ← m.id
     │  ├─列：名前 ← m.name
     │  └─列：操作
     │        └─リンク：編集 → /members/{m.id}/edit
     └─リンク：新規登録 → /members/new
```

| ノード | 意味 |
|---|---|
| タイトル `テンプレート：…` | テンプレートのパス（`templates/` 配下・拡張子なし） |
| `目的：…` | ファイル冒頭のコメントに記載 |
| `レイアウト：…` | 使用する共通レイアウト。`なし` なら単独のHTMLとして生成（`## 30.6`） |
| `タイトル：…` | `<title>` の内容 |
| `受取り` | コントローラーから渡される Model 属性と、その型 |
| `構成` | 画面の中身（`## 30.3`） |

- **`レイアウト` の行が無い場合は、`レイアウト：なし` として扱う。**
  ワークスペースにレイアウトファイルがあっても、推測で適用してはならない。

- **`受取り` に書かれた名前は、対応するコントローラーの `処理` で「〜をテンプレートへ渡す」とした名前と一致していなければならない**（`## 11.2`）。
  一致しない名前をテンプレートで参照しようとした場合は、推測で補わず
  `## 0.8` の報告の【見つからない名前】に載せること。
- `※任意` と書かれた受取りは、`th:if` で存在を確認してから使う。

---

## 30.3 構成ノードの対応表

### 基本の原則

- **静的な文字列は、HTMLの本文にそのまま書く。** `th:text` を付けない。
- **`←` が書かれた項目だけが動的**である。`th:text="${…}"` で出力する。
- `th:text` を使うときは、**プレビュー用のダミー文字列を本文にも残す**
  （`<td th:text="${m.name}">名前</td>`）。ブラウザで直接開いたときに崩れないためである。

### 対応表

| SPDの記述 | 生成されるHTML |
|---|---|
| `見出し：会員一覧` | `<h1>会員一覧</h1>` |
| `小見出し：基本情報` | `<h2>基本情報</h2>` |
| `段落：…` | `<p>…</p>` |
| `文字：名前 ← m.name` | `<span th:text="${m.name}">名前</span>` |
| `通知：message` | `<div class="message" th:text="${message}">通知</div>` |
| `リンク：新規登録 → /members/new` | `<a th:href="@{/members/new}">新規登録</a>` |
| `ボタン：登録する` | `<button type="submit">登録する</button>` |
| `区切り` | `<hr>` |

- **`見出し` の階層**は、`構成` 直下を `<h1>`、その1段下を `<h2>` とする。
- `← 値` が付いた見出し・段落は、`th:text` で出力する
  （`見出し：会員一覧 ← title` → `<h1 th:text="${title}">会員一覧</h1>`）。

### パスの書き方

**パスは必ず `@{…}` で囲む**（`## 11.4`）。素の `href="/members"` を生成してはならない。

| SPDの記述 | 生成 |
|---|---|
| `→ /members/new` | `th:href="@{/members/new}"` |
| `→ /members/{m.id}/edit` | `th:href="@{/members/{id}/edit(id=${m.id})}"` |
| `→ /members?keyword={keyword}` | `th:href="@{/members(keyword=${keyword})}"` |

- **パス変数は `{名前}` のプレースホルダと `(名前=${式})` の組で書く。**
  文字列連結（`@{'/members/' + ${m.id}}`）は生成しない。

---

## 30.4 繰り返しと条件表示

### 表

```
├─表：membersの各要素をmとする
│  ├─列：番号 ← m.id
│  ├─列：名前 ← m.name
│  └─列：操作
│        └─リンク：編集 → /members/{m.id}/edit
```

```html
<table>
  <thead>
    <tr>
      <th>番号</th>
      <th>名前</th>
      <th>操作</th>
    </tr>
  </thead>
  <tbody>
    <tr th:each="m : ${members}">
      <td th:text="${m.id}">1</td>
      <td th:text="${m.name}">名前</td>
      <td>
        <a th:href="@{/members/{id}/edit(id=${m.id})}">編集</a>
      </td>
    </tr>
  </tbody>
</table>
```

- `列：<見出し> ← <値>` の形である。見出しは `<thead>` へ、値は `<tbody>` の `<td>` へ振り分ける。
- `←` の無い `列` は、子ノードの内容を `<td>` の中に置く。
- **`th:each` は `<tr>` に付ける。** `<tbody>` や `<table>` に付けてはならない。

### 一覧

```
├─一覧：membersの各要素をmとする
│  └─項目：m.name
```
```html
<ul>
  <li th:each="m : ${members}" th:text="${m.name}">名前</li>
</ul>
```

### 条件表示

| SPDの記述 | 生成 |
|---|---|
| `条件表示：messageがある` | `th:if="${message}"` |
| `条件表示：membersが空である` | `th:if="${#lists.isEmpty(members)}"` |
| `条件表示：membersが空でない` | `th:if="${not #lists.isEmpty(members)}"` |
| `条件表示：m.ageが20以上` | `th:if="${m.age >= 20}"` |
| `そうでなければ` | 直前の条件の `th:unless`（同じ条件式） |

- 条件表示が**単独のタグを持たない**場合（複数の要素をまとめて出し分ける場合）は、
  `<th:block th:if="…">` を使う。余計な `<div>` を作らない。

---

## 30.5 フォーム

### 記法

```
テンプレート：member/form
│
├─目的：会員を登録する
├─レイアウト：layout/base
├─タイトル：会員登録
│
├─受取り
│  └─memberForm：MemberForm
│
└─構成
     ├─見出し：会員登録
     └─フォーム：memberForm → POST /members
          ├─入力欄：名前 ← name
          ├─エラー：name
          ├─入力欄：年齢 ← age　※数値
          ├─エラー：age
          └─ボタン：登録する
```

### 生成

```html
<form th:object="${memberForm}" th:action="@{/members}" method="post">
  <div>
    <label for="name">名前</label>
    <input type="text" id="name" th:field="*{name}">
    <span th:if="${#fields.hasErrors('name')}" th:errors="*{name}">エラー</span>
  </div>
  <div>
    <label for="age">年齢</label>
    <input type="number" id="age" th:field="*{age}">
    <span th:if="${#fields.hasErrors('age')}" th:errors="*{age}">エラー</span>
  </div>
  <button type="submit">登録する</button>
</form>
```

### 規則

| SPDの記述 | 生成 |
|---|---|
| `フォーム：memberForm → POST /members` | `<form th:object="${memberForm}" th:action="@{/members}" method="post">` |
| `入力欄：名前 ← name` | `<label>` + `<input type="text" th:field="*{name}">` |
| `入力欄：年齢 ← age　※数値` | `type="number"` |
| `入力欄：入会日 ← joinedOn　※日付` | `type="date"` |
| `入力欄：メール ← email　※メール` | `type="email"` |
| `入力欄：パスワード ← password　※パスワード` | `type="password"` |
| `複数行入力：備考 ← note` | `<textarea th:field="*{note}"></textarea>` |
| `チェック：公開する ← published` | `<input type="checkbox" th:field="*{published}">` |
| `選択欄：所属 ← departmentId、選択肢 ← departments` | `<select th:field="*{departmentId}">` + `<option th:each>` |
| `エラー：name` | `<span th:if="${#fields.hasErrors('name')}" th:errors="*{name}">` |

- **`フォーム` のオブジェクト名は、フォームクラスの型名の先頭の1文字を小文字にしたもの**（`MemberForm` → `memberForm`）とし、
  `受取り` にも同じ名前で書く。コントローラーが渡す属性名がこの名前になるためである（`## 11.3`）。
- **`th:object` を指定したフォームの中では、必ず `*{…}` を使う。** `${memberForm.name}` と書かない。
- **`th:field` は `id`・`name`・`value` を自動生成する。** これらを手で書いてはならない。
- `<label for="…">` の値は、`th:field` が生成する id（フィールド名と同じ）に合わせる。
- `メソッド` の指定が無いフォームは `method="post"` を既定とする。
- **`選択欄` の生成例**

```html
<select id="departmentId" th:field="*{departmentId}">
  <option value="">選択してください</option>
  <option th:each="d : ${departments}"
          th:value="${d.id}"
          th:text="${d.name}">部署名</option>
</select>
```

---

## 30.6 レイアウトの共通化

`レイアウト：layout/base` と書かれた場合、`templates/layout/base.html` の
フラグメントを使う形で生成する。

**レイアウト側（`layout/base.html`）**

```html
<!doctype html>
<html xmlns:th="http://www.thymeleaf.org" lang="ja" th:fragment="page(title, content)">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title th:replace="${title}">タイトル</title>
</head>
<body>
  <header>
    <a th:href="@{/}">ホーム</a>
  </header>
  <main th:replace="${content}"></main>
</body>
</html>
```

**画面側**

```html
<!doctype html>
<html xmlns:th="http://www.thymeleaf.org" lang="ja"
      th:replace="~{layout/base :: page(~{::title}, ~{::main})}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>会員一覧</title>
</head>
<body>
  <main>
    <!-- ここに「構成」の内容を置く -->
  </main>
</body>
</html>
```

- **`レイアウト：なし` の場合**（`レイアウト` の行が無い場合も含む。`## 30.2`）は、フラグメントを使わず、`<head>`・`<body>` を持つ
  完全なHTMLとして生成する。`構成` の内容は `<body>` の直下に置く。
- レイアウトファイルそのものを生成するのは、SPDに `テンプレート：layout/base` が
  与えられた場合だけである。**存在しないレイアウトを勝手に作ってはならない。**
  参照先が見つからない場合は `## 0.8` の報告の【見つからない名前】に載せること。

---

## 30.7 テンプレート生成規約

### HTMLの骨格

- `<!doctype html>` から書く。
- `<html>` に `xmlns:th="http://www.thymeleaf.org"` と `lang="ja"` を付ける。
- `<meta charset="UTF-8">` を必ず入れる。
- その直後に `<meta name="viewport" content="width=device-width, initial-scale=1">` を必ず入れる。
  スマートフォンで縮小表示されないためである。`構成` に書かれていなくても生成する。
- インデントは半角スペース2つとする。

### エスケープ

- **出力は必ず `th:text` を使う。`th:utext` を生成してはならない。**
  SPDに「HTMLとして出力する」と書かれていた場合も生成せず、
  `## 0.8` の報告の【確認事項】に載せること（XSSの原因になるため）。

### 生成しないもの

- **CSSフレームワーク（Bootstrap等）のクラス名を勝手に付けない。**
  SPDに指定がある場合だけ付ける。
- **JavaScriptを勝手に追加しない。**
- `構成` に書かれていない要素（ナビゲーション・フッター・装飾用の `<div>`）を追加しない。

### SPDの残し方

**テンプレートSPD全体を、テンプレートの冒頭（`<!doctype html>` の直前）に
Thymeleafのコメントとして残す。**

```html
<!--/*
テンプレート：member/list
├─目的：会員の一覧を表示する
…
*/-->
<!doctype html>
```

- `<!--/* … */-->` は Thymeleaf がレンダリング時に取り除くため、ブラウザには出力されない。
  通常のHTMLコメント（`<!-- … -->`）では出力されてしまうので使わない。
- `spd-core` の `## 9.10` と同じく、**分割して各要素の直前に配ってはならない。**

---

## 30.8 生成時のチェックリスト（Thymeleaf）

- [ ] テンプレートを `templates/<テンプレート名>.html` に生成したか。テンプレート名をそのまま使ったか（`## 11.1`）
- [ ] `受取り` の名前と、コントローラーの「〜をテンプレートへ渡す」の名前が一致しているか（`## 11.2`）
- [ ] 静的な文字列に `th:text` を付けていないか。`th:text` にプレビュー用のダミーを残したか（`## 30.3`）
- [ ] すべてのパスを `@{…}` で囲んだか。素の `href`／`action` を書いていないか（`## 30.3`）
- [ ] パス変数を `{名前}` + `(名前=${式})` の形にしたか。文字列連結にしていないか（`## 30.3`）
- [ ] `th:each` を `<tr>`／`<li>` に付けたか。`<tbody>`／`<table>` に付けていないか（`## 30.4`）
- [ ] `th:object` の中で `*{…}` を使ったか。`${memberForm.…}` と書いていないか（`## 30.5`）
- [ ] `th:field` があるのに `id`／`name`／`value` を手で書いていないか（`## 30.5`）
- [ ] 各入力欄に対応する `エラー` を、`#fields.hasErrors` + `th:errors` で出したか（`## 30.5`）
- [ ] `th:utext` を生成していないか（`## 30.7`）
- [ ] 存在しないレイアウトを勝手に作っていないか（`## 30.6`）
- [ ] `構成` に無い要素・CSSクラス・JavaScriptを追加していないか（`## 30.7`）
- [ ] `xmlns:th`・`lang="ja"`・`<meta charset="UTF-8">`・`<meta name="viewport" …>` を入れたか（`## 30.7`）
- [ ] テンプレートSPD全体を `<!--/* … */-->` で冒頭に残したか（`## 30.7`）

---

## 30.9 完全な変換例

### 与えられたSPD

```
テンプレート：member/list
│
├─目的：会員の一覧を表示する
├─レイアウト：なし
├─タイトル：会員一覧
│
├─受取り
│  ├─members：List<Member>
│  └─message：String　※任意
│
└─構成
     ├─見出し：会員一覧
     ├─条件表示：messageがある
     │  └─通知：message
     ├─条件表示：membersが空である
     │  └─段落：会員が登録されていません。
     ├─表：membersの各要素をmとする
     │  ├─列：番号 ← m.id
     │  ├─列：名前 ← m.name
     │  └─列：操作
     │        └─リンク：編集 → /members/{m.id}/edit
     └─リンク：新規登録 → /members/new
```

### 生成されるテンプレート

```html
<!--/*
テンプレート：member/list
│
├─目的：会員の一覧を表示する
├─レイアウト：なし
├─タイトル：会員一覧
│
├─受取り
│  ├─members：List<Member>
│  └─message：String　※任意
│
└─構成
     ├─見出し：会員一覧
     ├─条件表示：messageがある
     │  └─通知：message
     ├─条件表示：membersが空である
     │  └─段落：会員が登録されていません。
     ├─表：membersの各要素をmとする
     │  ├─列：番号 ← m.id
     │  ├─列：名前 ← m.name
     │  └─列：操作
     │        └─リンク：編集 → /members/{m.id}/edit
     └─リンク：新規登録 → /members/new
*/-->
<!doctype html>
<html xmlns:th="http://www.thymeleaf.org" lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>会員一覧</title>
</head>
<body>
  <h1>会員一覧</h1>

  <div class="message" th:if="${message}" th:text="${message}">通知</div>

  <p th:if="${#lists.isEmpty(members)}">会員が登録されていません。</p>

  <table>
    <thead>
      <tr>
        <th>番号</th>
        <th>名前</th>
        <th>操作</th>
      </tr>
    </thead>
    <tbody>
      <tr th:each="m : ${members}">
        <td th:text="${m.id}">1</td>
        <td th:text="${m.name}">名前</td>
        <td>
          <a th:href="@{/members/{id}/edit(id=${m.id})}">編集</a>
        </td>
      </tr>
    </tbody>
  </table>

  <a th:href="@{/members/new}">新規登録</a>
</body>
</html>
```

---

## 更新履歴

| バージョン | 更新日 | 変更内容 |
|---|---|---|
| 1.0.0 | 2026-09-19 | 初版。SPDの型定義タイトルに `画面:` を新設し、`目的`／`レイアウト`／`タイトル`／`受取り`／`構成` のノードを定義（`## 30.2`）。構成ノード（見出し・段落・文字・通知・リンク・ボタン・表・一覧・条件表示・フォーム・入力欄・選択欄・エラー）とThymeleaf属性の対応表を規定（`## 30.3`〜`## 30.5`）。パスは `@{…}` で囲みパス変数は `{名前}` + `(名前=${式})` とする規則、`th:object` 内では `*{…}` を使う規則、`th:utext` の生成禁止を明記。レイアウトのフラグメント方式（`## 30.6`）、HTML骨格とSPDの残し方（`<!--/* … */-->`。`## 30.7`）、チェックリスト14項目（`## 30.8`）、完全な変換例（`## 30.9`）を追加 |
| 1.0.1 | 2026-09-26 | HTMLの骨格に `<meta name="viewport" content="width=device-width, initial-scale=1">` を必須として追加（`## 30.7`）。チェックリストの該当項目（`## 30.8`）と、`## 30.6`・`## 30.9` の生成例に反映 |
| 1.0.2 | 2026-09-26 | `レイアウト` の行が無い場合は `レイアウト：なし` として扱い、推測でレイアウトを適用しない規則を追加（`## 30.2`）。`## 30.6` の `レイアウト：なし` の説明にも同じ扱いを明記 |
| 1.1.0 | 2026-09-26 | SPDのタイトル `画面:` を `テンプレート:` に改称（コントローラの `テンプレート` ノードと同じ語にそろえるため）。「画面名」「画面SPD」「画面定義」の呼び方も「テンプレート名」「テンプレートSPD」「テンプレート定義」に変更（`## 30.1`・`## 30.2`・`## 30.6`〜`## 30.9`）。地の文の「画面」は変更していない |
| 1.2.0 | 2026-09-26 | コントローラーの `受渡し` ノード廃止（`springboot-java.instructions.md` v1.2.0）に合わせ、`受取り` と照合する名前を、コントローラーの `処理` の「〜をテンプレートへ渡す」の名前に変更（`## 30.2`・`## 30.8`）。地の文の「コントローラ」を「コントローラー」に統一 |
| 1.3.0 | 2026-09-26 | フォームのオブジェクト名を、フォームクラスの型名の先頭を小文字にしたもの（`memberForm`）に統一する規則を追加（`## 30.5`・`## 11.3`）。`## 30.5` の記法例・生成例・対応表・チェックリスト（`## 30.8`）の `form` を `memberForm` に変更 |
