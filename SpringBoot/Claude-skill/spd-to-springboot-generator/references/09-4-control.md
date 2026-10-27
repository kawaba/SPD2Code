### 9.4 制御構造・ラムダ式・ストリーム処理のパターン

#### 分岐（`◇`）

**【最優先・厳守】`◇` を `if` にするか `else if` にするかの判定規則**

判定は、次の文字テストだけで行う。

1. その `◇` から左へ、空白（半角・全角・タブ）を読み飛ばす。
2. 最初に現れた非空白文字を見る。

| 最初の非空白文字 | 意味 | 生成するJava |
|---|---|---|
| `│`、または行頭まで空白しかない | 直上の `◇` の続き | **`else if`** |
| **それ以外のすべて**（`─` `├` `└` `=` など） | 新しい枝の開始 | **独立した `if`**（分岐の先頭） |

- **桁位置（字下げ）の一致を判定材料にしてはならない。** 独立した `if` が連続する場合も `else if` の連鎖の場合も `◇` の開始桁は一致するため、桁位置では区別できない。
- `◇` が縦に連続していること自体は `else if` の根拠にならない。根拠は上の表の1点のみである。
- 判定が付かない場合は、**必ず独立した `if`** とする。`else if` は「`│` または行頭のみが先行する」という積極的な根拠があるときだけ生成する。
- SPDが長くても分岐が多くても、この判定を `◇` 1個ごとに毎回行う。

**パターンA：if / else**
```
├─◇─条件
│  │    └─真の場合の処理
│  └─else
│        └─偽の場合の処理
```
```java
if (条件) {
    真の場合の処理;
} else {
    偽の場合の処理;
}
```

**パターンB：単独のif（elseなし）**
```
├─◇─条件
│        └─処理
```
```java
if (条件) {
    処理;
}
```

**パターンB-2：独立したifが連続する場合（`else if` にしてはならない）**

`◇` の左に罫線 `─`（`├─◇` / `└─◇`）があるものは、縦に並んでいても**それぞれ独立した `if`** である。

```text
├─◇─条件1
│        └─処理1
├─◇─条件2
│        └─処理2
```
```java
// どちらも ◇ の左が ─ なので、独立した if を2つ生成する
if (条件1) {
    処理1;
}
if (条件2) {
    処理2;
}
```

**誤り例**：上のSPDを次のように変換してはならない。

```java
if (条件1) {
    処理1;
} else if (条件2) {   // ← 誤り。◇ の左は ─ であって │ ではない
    処理2;
}
```

**パターンC：if / else if / else（`◇` の縦の連続）**
```text
├─◇─条件1
│  │    └─処理1
│  ◇─条件2
│  │    └─処理2
│  └─else
│       └─デフォルト処理
```
```java
if (条件1) {
    処理1;
} else if (条件2) {
    処理2;
} else {
    デフォルト処理;
}
```

ここで2つ目の `◇` が `else if` になるのは、その左が `│` と空白だけで罫線 `─` が無いためである（`├─◇` になっていない）。1つ目の `◇` は左が `─` なので分岐の先頭、すなわち `if` である。

**パターンD：switch文（文として）**
```
└─◇─switch文: 変数の値で判定
    ├─case 値1なら処理1
    ├─case 値2か値3なら処理2
    └─default それ以外なら処理3
```
```java
switch (変数) {
    case 値1 -> 処理1;
    case 値2, 値3 -> 処理2;
    default -> 処理3;
}
```

**パターンE：switch式（戻り値あり）**
```
└─変数Xにswitch式の戻り値を代入する
       └─x=◇─switch式: 変数の値で判定
             ├─case 値1なら 値Aを返す
             ├─case 値2か値3なら 値Bを返す
             └─default それ以外なら 値Cを返す
```
```java
var X = switch (変数) {
    case 値1 -> 値A;
    case 値2, 値3 -> 値B;
    default -> 値C;
};
```

**パターンF：条件式（戻り値ありの一行条件）**
`◇─` を使わずに一行で記述された条件判定が、値を選択して変数へ代入する処理を表している場合は、`if` 文ではなく条件式（`? :`）で表現する。

```
├─numberが6なら"当たり"を、それ以外なら"はずれ"を変数messageに代入する
```
```java
String message = number == 6 ? "当たり" : "はずれ";
```

