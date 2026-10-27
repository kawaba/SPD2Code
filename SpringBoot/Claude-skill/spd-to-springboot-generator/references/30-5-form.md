## 30.5 フォーム

### フォームの形

`［フォーム］[<オブジェクト名>] → [<HTTPメソッド>] <パス>` と書く。

| SPDの記述 | 生成 |
|---|---|
| `［フォーム］memberForm → POST /members` | `<form th:object="${memberForm}" th:action="@{/members}" method="post">` |
| `［フォーム］→ POST /members/{m.id}/delete` | `<form th:action="@{/members/{id}/delete(id=${m.id})}" method="post">` |
| `［フォーム］→ GET /members` | `<form th:action="@{/members}" method="get">` |

- **オブジェクト名は、フォームクラスの型名の先頭の1文字を小文字にしたもの**（`MemberForm` → `memberForm`）とし、
  `受け取り` にも同じ名前で書く。コントローラーが渡す属性名がこの名前になるためである（`## 11.3`）。
- **オブジェクト名を省略したフォーム**は `th:object` を持たない。削除（`POST`）や画面の移動（`GET`）のボタンだけを
  置くほか、簡単な入力テストのように、入力した値をコントローラーの `@パラメータ` でそのまま受け取るときにも使う
  （下記「フォームオブジェクトを使わない入力項目」）。
- HTTPメソッドを省略した場合は `post` とする。
- フォームの中に別のフォームを置いてはならない（HTMLでは入れ子にできない）。

### 入力項目

フォームの中の入力項目は、**`ラベル＜種類＞：フィールド名`** と書く。
- `ラベル` は画面に表示する項目名、`種類` は `<input>` などの種類（下の対応表）、`フィールド名` は入力した値を送る名前
  （生成する `id`・`name`）である。
- **`＜種類＞` は省略できない。** 1行の文字入力も `＜text＞` と書く。
- `フィールド名` は名前であり、値ではない。`{…}` で囲まない（`名前＜text＞：{name}` と書かれていた場合は生成せず、【確認事項】に載せること）。
- `ラベル：{…}` と書いた項目は入力項目ではなく、表示だけの項目になる（下記「フォームの中の表示だけの項目」）。
- **フォームの中に、`＜種類＞` が無く、値がフィールド名の形（英字で始まる英数字と `_` だけ）の `ラベル：値`
  （`名前：name` など）が書かれていた場合は、推測で入力項目にも表示だけの項目にもせず、【確認事項】に載せること。**
  `＜種類＞` の書き忘れであることが多いためである。値が空のもの（`空欄：`）や、それ以外の文字（`注意：半角で入力`）は、
  そのまま表示する。

この節の規則は、オブジェクト名を書いたフォーム（`th:object`）のものである。オブジェクト名を省略したフォームの
入力項目は、下記「フォームオブジェクトを使わない入力項目」に従う。

```
テンプレート：member/form
│
├─目的：会員を登録する
├─タイトル：会員登録
├─css：css/style.css
│
├─受け取り
│  └─入力内容：MemberForm memberForm
│
└─構成
     ├─［見出し］会員登録
     ├─［フォーム］memberForm → POST /members
     │    ├─［表（行）］
     │    │    ├─名前＜text＞：name
     │    │    ├─入会日＜date＞：joinedOn
     │    │    ├─会員種別＜radio＞：kind
     │    │    │    ├─一般：general
     │    │    │    └─学生：student
     │    │    └─メディア＜checkbox＞：mediaTypes
     │    │         ├─印刷本：print
     │    │         └─電子書籍：ebook
     │    ├─番号＜hidden＞：id
     │    └─登録する＜submit＞
     │
     └─［フォーム］→ GET /members
          └─戻る＜submit＞
```

**種類の対応表**

| SPDの種類 | 生成 |
|---|---|
| `＜text＞` | `<input type="text" th:field="*{f}">` |
| `＜number＞`・`＜date＞`・`＜time＞`・`＜datetime-local＞`・`＜email＞`・`＜password＞`・`＜tel＞`・`＜url＞` | `<input type="…" th:field="*{f}">` |
| `＜hidden＞` | `<input type="hidden" th:field="*{f}">`（ラベルもエラー表示も付けない） |
| `＜textarea＞` | `<textarea th:field="*{f}"></textarea>` |
| `＜checkbox＞`（子なし） | `<input type="checkbox" th:field="*{f}">`（`boolean` のフィールド） |
| `＜checkbox＞`（子あり） | 選択肢ごとに `<label><input type="checkbox" th:field="*{f}" value="…"> 表示名</label>` |
| `＜radio＞`（子あり） | 選択肢ごとに `<label><input type="radio" th:field="*{f}" value="…"> 表示名</label>` |
| `＜select＞`（子あり） | `<select th:field="*{f}">` ＋ 選択肢ごとに `<option value="…">表示名</option>` |

