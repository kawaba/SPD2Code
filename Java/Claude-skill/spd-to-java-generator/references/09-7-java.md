### 9.7 Javaコード生成規約

#### 言語仕様・型

* Java 21以降を前提とし、`record` / `switch式` / `var` / テキストブロック / パターンマッチング等の現代機能を積極的に活用する。`javax.*` ではなく `jakarta.*` を使う（該当する場合）。
* SPDで `var` と表記 → Javaも `var`。`int total` のように型が明示されていればその型を使う。レコード／メソッドの引数・戻り値もSPDの記述通りの型にする。

#### 入出力

| SPDの記述 | Javaコード |
| --- | --- |
| キーボードから入力 | `Input.getInt()` / `getDouble()` / `getString()` など（`Input.getInt("ガイド文字列")` の形も可。`## 4`） |
| コンソールに表示 | `System.out.println(...)` |
| `"〇〇=△△"` の形式で表示 | `System.out.printf("〇〇=%s%n", 値)` または `String.format` |
| コロンとタブで区切って表示 | `System.out.println(a + ":\t" + b)` |

#### ファイルI/O

| SPDの記述 | Javaコード |
| --- | --- |
| パスを代入 | `var path = Path.of("ファイル名");` |
| 全内容をリストとして一括読み出し | `var list = Files.readAllLines(path);` |
| 行ごとの読み込み | `try (var in = Files.newBufferedReader(path)) { ... }` |
| 行単位のストリーム読み込み | `Files.lines(path)`（SPDは `▽─Files.lines(path)`。`## 9.4` パターンA-2） |
| ディレクトリをたどる | `Files.walk(path)`（再帰）／`Files.list(path)`（直下のみ）（`## 9.4` パターンA-3） |
| リストを一括出力 | `Files.write(path, list);` |
| 行ごとの書き出し | `try (var out = new PrintWriter(Files.newBufferedWriter(path))) { ... }` |

#### 数値処理

| SPDの記述 | Javaコード |
| --- | --- |
| 小数点以下N桁までに四捨五入 | `Tools.round(x, N)`（`jp.kwebs.tools.Tools` をインポート） |
| 整数へ四捨五入（小数点以下0桁） | `Math.round(x)` |
| 整数を小数に変換 | `(double) value` |

#### 例外処理

* `catch` 句で何もしないSPD指示がない限り、最低でもメッセージを表示する（握りつぶさない）。try-with-resources を優先する。
* `Optional` から値を取り出すときは `get()` を使わず、引数なしの `orElseThrow()` を既定とする（`## 9.4`）

#### 骨格

* 型定義（`クラス:` / `抽象クラス:` / `インタフェース:` / `レコード:`）が先頭にあるSPDは、その型を定義する（`## 9.5`）。型宣言が無いSPDは `## 9.6.7` に従い、main／クラスメソッドとして生成する（手続き型SPDは `main` メソッド内に直接書くのが基本）。
* メソッドの `static`・アクセス修飾子は SPD の記法（`## 9.6`）に従う。記法が無い場合のみ `public static` を既定とする。
* **パッケージ文（`package 〇〇;`）は自動で追加しないこと。**

#### メソッド呼び出しの扱い

SPDに `Dice.roll()` のような既存のメソッド呼び出しが書かれている場合、そのクラス／メソッドは外部で定義されている前提とする（SPDの本旨は呼び出し側の構造である）。

#### インポート処理

SPDにインポート文の明示がない場合でも、インポートすべきクラスがある場合は以下の指示および**`references/pom.xml` を必ず参照して自動挿入すること。**

1. プロジェクト固有クラス（最優先）
* `jp.kwebs.tools.Input` — キーボード入力（`## 4` 参照）
* `jp.kwebs.tools.Tools` — 丸め処理（`## 5` 参照）


2. `pom.xml` に記載された依存ライブラリから選択する
| artifactId | 代表的なインポートパッケージ | 主な用途 |
| --- | --- | --- |
| `tools` | `jp.kwebs.tools.*` | Input / Tools |
| `tkxmail` | `jp.kwebs.tkxmail.*` | メール送受信 |
| `zxing` core/javase | `com.google.zxing.*` | QRコード生成・読み取り |
| `commons-io` | `org.apache.commons.io.*` | ファイル操作ユーティリティ |


3. Java 標準ライブラリ（`java.*` / `javax.*`）

**依存ライブラリの正は、`references/pom.xml` である。** 上の表は代表例であり、`pom.xml` と食い違う場合は `pom.xml` を優先する。

**pom.xml に存在しないライブラリは絶対に追加しないこと。** 必要な場合はユーザーに確認すること。