- 代入先の変数がSPDで型付きで示されている場合は、その型をそのまま使う。
- ローカル変数の型がSPDで明示されておらず、右辺がオブジェクトを返す式である場合は、プロジェクト方針に従って `var` を使用してよい。
- 分岐ごとに文を実行する場合や、複数行の処理を伴う場合は、このパターンではなく `if` / `else` を使用する。

#### 繰り返し（`↻`）

**パターンA：拡張for（コレクションの全要素を順に処理）**
```
└─↻─for: 変数nにlistから毎回１つずつ要素を取り出す
   └─処理
```
```java
for (var n : list) {
    処理;
}
```

**パターンB：while（条件式に副作用を含む形）**
```
└─↻─while: lineにreaderから1行読み込み、nullでない間繰り返す
   └─処理
```
```java
while ((line = reader.readLine()) != null) {
    処理;
}
```

**パターンC：無限ループ + break（条件付き脱出）**
```
├─合計の計算─↻─while: true
│             ├─処理1
│             ├─◇─終了条件
│             │  └─breakでループを脱出する
│             └─処理2
```
```java
while (true) {
    処理1;
    if (終了条件) {
        break;
    }
    処理2;
}
```

**パターンD：通常のfor（カウンタ制御）**
明示的にカウンタ範囲が示される場合：
```
└─↻─for: iを0からn未満まで1ずつ増やす
   └─処理
```
```java
for (int i = 0; i < n; i++) {
    処理;
}
```

#### 例外処理（`〇`）

**パターンA：try / catch**
```
├─〇─try
│  │  └─通常処理
│  〇─catch:例外型
│       └─例外時の処理
```
```java
try {
    通常処理;
} catch (例外型 e) {
    例外時の処理;
}
```

**パターンB：try-with-resources**
`try:` の右にリソース取得式が書かれている場合は try-with-resources にする。
```
├─〇─try:var in = Files.newBufferedReader(path) によりファイルを開く
│  │  └─ 通常処理
│  〇─catch:IOException e
│       └─エラー処理
```
```java
try (var in = Files.newBufferedReader(path)) {
    通常処理;
} catch (IOException e) {
    エラー処理;
}
```

**パターンC：例外を投げる（`…を投げる`）**

`（例外型）を投げる` は `throw new （例外型）(…);` を生成する。
コンストラクタの引数は、その `└─` の子ノードから決める。

| 子ノードの書き方 | 生成する引数 |
|---|---|
| （子ノードなし） | 引数なし（`throw new XxxException();`） |
| 「エラーメッセージは … とする」 | 第1引数（メッセージ） |
| 「原因は … とする」 | 第2引数（`cause`） |

```
├─◇─count は負である
│        └─CheckedNumberExceptionを投げる
│              └─エラーメッセージは "不正な値" + count とする
```
```java
if (count < 0) {
    throw new CheckedNumberException("不正な値" + count);
}
```

- 例外クラスの定義は、SPDに書かれていない限り**生成しない**。ワークスペースにも見つからない場合は、
  報告の【見つからない名前】に載せる（`## 0.8`）。
- 投げた例外が**検査例外**で、それを受ける `〇─catch:` がSPD内に無い場合は、
  囲んでいるメソッドの宣言に `throws` を補う（`## 9.6.6`）。

#### ラムダ式（`λ`）

`λ(引数並び)：<本体>` でラムダ式を表す。コロンは全角・半角どちらでもよい（`## 9.2`）。

**パターンA：式形式（本体が1つの式）**
```
──λ(a):a の重さは300 以上
```
```java
a -> a.weight() >= 300
```
`：` の右が1つの式のときは、`->` の右にその式をそのまま置く。
`{ }`・`return`・`;` は付けない。

**パターンB：引数の書き方**

| SPDの記述 | 生成する引数部 | 備考 |
|---|---|---|
| `λ()` | `()` | 引数なし |
| `λ(a)` | `a` | 1つのときは括弧を付けない |
| `λ(a, b)` | `(a, b)` | 2つ以上は括弧で囲む |
| `λ(Item a)` | `(Item a)` | 型を明記したときは1つでも括弧が必要 |