- **選択肢は、子の枝に `表示名：値` と書く。** `＜radio＞`・`＜select＞` は選択肢が必須である。
- 選択肢をコントローラーから受け取ったリストから作る場合は、下記「リストから作る選択肢」の書き方をする。
- 表に無い種類は、推測せず【確認事項】に載せること。
- ボタン（`＜submit＞`・`＜reset＞`）は入力項目ではない（下記「ボタン」）。

**入力項目に共通の規則**

- **`th:object` を指定したフォームの中では、フォームオブジェクトのフィールドに必ず `*{…}` を使う。** `${memberForm.name}` と書かない
  （SPD の `{memberForm.name}` も `*{name}` で生成する。下記「フォームの中の表示だけの項目」）。
- **`th:field` は `id`・`name`・`value` を自動生成する。** これらを手で書いてはならない
  （選択肢の `value` は例外。`th:field` はチェックボックス・ラジオボタン・選択肢の値を作らないため）。
- **`＜hidden＞` 以外のすべての入力項目に、エラー表示を付ける。** 入力欄（選択肢がある場合は最後の選択肢）の直後に置く。
  ```html
  <span class="error-msg" th:if="${#fields.hasErrors('name')}" th:errors="*{name}">エラー</span>
  ```
  検証アノテーションが無いフィールドでも、型変換のエラー（日付・数値の変換失敗）は起こるためである。
  `class="error-msg"` は固定で付ける（`## 30.7` の「CSSクラスを勝手に付けない」の例外）。見た目は CSS で定める。
- ラベルは書かれたとおりに出す（`：` などを補わない）。
- 選択肢の無い入力項目は、`<label for="<フィールド名>">` でラベルを付ける（`th:field` が作る `id` はフィールド名と同じ）。
  選択肢のある `＜checkbox＞`・`＜radio＞` と、子の無い `＜checkbox＞` は、`th:field` が `id` に連番を付けるため
  `for` を使わず、選択肢ごとに `<label>` で入力を包む。項目のラベルは文字だけで出す。

### 表（行）

**`［表（行）］`** は、**子の各枝が1つの行**を表す表である。繰り返しは無い。
フォームの入力項目を、左にラベル・右に入力欄の形で並べるときに使う。フォームの外で、詳細画面のように
左に項目名・右に値の形で並べるときにも使う（下記「行の書き方」）。

```html
<form th:object="${memberForm}" th:action="@{/members}" method="post">
  <input type="hidden" th:field="*{id}">
  <table>
    <tr>
      <td><label for="name">名前</label></td>
      <td>
        <input type="text" th:field="*{name}">
        <span class="error-msg" th:if="${#fields.hasErrors('name')}" th:errors="*{name}">エラー</span>
      </td>
    </tr>
    <tr>
      <td><label for="joinedOn">入会日</label></td>
      <td>
        <input type="date" th:field="*{joinedOn}">
        <span class="error-msg" th:if="${#fields.hasErrors('joinedOn')}" th:errors="*{joinedOn}">エラー</span>
      </td>
    </tr>
    <tr>
      <td>会員種別</td>
      <td>
        <label><input type="radio" th:field="*{kind}" value="general"> 一般</label>
        <label><input type="radio" th:field="*{kind}" value="student"> 学生</label>
        <span class="error-msg" th:if="${#fields.hasErrors('kind')}" th:errors="*{kind}">エラー</span>
      </td>
    </tr>
    <tr>
      <td>メディア</td>
      <td>
        <label><input type="checkbox" th:field="*{mediaTypes}" value="print"> 印刷本</label>
        <label><input type="checkbox" th:field="*{mediaTypes}" value="ebook"> 電子書籍</label>
        <span class="error-msg" th:if="${#fields.hasErrors('mediaTypes')}" th:errors="*{mediaTypes}">エラー</span>
      </td>
    </tr>
  </table>
  <button type="submit">登録する</button>
</form>

<form th:action="@{/members}" method="get">
  <button type="submit">戻る</button>
</form>
```

