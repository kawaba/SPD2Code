### 2.6 関数

#### 2.6.1 関数の定義と使用例

```
関数: score
│
├─目的：3 科目のテストの合計と平均を計算する
├─引数
│    ├─math：数学のテストの点数
│    ├─science ：理科のテストの点数
│    └─english ：英語のテストの点数
│
├─戻り値：合計と平均のタプル
│
└─処理
    ├─合計を計算して変数total に代入する
    ├─平均を計算して小数点以下1 桁までに丸めて、変数average に代入する
    └─totalとaverageをタプルにして返す

関数の使用例
│
├─score(80, 70, 60) を実行して、戻り値を変数total とaverage に代入する
└─合計(total) と平均(average) を、"合計= 〇〇、平均= 〇〇. 〇" の形式で表示する
```

```python
def score(math, science, english):
    """3科目のテストの合計と平均を計算します。"""
    total = math + science + english
    average = round(total / 3, 1)
    return total, average


total, average = score(80, 70, 60)
print(f"合計= {total}、平均= {average:.1f}")
```

#### 2.6.2 main関数

`関数: main` があるときだけ `main()` と実行エントリを生成する。

```
関数: main
  │
  ├─目的：3 科目の点数から合計と平均を求めて表示する
  ├─引数: なし
  ├─戻り値: なし
  │
  └─処理
        ├─数学・理科・英語の点数をキーボードから入力する
        ├─score() を呼び出して、戻り値を変数total とaverage に代入する
        └─合計(total) と平均(average) を、 "合計= 〇〇、平均= 〇〇. 〇" の形式で表示する
```

```python
def main():
    """3科目の点数から合計と平均を求めて表示します。"""
    math = int(input("数学> "))
    science = int(input("理科> "))
    english = int(input("英語> "))
    total, average = score(math, science, english)
    print(f"合計= {total}、平均= {average:.1f}")


if __name__ == "__main__":
    main()
```

`main` は引数も戻り値もないので、`目的`・`引数`・`戻り値` の枝を省略してよい。
省略形でも生成するコードは上と同じで、docstringは `処理` の内容から作る。

```
※main　関数の省略形
関数: main
  │
  └─処理
        ├─数学・理科・英語の点数をキーボードから入力する
        ├─score() を呼び出して、戻り値を変数total とaverage に代入する
        └─合計(total) と平均(average) を、 "合計= 〇〇、平均= 〇〇. 〇" の形式で表示する
```