```
──λ(): 乱数を生成して返す
──λ(a):a を表示する
──λ(a, b):aのb 乗を返す
```
```java
() -> Math.random()
a -> System.out.println(a)
(a, b) -> Math.pow(a, b)
```
（この3例は、いずれもパターンGによりメソッド参照に書き換える。後述）

**パターンC：ブロック形式（`：┬`）**

本体を複数の処理にするときは `：` の右に `┬` を置き、子ノード（`├─` `└─`）に処理を並べる。
```
──λ(a):┬
       ├─a の重さを表示する
       └─a の重さは300 以上を返す
```
```java
a -> {
    System.out.println(a.weight());
    return a.weight() >= 300;
}
```
- 子ノードを上から順に文として生成し、全体を `{ }` で囲む。
- **最後の子ノードが「〜を返す」なら `return` 文にする。** 値を返さない（void）ラムダでは `return` を書かない。
- 子ノードの中では `◇`（分岐）・`↻`（繰り返し）・`〇`（例外処理）を通常どおり使ってよい。

**パターンD：本体の日本語の解釈**

| SPDの記述 | 生成する式 |
|---|---|
| 「〜を返す」 | その値を表す式そのもの（式形式では `return` を書かない） |
| 「〜は…以上」「〜と…は同じ」などの判定 | `boolean` 式（`>=` / `equals` など） |
| 「〜を表示する」 | 戻り値なしの出力処理（Web層では `log.info(...)`。`## 20.7`） |

**パターンE：外部変数の参照（キャプチャ）**

ラムダより前（同じ親の兄ノード）で宣言された変数は、そのまま参照してよい。
```
┬─final な変数String colorに"red" を入れる
└─λ(a):a の色は変数color と同じ
```
```java
final String color = "red";
a -> a.color.equals(color)
```
- `final な変数` と書かれていれば `final` を付けて宣言する。
- 書かれていなくても、ラムダ内で参照する外部ローカル変数は再代入しない（実質的finalを壊さない）。

**パターンF：ラムダの置かれ方**

- `λ` ノードが単独で置かれている場合は、**ラムダ式だけ**を生成する。
  代入先の関数型インタフェース（`Predicate` 等）は、SPDに指定が無いかぎり勝手に補わない。
- `## 9.3` ルール4 の横連結でλが右に来る場合は、左の処理の**引数として**ラムダを渡す。
```
├─listを重さ順に並べ替える─λ(a, b):aとbの重さを比較した結果を返す
```
```java
list.sort((a, b) -> Integer.compare(a.weight(), b.weight()));
```

**パターンG：メソッド参照への書き換え**

生成したラムダ式が次のいずれかの形に**完全に一致する**ときは、メソッド参照に書き換える。
一致しないものは**ラムダ式のまま**にする（迷った場合はラムダ式のまま残す＝安全側に倒す）。

| # | 種類 | ラムダ式の形 | メソッド参照 | 例 |
|---|---|---|---|---|
| 1 | レシーバ束縛形 | `(a, …) -> 式.method(a, …)` | `式::method` | `a -> System.out.println(a)` → `System.out::println` |
| 2 | static形 | `(a, …) -> 型.method(a, …)` | `型::method` | `(a, b) -> Math.pow(a, b)` → `Math::pow` |
| 3 | 型::インスタンスメソッド | `(型 a, …) -> a.method(…)` | `型::method` | `(Item a) -> a.weight()` → `Item::weight` |
| 4 | コンストラクタ参照 | `(a, …) -> new 型(a, …)` | `型::new` | `() -> new ArrayList<>()` → `ArrayList::new` |

**書き換えてはならない場合**
- 本体がブロック形式（`：┬`、パターンC）
- ラムダの引数が、呼び出しの引数として**同じ順序で過不足なく**渡されていない
  （例：`a -> a.color.equals(color)` はレシーバが `a` ではなく `a.color` なので**書き換えない**）
- 本体に演算子・比較・条件式が含まれる（例：`a -> a.weight() >= 300`）
- 種類3で、ラムダの引数の型がSPDに書かれておらず、`型::メソッド` の `型` を確定できない
  （`λ(a):a の重さを返す` は型が不明なので書き換えない。`λ(Item a):…` なら `Item::weight`）