- 入力項目の行は `<tr><td>ラベル</td><td>入力欄とエラー表示</td></tr>` とする。
- **`［表（行）］` には「〜の各要素を〜とする」を書かない。** 書かれていた場合は生成せず、【確認事項】に載せること。
- `＜hidden＞` の項目は行を作らない。`［表（行）］` の中に書かれていても、`<table>` の直前に置く。
- `［表（行）］` を使わず、入力項目を `［フォーム］` の直下に書いた場合は、1項目を1つの `<div>` にまとめる
  （`<div><label …>…</label> 入力欄 エラー表示</div>`）。

**行の書き方**

**`：` がある行は2マス、`：` が無い `［ノード］` の行は1マス**である。

| SPDの記述 | 生成 |
|---|---|
| `日付：{birthday}` | `<tr><td>日付</td><td th:text="${birthday}">2026-01-01</td></tr>` |
| `空欄：`（子なし） | `<tr><td>空欄</td><td></td></tr>` |
| `：左マスは空欄` | `<tr><td></td><td>左マスは空欄</td></tr>` |
| `参考図：［画像］/images/sample.png <<50px>>` | `<tr><td>参考図</td><td><img th:src="@{/images/sample.png}" alt="" width="50"></td></tr>` |
| `：［リンク］戻る → /end` | `<tr><td></td><td><a th:href="@{/end}">戻る</a></td></tr>` |
| `［空］：［リンク］戻る → /end` | `：［リンク］戻る → /end` と同じ |
| `操作：` ＋ 子 | `<tr><td>操作</td><td>子を書かれた順に</td></tr>` |
| `［空］：` ＋ 子 | `<tr><td></td><td>子を書かれた順に</td></tr>` |
| `┬─…` ＋ `├─…`・`└─…` | `<tr><td colspan="2">要素を書かれた順に</td></tr>`（下記「1つのマスに複数の要素を並べる」） |
| `［段落］これは段落`（`：` が無い） | `<tr><td colspan="2"><p>これは段落</p></td></tr>` |
| `［リンク］戻る → /end`（`：` が無い） | `<tr><td colspan="2"><a th:href="@{/end}">戻る</a></td></tr>` |
| `備考＜text＞：memo` | 入力項目の行（上記） |

```
├─受け取り
│  └─会員：Member member
│
└─構成
     ├─［見出し］会員詳細
     └─［表（行）］
          ├─番号：{member.id}
          ├─名前：{member.name}
          ├─写真：［画像］/images/{member.photo} "{member.name}の写真" <<120px .写真枠>>
          ├─紹介：
          │    ├─［文字］{member.name}さんのページは
          │    └─［リンク］こちら → /members/{member.id}/profile
          ├─操作：
          │    ├─［リンク］編集 → /members/{member.id}/edit
          │    ├─［文字］|
          │    └─［フォーム］→ POST /members/{member.id}/delete
          │          └─削除＜submit＞
          └─［リンク］一覧へ戻る → /members
```
```html
<table>
  <tr>
    <td>番号</td>
    <td th:text="${member.id}">1</td>
  </tr>
  <tr>
    <td>名前</td>
    <td th:text="${member.name}">名前</td>
  </tr>
  <tr>
    <td>写真</td>
    <td><img th:src="@{/images/{photo}(photo=${member.photo})}" th:alt="|${member.name}の写真|" alt="" width="120" class="写真枠"></td>
  </tr>
  <tr>
    <td>紹介</td>
    <td>
      <span th:text="|${member.name}さんのページは|">名前さんのページは</span>
      <a th:href="@{/members/{id}/profile(id=${member.id})}">こちら</a>
    </td>
  </tr>
  <tr>
    <td>操作</td>
    <td>
      <a th:href="@{/members/{id}/edit(id=${member.id})}">編集</a>
      |
      <form th:action="@{/members/{id}/delete(id=${member.id})}" method="post">
        <button type="submit">削除</button>
      </form>
    </td>
  </tr>
  <tr>
    <td colspan="2"><a th:href="@{/members}">一覧へ戻る</a></td>
  </tr>
</table>
```

**2マスの行（`：` がある行）**

- 左のマスはラベル、右のマスは値である。ラベルが無い（`：値`）ときは左を、値が無い（`ラベル：`）ときは右を、空の `<td></td>` にする。
  ラベルが無いことは、`［空］：値` とも書ける（`## 30.1`）。`：値` と同じ HTML を生成する。
