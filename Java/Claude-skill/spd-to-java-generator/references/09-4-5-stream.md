#### ストリーム処理（`▽─stream:`）

`▽─stream:（コレクション）` で、そのコレクションに対するストリーム処理を表す。コロンは全角・半角どちらでもよい（`## 9.2`）。

##### パターンA：基本形（結果を変数に入れない場合）
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
- `▽` ノードの**子ノード**（`├─` `└─`）を**上から順に**中間操作・終端操作としてメソッドチェーンにする。**1つの子ノード＝1つの操作**である。
- 子ノードがさらに子（`└─ただし、…`）を持つ場合は、その操作に対する**詳細指定**である（`## 9.3` ルール3）。
- 終端操作の子ノードが1つも無い場合は**不整合として指摘する**（ストリームは終端操作が無いと実行されない）。

##### パターンA-2：ストリーム源が式の場合（`▽─式`）

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

##### パターンA-3：`〇─try:` と横連結する場合（try-with-resources）

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

##### パターンA-4：結果を変数に入れる場合（`変数←▽─式`）

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

##### パターンB：結果を変数に入れる場合

`変数←▽─stream:（コレクション）` または `変数=▽─stream:（コレクション）` と書く。`←` と `=` は同じ意味（代入）である。
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

- **代入先の変数の型は、ストリームの要素型と終端操作から推測して明示的に書く**（この場合は `var` を使わない）。型が確定できないときは、その旨をコメントで明示する。
- 変数名は**SPDに書かれたとおり**にする。ただし `employee_names` のようなスネークケースの場合は、Javaの命名規約に合わせて `employeeNames` に読み替える（この読み替えは黙って行う）。
- `←` は `## 9.2` の「等値判定/ゲッター/…の対象フィールド指定」とは別の用法で、**`自動生成` ノードの外では代入**を表す。

##### パターンC：中間操作の対応表

| SPDの記述 | 生成する操作 |
| --- | --- |
| 「…のストリームに変換する」 | `.map(…)` |
| 「…に平たん化する」 | `.flatMap(…)` |
| 「…だけをフィルタリングする」「…であるものだけを取り出す」 | `.filter(…)` |
| 「重複した要素を削除する」 | `.distinct()` |
| 「…でソートする」「…順に並べ替える」 | `.sorted(Comparator.comparing(…))`（自然順序なら `.sorted()`） |
| 「逆順にする」「降順に…」 | `Comparator.reverseOrder()` / `…reversed()` |
| 「先頭のn個を取り出す」 | `.limit(n)` |
| 「先頭のn個を読み飛ばす」 | `.skip(n)` |

##### パターンD：終端操作と変数の型の対応表

| SPDの記述 | 生成する操作 | 変数の型 |
| --- | --- | --- |
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

##### `Optional` から値を取り出すとき

`max` / `min` / `findFirst` など `Optional` を返す終端操作の結果から値を取り出す場合は、**引数なしの `orElseThrow()` を既定とする**（値が空なら `NoSuchElementException` が投げられる）。
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

- **`get()` は生成しない。** SPDに「`get` メソッドで値を取り出す」と書かれていても `orElseThrow()` に読み替える（この読み替えは黙って行う）。
- `orElseThrow(NoSuchElementException::new)` のような冗長な指定もしない。
- 例外を明示するのは、空になる原因がSPDに書かれている場合だけとする（引数が原因なら `orElseThrow(() -> new IllegalArgumentException("…"))`、オブジェクトの状態が原因なら `IllegalStateException`、業務上の「見つからない」なら独自例外）。
- SPDが「値が無ければ〜する」と**空の場合の処理を書いている**ときは例外にせず、`ifPresentOrElse` / `orElse` / `orElseGet` を使う。

##### パターンE：要素の指定と関数の書き方

- 「PCのメーカー（maker ）」のように**括弧内にフィールド名／メソッド名**が書かれていれば、それを使う。要素型が確定できるなら `型::メソッド`（`PC::maker`）、確定できなければラムダ式（`pc -> pc.maker()`）にする（`## 9.4` パターンG）。
- 比較・演算・条件式を含む本体は、メソッド参照に書き換えず**ラムダ式のまま**にする（例：`pc -> "Panan".equals(pc.maker())`）。
- `▽` ノードの中に `λ(引数並び)：…`（`## 9.4`）が直接書かれている場合は、その操作の引数としてそのまま渡す。

##### パターンF：グループ分けの詳細指定
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

- 「ただし、マップの値を…にする」という `└─` の詳細指定は、`groupingBy` の**第2引数のダウンストリーム**（`mapping` / `counting` / `summingInt` など）として生成し、変数の型もそれに合わせる（値をリストにするなら `Map<K, List<E>>`、個数を数えるなら `Map<K, Long>`）。

##### インポート

`groupingBy`／`joining`／`toList`／`toSet`／`mapping`／`counting` などの `Collectors` のメソッドは、`import static java.util.stream.Collectors.*;` で静的インポートして**短い名前で書く**（`## 9.7`）。`Comparator`・`Optional`・`Map`・`List` などは通常どおりインポートする。