**SPDにメソッド参照を直接書く場合**

SPDのノードに `型::メソッド` の形が直接書かれていれば、そのままメソッド参照として生成する
（`## 9.7 メソッド呼び出しの扱い` と同じ扱い。新しい記号は使わない）。
パターンGの対象外の形をメソッド参照で書かせたいときは、この書き方を使う。
```
──Item::weight
```
```java
Item::weight
```

#### ストリーム処理（`▽─stream:`）

`▽─stream:（コレクション）` で、そのコレクションに対するストリーム処理を表す。
コロンは全角・半角どちらでもよい（`## 9.2`）。

**パターンA：基本形（結果を変数に入れない場合）**
```
├─PCクラスのインスタンスのリストを取得（PC.getList()）して、変数listに入れる
│
└─▽─stream:list
    ├─メーカー名（maker ）が"Panan" であるものだけをフィルタリングする
    ├─機種名（name ）のストリームに変換する
    └─すべての要素をprintln で表示する
```
```java
List<PC> list = PC.getList();

list.stream()
    .filter(pc -> "Panan".equals(pc.maker()))
    .map(PC::name)
    .forEach(System.out::println);
```

- `▽─stream:X` は `X.stream()` を生成する。
- `▽` ノードの**子ノード**（`├─` `└─`）を**上から順に**中間操作・終端操作としてメソッドチェーンにする。
  **1つの子ノード＝1つの操作**である。
- 子ノードがさらに子（`└─ただし、…`）を持つ場合は、その操作に対する**詳細指定**である（`## 9.3` ルール3）。
- 終端操作の子ノードが1つも無い場合は**不整合として指摘する**（ストリームは終端操作が無いと実行されない）。

**パターンA-2：ストリーム源が式の場合（`▽─式`）**

`▽─` の右に**ストリームを返す式**が直接書かれている場合は、その式を**そのまま**ストリーム源として生成し、
子ノードを操作のチェーンにする。`（コレクション）.stream()` に限らず、`Files.lines(path)`・`Files.walk(path)`・
`Files.list(path)`・`Arrays.stream(a)`・`IntStream.range(0, n)` など、ストリームを返す式ならすべてこの形で書ける。

| SPDの書き方 | 生成するストリーム源 |
|---|---|
| `▽─stream:（コレクション）` | `（コレクション）.stream()`（パターンA） |
| `▽─（式）` | 書かれた式をそのまま（`Files.lines(path)` など） |

```
ストリームを使ってテキストファイルから行単位で読み込む
│
├─"nagasaki.txt"のパスを作ってpathに入れる
└─▽─Files.lines(path)
    │
    ├─空白でない行だけをフィルタリングする
    └─forEach でコンソールに表示する
```
```java
var path = Path.of("nagasaki.txt");

Files.lines(path)
     .filter(line -> !line.isBlank())
     .forEach(System.out::println);
```

- 子ノードの扱い（上から順に1ノード＝1操作、終端操作が無ければ不整合として指摘）はパターンAと同じ。
- **`try` を勝手に足さない。** `Files.lines`／`Files.walk`／`Files.list` は検査例外 `IOException` を投げるが、
  SPDに `〇`（例外処理）が書かれていない場合は try-with-resources も try-catch も補わず、
  囲んでいるメソッドの宣言に `throws IOException` を付ける
  （これらのストリームは本来 `close` が必要なので、正式にはパターンA-3の形で書く）。
- よく使う述語：「空白でない行だけを…」→ `.filter(line -> !line.isBlank())`、
  「ファイルだけを…」→ `.filter(Files::isRegularFile)`、「ディレクトリだけを…」→ `.filter(Files::isDirectory)`。
- インポートは `java.nio.file.Path`・`java.nio.file.Files`・`java.io.IOException`（`## 9.7`）。

**パターンA-3：`〇─try:` と横連結する場合（try-with-resources）**

`〇─try:` の右に `▽─式` が横連結されている場合は、その式をリソースとする **try-with-resources** にする
（例外処理のパターンB）。`▽` の子ノードは `try` ブロックの中身として生成する。