- 値は `## 30.3` の「値の書き方」のとおりに書く。値の位置には `［画像］`・`［リンク］`・`［文字］`・`［通知］` を書ける
  （`## 30.3` の「値の位置に書くノード」）。
- **値を書かず `ラベル：` の子に並べた行**（上の例の `紹介：`・`操作：`）は、子ノードの内容を、書かれた順に2つ目の `<td>` の中に置く。
  子に書けるノードは、`［表（列）］` の子に並べた列と同じである（`## 30.4`）。
  **フォームの中の表では、ボタン（`＜submit＞`・`＜reset＞`）も子に書ける**（下記「1つのマスに複数の要素を並べる」）。
  入力項目は子に書けない。1行に複数の入力欄を並べる書き方は、この規約に無い。
- 要素が1つだけのときは、子に置かず値の位置に書く（`写真：［画像］…`）。子を1つだけ置いた場合も、値の位置に書いたときと
  同じ HTML を生成する。
- **値と子の両方を書いた行は、生成せず【確認事項】に載せること。**

**1マスの行（`：` が無い行）**

- `［ノード］` の行は、2つのマスを結合した1マスの行（`<tr><td colspan="2">…</td></tr>`）にする。
- 1マスの行に書けるのは、`［段落］`・`［画像］`・`［文字］`・`［通知］`・`［リンク］`・`［フォーム］`（ボタンだけのフォーム）である。
  それ以外のノード（`［見出し］`・`［表（行）］` など）が書かれていた場合は生成せず、【確認事項】に載せること。
- **フォームの中の表では、ボタン（`送信＜submit＞`・`消去＜reset＞`）を1つだけ書いた行も1マスの行にする。**
  `┬─送信＜submit＞` と書いたときと同じ HTML（`<tr><td colspan="2"><button type="submit">送信</button></td></tr>`）を生成する。
  ボタンを入力欄の列（右のマス）にそろえたいときは、`［空］：` の子に置く（下記）。
- `：` も `［…］` も無い文字だけの行（`操作`）は、生成せず【確認事項】に載せること（`## 30.1`）。
- 1マスの中に複数の要素を並べるときは、`┬` でまとめる（下記）。

**1つのマスに複数の要素を並べる**

ボタンやリンクなどを1つのマスに並べる書き方は2つある。

| 書き方 | 並べる場所 |
|---|---|
| `［空］：`（または `ラベル：`）の子に並べる | 2マスの右のマス（入力欄の列にそろう） |
| `┬` でまとめる | 2つのマスを結合した1マス（`colspan="2"`） |

```
├─［フォーム］→ POST /select
│    └─［表（行）］
│          ├─都市＜select＞：city
│          │    ├─東京：東京
│          │    └─大阪：大阪
│          └─［空］：
│                ├─送信＜submit＞
│                ├─消去＜reset＞
│                └─［リンク］キャンセル → /list
│
└─［フォーム］→ POST /select
      └─［表（行）］
            ├─都市＜select＞：city
            │    ├─東京：東京
            │    └─大阪：大阪
            └─┬─送信＜submit＞ <<.中央揃え>>
               ├─消去＜reset＞
               └─［リンク］キャンセル → /list
```
```html
<form th:action="@{/select}" method="post">
  <table>
    <tr>
      <td><label for="city">都市</label></td>
      <td>
        <select id="city" name="city">
          <option value="東京">東京</option>
          <option value="大阪">大阪</option>
        </select>
      </td>
    </tr>
    <tr>
      <td></td>
      <td>
        <button type="submit">送信</button>
        <button type="reset">消去</button>
        <a th:href="@{/list}">キャンセル</a>
      </td>
    </tr>
  </table>
</form>

<form th:action="@{/select}" method="post">
  <table>
    <tr>
      …（上と同じ）
    </tr>
    <tr>
      <td colspan="2" class="中央揃え">
        <button type="submit">送信</button>
        <button type="reset">消去</button>
        <a th:href="@{/list}">キャンセル</a>
      </td>
    </tr>
  </table>
</form>
```
```css
/* css：に書いたファイルに定義する */
.中央揃え {
  text-align: center;
}
```

