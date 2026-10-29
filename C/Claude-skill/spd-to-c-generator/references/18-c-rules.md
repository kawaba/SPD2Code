### 18. Cコード生成規約（SPD固有）

#### 骨格

- 関数として明示されていないSPDは `main` 関数に直接記述する。
- SPDにない関数分割をしない。
- `main` の基本形は `int main(void)` とする。

#### 命名と型

- SPDで `int total` のように型が明示されている場合は、その型を使用する。
- SPDで型が省略されている場合は、Cとして自然な型を補う。
- Javaの `var` はCでは使わない。
- 文字列は基本的に固定長の `char` 配列で扱う。

#### 入出力（SPDの記述とCコードの対応）

| SPDの記述 | Cコード |
|---|---|
| キーボードから整数を入力 | `getInt(NULL)` または `getInt("プロンプト")` |
| キーボードから実数を入力 | `getDouble(NULL)` または `getDouble("プロンプト")` |
| キーボードから文字列を入力 | `getString(buffer, sizeof(buffer), NULL)` |
| 整数配列を一括入力 | `getIntArray(array, ARRAY_LEN(array), NULL)` |
| 実数配列を一括入力 | `getDoubleArray(array, ARRAY_LEN(array), NULL)` |
| 文字列配列を一括入力 | `getStringArray(array, count, size, NULL)` |
| 座標を入力 | `getCoordinate(&x, &y, NULL)` |
| コンソールに表示 | `printf(...)` |
| `"合計=〇〇"` の形式で表示 | `printf("合計=%d\n", total)` など |
| コロンとタブで区切って表示 | `printf("%s:\t%d\n", name, price)` など |

#### 配列

- Javaの「リスト」は、C版SPDでは原則として「配列」と記述する。
- 固定長配列の要素数は `ARRAY_LEN` マクロを使う（セクション6参照）。

#### ファイルI/O

C版SPDでは例外処理を使わない。ファイルオープン失敗などは `◇` による分岐としてSPDに明示する。

| SPDの記述 | Cコード |
|---|---|
| ファイルを読み込み用に開く | `FILE *file = fopen("fruit.txt", "r");` |
| ファイルを開けなかった場合 | `if (file == NULL) { ... }` |
| 1行読み込む | `fgets(line, sizeof(line), file)` |
| ファイルへ書き込む | `fprintf(file, "...", ...)` |
| ファイルを閉じる | `fclose(file);` |

失敗しうる処理を扱う場合は、エラー対策をSPDに `◇` として書く。

#### 数値処理

| SPDの記述 | Cコード |
|---|---|
| 平方根を計算 | `sqrt(x)` |
| 小数点以下N桁までに四捨五入 | `round(x * scale) / scale` |
| 整数へ四捨五入 | `round(x)` |
| 整数を小数に変換 | `(double)value` |

`sqrt` や `round` を使う場合は `#include <math.h>` を補う。