```
ストリームを使ってファイルとディレクトリを操作する
│
├─"d:/deel/"のパスを作って変数pathに入れる
│
〇─try:▽─Files.walk(path)
│      │
│      ├─ファイルだけをフィルタリングする
│      └─forEach でコンソールに表示する
│
〇─catch: IOException e
        └─標準エラー出力にスタックトレースを表示する
```
```java
var path = Path.of("d:/deel/");

try (var paths = Files.walk(path)) {
    paths.filter(Files::isRegularFile)
         .forEach(System.out::println);
} catch (IOException e) {
    e.printStackTrace();
}
```

- リソース変数名はSPDに指定が無ければ、`Files.lines` なら `lines`、`Files.walk`／`Files.list`／`Files.find` なら `paths`、
  それ以外は `stream` とする。`▽` の子ノードのチェーンは、この変数から始める。
- この形では `throws IOException` を付けない（例外はSPDのとおり `catch` で処理する）。

**パターンA-4：結果を変数に入れる場合（`変数←▽─式`）**

`変数←▽─式`（`変数=▽─式`）と書く。`〇─try:` に横連結されている場合は、**代入文も `try` ブロックの中**に生成する。

```
ストリームを使ってファイルとディレクトリを操作する
│
├─"d:/deel/"のパスを作って変数pathに入れる
│
〇─try:files←▽─Files.walk(path)
│              │
│              ├─ファイルだけをフィルタリングする
│              └─リストにする
│
〇─catch: IOException e
        └─標準エラー出力にスタックトレースを表示する
```
```java
var path = Path.of("d:/deel/");

try (var paths = Files.walk(path)) {
    List<Path> files = paths.filter(Files::isRegularFile)
                            .toList();
} catch (IOException e) {
    e.printStackTrace();
}
```

- 代入先の型は、要素型と終端操作から推測して明示的に書く（パターンD）。`Files.walk`／`Files.list` の要素型は `Path`、
  `Files.lines` の要素型は `String` である。
- SPDでその変数を **`try` の外（`〇` の後ろ）でも使っている**場合だけ、宣言を `try` の前に出し、
  `List<Path> files = List.of();` のように初期化しておいてから `try` の中で代入する。

**パターンB：結果を変数に入れる場合**

`変数←▽─stream:（コレクション）` または `変数=▽─stream:（コレクション）` と書く。
`←` と `=` は同じ意味（代入）である。

```
├─Departmentクラスのインスタンスのリストを取得（Department.getList()）して、変数listに入れる
│
├─従業員の名前のリストを作る
│    └─employees←▽─stream:list
│                  ├─従業員名のリスト（employees ）のストリームに変換する
│                  ├─従業員名のストリームに平たん化する
│                  └─リストにする
│
└─forEach でemployees の全ての要素を、スペースで区切って一行に表示する
```
```java
List<Department> list = Department.getList();

List<String> employees = list.stream()
        .map(Department::employees)
        .flatMap(List::stream)
        .toList();

employees.forEach(employee -> System.out.print(employee + " "));
```

- **代入先の変数の型は、ストリームの要素型と終端操作から推測して明示的に書く**（この場合は `var` を使わない）。
  型が確定できないときは、その旨をコメントで明示する。
- 変数名は**SPDに書かれたとおり**にする。ただし `employee_names` のようなスネークケースの場合は、
  Javaの命名規約に合わせて `employeeNames` に読み替える（この読み替えは黙って行う）。
- `←` は `## 9.2` の「等値判定/ゲッター/…の対象フィールド指定」とは別の用法で、
  **`自動生成` ノードの外では代入**を表す。

**パターンC：中間操作の対応表**

| SPDの記述 | 生成する操作 |
|---|---|
| 「…のストリームに変換する」 | `.map(…)` |
| 「…に平たん化する」 | `.flatMap(…)` |
| 「…だけをフィルタリングする」「…であるものだけを取り出す」 | `.filter(…)` |
| 「重複した要素を削除する」 | `.distinct()` |
| 「…でソートする」「…順に並べ替える」 | `.sorted(Comparator.comparing(…))`（自然順序なら `.sorted()`） |
| 「逆順にする」「降順に…」 | `Comparator.reverseOrder()` / `…reversed()` |
| 「先頭のn個を取り出す」 | `.limit(n)` |
| 「先頭のn個を読み飛ばす」 | `.skip(n)` |