- **`┬` の右に1つ目の要素を書き、2つ目からは `┬` の下に `├─`・`└─` で並べる。** すべての要素を、書かれた順に1つの `<td colspan="2">` の中に置く。
- `┬` でまとめた要素に書けるのは、1マスの行に書けるノード（上記）と、ボタン（`＜submit＞`・`＜reset＞`）である。
  ボタンはフォームの中の表でだけ書ける（`## 30.1`）。入力項目・`ラベル：値`・`［見出し］` などが書かれていた場合は生成せず、【確認事項】に載せること。
- **`┬` の行の末尾の `<<…>>` は、`<td colspan="2">` に付ける**（1つ目の要素には付かない）。書けるのはクラス名だけである（`## 30.4` の「CSSクラスの指定」）。
  書式・サイズが書かれていた場合は生成せず、【確認事項】に載せること。サイズなどの `<<…>>` を付けた `［画像］` や、クラス名を付けた `［リンク］` は、2つ目以降に置く。
- クラス名を書かない場合は、`class` を付けない。中央揃えなどの配置は、クラス名を付けて CSS で定める（`style` 属性にしない）。
- 要素が1つだけのときは `┬` を使わず、1マスの行（`［リンク］戻る → /end`・`送信＜submit＞`）として書く。
- `┬` は `［表（行）］` の子にだけ書ける。`［表（列）］` の列、`［フォーム］` の直下、`構成` の直下などに書かれていた場合は生成せず、【確認事項】に載せること。

**フォームの中の表（行）**

- フォームの中でも外でも使える。入力項目の行と、表示の行・1マスの行を混ぜてよい。
- フォームの中の `［表（行）］` には `［フォーム］` を書けない（フォームの入れ子になるため。上記「フォームの形」）。
- フォームの中では、`{memberForm.…}` を `*{…}` で生成する（下記「フォームの中の表示だけの項目」）。

### フォームの中の表示だけの項目

フォームの中でも、**`<ラベル>：<値>[<<書式・クラス名>>]`** と書いた項目は、入力欄を作らず値を表示するだけである
（編集画面の会員番号など）。値は送信されない。

```
├─［フォーム］memberForm → POST /members/update
│    ├─［表（行）］
│    │    ├─会員番号：{memberForm.id}
│    │    └─名前＜text＞：name
│    ├─番号＜hidden＞：id
│    └─更新する＜submit＞
```
```html
<tr>
  <td>会員番号</td>
  <td th:text="*{id}">1</td>
</tr>
```

- **値の `{…}` は、フォームの中でも `受け取り` の名前から始める**（`## 30.3` の「値の書き方」）。フォームオブジェクトの
  フィールドは `{memberForm.id}` と書き、`{id}` とは書かない。`{id}` は `受け取り` の `id` を指すことになるためである。
- `th:object` のフォームの中では、フォームのオブジェクト名で始まる式を、オブジェクト名を除いて `*{…}` で生成する
  （`{memberForm.id}` → `th:text="*{id}"`、文字と混ざる場合は `{memberForm.id}番` → `th:text="|*{id}番|"`）。
  `${memberForm.id}` とは書かない。
- フォームオブジェクト以外の値（`{departmentName}` など）は、フォームの中でも `${…}` で生成する。
  オブジェクト名を省略したフォームの中では、すべて `${…}` で生成する。
- 入力項目のフィールド名（`名前＜text＞：name`・`番号＜hidden＞：id`）は、値ではなく送る名前なので、
  オブジェクト名を付けずに書く（`## 30.5` の「入力項目」）。**`{…}` で書くのは画面に出す値、`：` の後にそのまま書くのは送る名前**である。
  `th:field="*{id}"` が送る名前と今の値の両方を決めるため、`番号＜hidden＞：{memberForm.id}` とは書かない。
- 値がフィールド名の形の `ラベル：値`（`名前：name`）は、`＜種類＞` の書き忘れとして報告する（上記「入力項目」）。
- `<label>` もエラー表示も付けない。
- `［表（行）］` の中では上記「行の書き方」のとおりに生成する。
  `［フォーム］` の直下では `<div>ラベル <span th:text="…">ダミー</span></div>` とする。値の位置のノード（`戻り先：［リンク］…`）は、
  `<span>` の代わりにそのノードの要素を置く（`<div>戻り先 <a …>…</a></div>`）。
