## 4.キーボード入力

* コンソールからのキーボード入力には、必ず `jp.kwebs.tools.Input` クラスのstaticメソッドを使用すること。
* `Scanner` や `BufferedReader` などの標準Javaクラスは使用しないこと。
* 設計の指示に 「選択肢」「メニュー」「選ぶ」「選択する」 などの記述がある場合は、自由入力として `Input.getString` を使うのではなく、`Input.getSelect` を優先して使用すること。
* インポート
```java
import jp.kwebs.tools.Input;
```


### Input クラス API リファレンス（version 1.8.3）

すべて `static`（`Input.getInt()` の形で呼ぶ）。各メソッドに**引数なし**（既定のガイド文字列を表示）と**引数あり `(String s)`**（`s` をガイド文字列として表示）の2種類がある。変換できない入力は、その型の既定値（`0`、`false`、`null` 等）を返す。

| メソッド | 戻り値 | 説明 |
| --- | --- | --- |
| `getChar()` / `getChar(s)` | `char` | 文字を入力（1文字） |
| `getByte()` / `getByte(s)` | `byte` | byte整数を入力 |
| `getShort()` / `getShort(s)` | `short` | short整数を入力 |
| `getInt()` / `getInt(s)` | `int` | 整数を入力 |
| `getLong()` / `getLong(s)` | `long` | long整数を入力 |
| `getFloat()` / `getFloat(s)` | `float` | float実数を入力 |
| `getDouble()` / `getDouble(s)` | `double` | double実数を入力 |
| `getBoolean()` / `getBoolean(s)` | `boolean` | boolean値を入力（`true` 以外はすべて `false`） |
| `getString()` / `getString(s)` | `String` | 文字列を入力。Enterキーのみで `null` を返す |
| `getStringE()` / `getStringE(s)` | `String` | 文字列を入力。Enterのみで空文字、`\0` または `\null` で `null` を返す |
| `getSelect(s)` | `String` | 選択肢をCSV文字列で指定して縦に表示し、該当する記号1文字を選択して返す（戻り値は大文字） |
| `getHex()` / `getHex(s)` | `byte` | 16進数形式でbyte値を入力 |
| `getBin()` / `getBin(s)` | `byte` | 2進数形式でbyte値を入力 |
| `getCordinate()` / `getCordinate(s)` | `double[]` | 座標を入力（例: `"12.3 45.6"`）。`[x, y]` の配列を返す。解釈できない場合は再入力を促す |

### 使用例

```java
import jp.kwebs.tools.Input;

int age = Input.getInt();                                // 既定のガイド文字列
String name = Input.getString("名前を入力してください: "); // Enterのみなら null
double height = Input.getDouble("身長(cm): ");
String memo = Input.getStringE("任意入力: ");             // Enterのみなら空文字
String answer = Input.getSelect("Y:続ける, N:終了する");   // 戻り値は大文字1文字
double[] pos = Input.getCordinate("座標(x y): ");         // pos[0]=x, pos[1]=y
```