**パターンD：終端操作と変数の型の対応表**

| SPDの記述 | 生成する操作 | 変数の型 |
|---|---|---|
| 「リストにする」 | `.toList()` | `List<要素型>` |
| 「セットにする」 | `.collect(toSet())` | `Set<要素型>` |
| 「…で連結した文字列を作成する」 | `.collect(joining(区切り文字))` | `String` |
| 「…でグループ分けしたマップにする」 | `.collect(groupingBy(…))` | `Map<キーの型, List<要素型>>` |
| 「…が最も大きな（小さな）要素を取り出す」 | `.max(…)` / `.min(…)` | `Optional<要素型>` |
| 「最初の要素を取り出す」 | `.findFirst()` | `Optional<要素型>` |
| 「合計を求める」 | `.sum()`（`mapToInt` 等の後） | `int` / `long` / `double` |
| 「個数を数える」 | `.count()` | `long` |
| 「…かどうか調べる」 | `.anyMatch(…)` / `.allMatch(…)` / `.noneMatch(…)` | `boolean` |
| 「（全ての要素を）表示する」 | `.forEach(…)` | （戻り値なし＝代入しない） |

**`Optional` から値を取り出すとき**

`max` / `min` / `findFirst` など `Optional` を返す終端操作の結果から値を取り出す場合は、
**引数なしの `orElseThrow()` を既定とする**（値が空なら `NoSuchElementException` が投げられる）。

```
├─max←▽─stream:list
│      └─価格（price ）が最も大きなPCを取り出す
│
└─max から値を取り出して表示する
```
```java
Optional<PC> max = list.stream()
        .max(Comparator.comparing(PC::price));

System.out.println("最高値=" + max.orElseThrow());
```

- **`get()` は生成しない。** SPDに「`get` メソッドで値を取り出す」と書かれていても
  `orElseThrow()` に読み替える（この読み替えは黙って行う）。
- `orElseThrow(NoSuchElementException::new)` のような冗長な指定もしない。
- 例外を明示するのは、空になる原因がSPDに書かれている場合だけとする
  （引数が原因なら `orElseThrow(() -> new IllegalArgumentException("…"))`、
  オブジェクトの状態が原因なら `IllegalStateException`、業務上の「見つからない」なら独自例外）。
- SPDが「値が無ければ〜する」と**空の場合の処理を書いている**ときは例外にせず、
  `ifPresentOrElse` / `orElse` / `orElseGet` を使う。

**パターンE：要素の指定と関数の書き方**

- 「PCのメーカー（maker ）」のように**括弧内にフィールド名／メソッド名**が書かれていれば、それを使う。
  要素型が確定できるなら `型::メソッド`（`PC::maker`）、確定できなければラムダ式（`pc -> pc.maker()`）にする
  （`## 9.4` パターンG）。
- 比較・演算・条件式を含む本体は、メソッド参照に書き換えず**ラムダ式のまま**にする
  （例：`pc -> "Panan".equals(pc.maker())`）。
- `▽` ノードの中に `λ(引数並び)：…`（`## 9.4`）が直接書かれている場合は、その操作の引数としてそのまま渡す。

**パターンF：グループ分けの詳細指定**

```
└─typeGroup←▽─stream:list
              └─PCのタイプ（type ）でグループ分けしたマップにする
                    └─ただし、マップの値をPCの名前（name ）のリストに変換する
```
```java
Map<String, List<String>> typeGroup =
        list.stream()
            .collect(groupingBy(PC::type, mapping(PC::name, toList())));
```
- 「ただし、マップの値を…にする」という `└─` の詳細指定は、`groupingBy` の**第2引数のダウンストリーム**
  （`mapping` / `counting` / `summingInt` など）として生成し、変数の型もそれに合わせる
  （値をリストにするなら `Map<K, List<E>>`、個数を数えるなら `Map<K, Long>`）。

**インポート**

`groupingBy`／`joining`／`toList`／`toSet`／`mapping`／`counting` などの `Collectors` のメソッドは、
`import static java.util.stream.Collectors.*;` で静的インポートして**短い名前で書く**（`## 9.7`）。
`Comparator`・`Optional`・`Map`・`List` などは通常どおりインポートする。
