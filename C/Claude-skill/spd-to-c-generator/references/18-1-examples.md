### 18.1 変換例

#### 配列の集計

**SPD**

```
配列の要素を集計する
  │
  ├─整数の配列を作成して、変数array に代入する
  │        └─array ← {10, 20, 30}
  ├─合計を入れる変数int total を宣言してゼロを代入する
  │
  ├─↻─ for: ループ変数をi としてarray の要素の数だけ繰り返す
  │  │
  │  └─array[i]をtotal に加算する
  │
  ├─平均を計算して変数double averageに代入する
  │    └─total をdoubleに変換し、配列array の要素数で割る
  │
  ├─合計を "合計= 〇〇" の書式でコンソールに表示する
  └─平均を "平均= 〇〇. 〇" の書式で小数点以下１桁まで表示する
```

**生成Cコード**

（SPDは分割せず、`#include` 群の直後に1つのブロックコメントとしてそのまま残す）

```c
#include <stdio.h>

#define ARRAY_LEN(array) (sizeof(array) / sizeof((array)[0]))

/*
配列の要素を集計する
  │
  ├─整数の配列を作成して、変数array に代入する
  │        └─array ← {10, 20, 30}
  ├─合計を入れる変数int total を宣言してゼロを代入する
  │
  ├─↻─ for: ループ変数をi としてarray の要素の数だけ繰り返す
  │  │
  │  └─array[i]をtotal に加算する
  │
  ├─平均を計算して変数double averageに代入する
  │    └─total をdoubleに変換し、配列array の要素数で割る
  │
  ├─合計を "合計= 〇〇" の書式でコンソールに表示する
  └─平均を "平均= 〇〇. 〇" の書式で小数点以下１桁まで表示する
*/
int main(void) {
    int array[] = {10, 20, 30};

    int total = 0;

    for (int i = 0; i < ARRAY_LEN(array); i++) {
        int n = array[i];
        total += n;
    }

    double average = (double)total / ARRAY_LEN(array);

    printf("合計=%d\n", total);
    printf("平均=%.1f\n", average);

    return 0;
}
```

> ↑のように、SPDは**丸ごと1ブロック**で残す。決して各行を `for` や `printf` の直前にばらして配置しない。

#### ファイル処理

**SPD**

```
行単位のファイル読み込み
  │
  ├─fruit.txt を読み込み用に開き、変数fileに代入する
  ├─◇─ file はNULLである
  │        └─ "ファイル入力エラー" を表示して1 を返して終了する
  │
  ├─行データを入れる変数line char[1000] を宣言する
  ├─↻─ while: fileから1 行分をlineに読み込み、成功している間繰り返す
  │  │
  │  └─ line をコンソールに表示する
  │
  │
  └─file　を閉じる
```

**生成Cコード**

```c
#include <stdio.h>

int main(void) {
    FILE *file = fopen("fruit.txt", "r");
    if (file == NULL) {
        fprintf(stderr, "ファイル入力エラー\n");
        return 1;
    }

    char line[1000];
    while (fgets(line, sizeof(line), file) != NULL) {
        printf("%s", line);
    }

    fclose(file);
    return 0;
}
```
