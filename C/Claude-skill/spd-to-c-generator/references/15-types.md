### 15. 構造体定義のパターン

```
構造体: product
  │
  ├─型番: char number[20]
  ├─品名: char name[100]
  ├─価格: int price
  └─在庫の有無: bool stock
```

```c
typedef struct {
    char number[20];
    char name[100];
    int price;
    bool stock;
} Product;
```
文字列フィールドは、固定長の文字配列として定義する。
`bool` を使う場合は `#include <stdbool.h>` を補う。


### 16. 列挙型定義のパターン
列挙型: suit
  │
  ├─クラブ: CLUB
  ├─ダイア: DIAMOND
  ├─ハート: HEART
  └─スペード: SPADE

// 対応するＣ言語ソースコード
typedef enum {
    CLUB,
    DIAMOND,
    HEART,
    SPADE
} Suit;


### 16.5 グローバル変数定義のパターン

タイトルを「グローバル変数」とし、子項目1つにつき変数1つを **Cの宣言と同じ形**（型 変数名。配列は `[]` 付き）で書く。

```
グローバル変数
  │
  ├─static Texture2D cardTextures[DECK_SIZE] ※52枚分のカードテクスチャ
  └─int totalScore ←0
```

```c
// 52枚分のカードテクスチャ
static Texture2D cardTextures[DECK_SIZE];
int totalScore = 0;
```

生成の規則：

- `static` が付いている変数は、**ファイル内専用**（他の `.c` から見えない）として `static` 付きのまま生成する。付いていない変数には付けない。**static の有無はSPDの記述どおり**とし、生成側が勝手に変更しない。
- 初期値を指定する場合は `←` で書く（例: `int totalScore ←0`）。`←` がない場合は初期化式を付けない。
- 配置は **`#include` 群・`#define` の直後、最初の関数定義の前**とする。
- グローバル変数は `.c` ファイルに置き、**ヘッダ（`.h`）には書かない**。
- SPDにないグローバル変数を生成側が追加してはならない。逆に、SPDに書かれた変数を省略してもならない。
