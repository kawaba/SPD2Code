### 8. 利用可能な外部ライブラリ

学習環境では以下の外部ライブラリが使用できる。
要件定義や仕様書作成の際、これらの利用が適切な場面では積極的に採用すること。

#### CP932（MS932）からUTF-8への変換

- コマンドプロンプトからの入力文字列は CP932（MS932）エンコードになる。
- utf8proc に渡す前に、必ず `cp932_to_utf8` 関数で UTF-8 に変換すること。
- `cp932_to_utf8` は `utils.h` に定義済み。

```c
char input[256];
getString(input, sizeof(input), "入力: ");

char utf8[256];
cp932_to_utf8(input, utf8, sizeof(utf8));
// 以降は utf8 を utf8proc に渡す
```

#### utf8proc（UTF-8文字列処理）

- ヘッダ: `#include "utf8proc.h"`
- コンパイル時は必ず `-DUTF8PROC_STATIC` が付く（ビルドタスクに設定済み）。ソースで `#define UTF8PROC_STATIC` は不要。
- 主な用途: UTF-8文字列の正規化・文字種判定・コードポイント列挙など

代表的な関数:

```c
// 文字列を NFC 正規化して新しいバッファに返す（呼び出し側で free する）
utf8proc_uint8_t *utf8proc_NFC(const utf8proc_uint8_t *str);

// 文字列全体を小文字（Case fold）に変換して返す
utf8proc_uint8_t *utf8proc_NFKC_Casefold(const utf8proc_uint8_t *str);

// 1コードポイントをデコードし、読み進めたバイト数を返す
utf8proc_ssize_t utf8proc_iterate(const utf8proc_uint8_t *str,
                                  utf8proc_ssize_t strlen,
                                  utf8proc_int32_t *dst);

// コードポイントのカテゴリ情報を返す
const utf8proc_property_t *utf8proc_get_property(utf8proc_int32_t codepoint);

// コードポイントが英字か判定
int utf8proc_isalpha(utf8proc_int32_t codepoint);

// コードポイントが数字か判定
int utf8proc_isdigit(utf8proc_int32_t codepoint);

// ライブラリバージョン文字列を返す
const char *utf8proc_version(void);
```

使用例（コードポイント列挙）:

```c
#include "utf8proc.h"

const utf8proc_uint8_t *p = (const utf8proc_uint8_t *)"こんにちは";
utf8proc_int32_t cp;
utf8proc_ssize_t bytes;
while (*p) {
    bytes = utf8proc_iterate(p, -1, &cp);
    if (bytes <= 0) break;
    printf("U+%04X\n", cp);
    p += bytes;
}
```

#### raylib（グラフィックス）

- ヘッダ: `#include "raylib.h"`
- ビルドタスク「raylib付き」を使う。