- 値の書き方は `## 30.3` の「値の書き方」、書式とクラス名（`<<…>>`）は `## 30.4` の「値の書式」「CSSクラスの指定」と同じである。
- 値を送信もしたい場合は、この項目とは別に `＜hidden＞` の項目を書く（上の例の `番号＜hidden＞：id`）。

### フォームオブジェクトを使わない入力項目

簡単な入力テストのように、入力した値をコントローラーでそのまま受け取るだけの場合は、
**オブジェクト名を省略したフォーム**に入力項目を置く。書き方は上の「入力項目」と同じ `ラベル＜種類＞：名前` であるが、
`名前` はフォームのフィールド名ではなく、**リクエストパラメーターの名前**である。

```
テンプレート：test/input
│
├─目的：入力した値を送信する
├─タイトル：入力テスト
│
├─受け取り：なし
│
└─構成
     ├─［見出し］入力テスト
     └─［フォーム］→ POST /test
          ├─名前＜text＞：name
          ├─年齢＜number＞：age
          ├─会員種別＜radio＞：kind
          │    ├─一般：general
          │    └─学生：student
          └─送信する＜submit＞
```
```html
<form th:action="@{/test}" method="post">
  <div><label for="name">名前</label> <input type="text" id="name" name="name"></div>
  <div><label for="age">年齢</label> <input type="number" id="age" name="age"></div>
  <div>会員種別
    <label><input type="radio" name="kind" value="general"> 一般</label>
    <label><input type="radio" name="kind" value="student"> 学生</label>
  </div>
  <button type="submit">送信する</button>
</form>
```

**種類の対応表**（`n` はパラメーター名）

| SPDの種類 | 生成 |
|---|---|
| `＜text＞` | `<input type="text" id="n" name="n">` |
| `＜number＞`・`＜date＞`・`＜time＞`・`＜datetime-local＞`・`＜email＞`・`＜password＞`・`＜tel＞`・`＜url＞` | `<input type="…" id="n" name="n">` |
| `＜textarea＞` | `<textarea id="n" name="n"></textarea>` |
| `＜checkbox＞`（子なし） | `<input type="checkbox" name="n" value="true">` |
| `＜checkbox＞`（子あり） | 選択肢ごとに `<label><input type="checkbox" name="n" value="…"> 表示名</label>` |
| `＜radio＞`（子あり） | 選択肢ごとに `<label><input type="radio" name="n" value="…"> 表示名</label>` |
| `＜select＞`（子あり） | `<select id="n" name="n">` ＋ 選択肢ごとに `<option value="…">表示名</option>` |

- **初期値は常に空（`""`）である。** `value`（選択肢の `value` を除く）・`th:value`（選択肢の `th:value` を除く）・
  `checked`・`selected` を付けない。
  送信後に同じ画面を返すと、入力した値は消える。値を残したい画面は、フォームオブジェクトを使うこと。
- **`id`・`name` は手で書く。** `th:field`・`*{…}` は使わない（`th:object` が無いため）。`id` は、`<label for>` を使う
  選択肢の無い入力項目と `<select>` にだけ付ける。
- **エラー表示を付けない。** 検証の結果（`BindingResult`）が無く、`#fields` を使えないためである。
- **`＜hidden＞` は生成せず、【確認事項】に載せること。** 初期値が常に空なので、送る値が無いためである。
- 表に無い種類も、推測せず【確認事項】に載せること。
- ラベルの付け方、`［表（行）］` の中での配置、`［フォーム］` の直下に書いた場合の `<div>` は、上の規則と同じである
  （エラー表示が無いだけが異なる）。
- 下記「リストから作る選択肢」も使える。`th:field` の代わりに `name`（`<select>` には `id` も）を書き、エラー表示を付けない。
- 同じフォームの中に、`th:field` を使う入力項目と混ぜることはできない（`th:object` が無いため）。
- **受け取る側**は、送信先のハンドラーメソッドの `@パラメータ` の引数である。変数名はパラメーター名と一致させ、
  既定値（`= ""` など）を付けることを推奨する（`## 11.4`）。

### ボタン

ボタンは、入力項目と同じ形で **`キャプション＜種類＞`** と書く。`キャプション` はボタンに表示する文字である。

| SPDの記述 | 生成 |
|---|---|
| `登録する＜submit＞` | `<button type="submit">登録する</button>` |
| `クリア＜reset＞` | `<button type="reset">クリア</button>` |

- ボタンには `：` 以降を書かない（送る値を持たない）。書かれていた場合は生成せず、【確認事項】に載せること。
- **ボタンはフォームの中にだけ書ける**（`## 30.1`）。フォームの外（`［リンク］` の子など）に書かれていた場合は生成せず、
  【確認事項】に載せること。
- フォームの中の `［表（行）］` では、ボタンとリンクを1つのマスに並べられる（`［空］：` の子・`┬`。上記「表（行）」）。
  ボタンを1つだけ書いた行は、2つのマスを結合した1マスの行になる（上記「表（行）」の「1マスの行」）。
- 上記以外の種類（`＜button＞` など）は、JavaScript が無いと動かないため生成せず、【確認事項】に載せること。

### リストから作る選択肢

`＜select＞`・`＜radio＞`・`＜checkbox＞` の選択肢を、コントローラーから受け取ったリスト（部署の一覧など）から作る場合は、
入力項目の子に **`<リスト>の各要素を<変数>とする`** の枝を置き、その子に **`{表示名の式}：{値の式}`** を1行書く。

```
├─受け取り
│  ├─入力内容：MemberForm memberForm
│  └─部署リスト：List<Department> departments
…
│    ├─所属＜select＞：departmentId
│    │    └─departmentsの各要素をdとする
│    │         └─{d.name}：{d.id}
```
```html
<label for="departmentId">所属</label>
<select th:field="*{departmentId}">
  <option value="">選択してください</option>
  <option th:each="d : ${departments}" th:value="${d.id}" th:text="${d.name}">表示名</option>
</select>
<span class="error-msg" th:if="${#fields.hasErrors('departmentId')}" th:errors="*{departmentId}">エラー</span>
```

| SPDの種類 | 生成（`L` はリスト、`x` は変数、`f` はフィールド名） |
|---|---|
| `＜select＞` | `<option value="">選択してください</option>` ＋ `<option th:each="x : ${L}" th:value="${x.値}" th:text="${x.表示名}">表示名</option>` |
| `＜radio＞` | `<label th:each="x : ${L}"><input type="radio" th:field="*{f}" th:value="${x.値}"> <span th:text="${x.表示名}">表示名</span></label>` |
| `＜checkbox＞` | `<label th:each="x : ${L}"><input type="checkbox" th:field="*{f}" th:value="${x.値}"> <span th:text="${x.表示名}">表示名</span></label>` |

- 書き方は `［表（列）］` の「〜の各要素を〜とする」と同じである（`## 30.4`）。変数名は自由に付けてよい。
  ただし、入力項目の子なので `［…］` で囲まない。
- **`{表示名の式}：{値の式}` は、固定の選択肢と同じ「表示名：値」の順**である。式は変数から始める（`d.name`）。
- **固定の選択肢とは、`{…}` の有無で見分ける。** `一般：general` は固定の選択肢、`{d.name}：{d.id}` はリストから作る選択肢である。
  固定の選択肢（入力項目の直下）に `{…}` があった場合、リストから作る選択肢（「〜の各要素を〜とする」の下）に `{…}` が
  無かった場合は、生成せず【確認事項】に載せること。
- 表示名は、文字と変数を混ぜて書いてよい（`{d.code} {d.name}：{d.id}` → `th:text="|${d.code} ${d.name}|"`。`## 30.3` の「値の書き方」）。
  `：` の左に `{…}` を書けるのは、ここだけである。値は `{…}` 1つだけとする。
- **リストの名前は、`受け取り` に書かれていなければならない**（`## 30.2`）。無い場合は推測で補わず、
  `## 0.8` の報告の【見つからない名前】に載せること。
- `＜select＞` には、先頭に `<option value="">選択してください</option>` を必ず付ける。`＜radio＞`・`＜checkbox＞` には付けない。
- `＜radio＞`・`＜checkbox＞` では、`<label>` に `th:text` を付けない（中の `<input>` が消えるため）。表示名は `<span>` で出す。
- 固定の選択肢と、リストから作る選択肢を、同じ入力項目の中に混ぜてはならない。
  「〜の各要素を〜とする」の子が `{表示名の式}：{値の式}` の1行でない場合も含めて、生成せず【確認事項】に載せること。
- `［表（行）］` の中に書いた場合の配置、ラベルの付け方、エラー表示は、上の「入力項目」と同じである。
- オブジェクト名を省略したフォームでは、`th:field` の代わりに `name="f"`（`<select>` には `id="f"` も）を書き、エラー表示を付けない。

