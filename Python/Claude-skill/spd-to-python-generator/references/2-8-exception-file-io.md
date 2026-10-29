### 2.8 例外処理とファイル入出力

#### 2.8.1 テキストファイルの一括読み込み

```
テキストファイルの一括読み込み（例外処理）
│
├─入力ファイルのパスを用意する─path←fruit.txt のパス
│
└─ファイル入力処理─〇─try
                      │    ├─ファイルの全内容を一括読み出しして、変数dataに代入する
                      │    │      └─ data ← path.read_text(encoding="utf-8")
                      │    └─print でdataをコンソールに出力する
                      │
                      〇─except (OSError, UnicodeDecodeError) as e:
                            └─ "ファイル入力エラー" と表示する
```

```python
from pathlib import Path

path = Path("fruit.txt")

# ファイルの全内容を一括で読み出して表示する
try:
    data = path.read_text(encoding="utf-8")
    print(data)
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

#### 2.8.2 テキストファイルの行単位の読み込み

```
行単位のファイル読み込み（例外処理）
│
├─入力ファイルのパスを用意する─path←fruit.txt のパス
│
└─ファイル入力処理
      │
      └─〇─ try: with文で、pathを入力モードで開いてファイルオブジェクトをf にセットする
          │    └─↻─ for: line← f
          │            └─ 1行分のデータ（line）をコンソールに表示する
          │
          〇─ except (OSError, UnicodeDecodeError) as e:
                └─ "ファイル入力エラー" と表示する
```

```python
from pathlib import Path

path = Path("fruit.txt")

# ファイルを1行ずつ読み出して表示する
try:
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            print(line, end="")
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

#### 2.8.3 テキストファイルの一括出力

```
テキストファイルの一括出力（例外処理）
│
├─出力するテキストとパスを準備する┬─出力するテキストを作る
│                                  │    └─ data ← "リンゴ\nバナナ\nさくらんぼ\n"
│                                  └─path←fruit.txt のパス
│
└─ファイルへ一括出力処理─〇─try
                            │    └─テキストを一括出力する
                            │            └─ path.write_text(data, encoding="utf-8")
                            │
                            〇─except (OSError, UnicodeEncodeError) as e:
                                  └─ "ファイル出力エラー" と表示する
```

```python
from pathlib import Path

data = "リンゴ\nバナナ\nさくらんぼ\n"
path = Path("fruit.txt")

# テキストを一括で出力する
try:
    path.write_text(data, encoding="utf-8")
except (OSError, UnicodeEncodeError) as error:
    print("ファイル出力エラー")
```

#### 2.8.4 リストの一括出力

```
リストの一括出力（例外処理）
│
├─準備┬─出力するリストを用意する┬─出力するリストを作る
│      │                          │    └─data← ["apple","banana","cherry"]
│      │                          │
│      │                          └─リストの各要素に改行（\n）を付加した新しいリストを作る
│      │                                │
│      │                                └─リスト内包表記で新しいリストnew_dataを作成する
│      │                                        ├─for: item ← data
│      │                                        └─変換: item + "\n"
│      │
│      └─パスの作成─path←fruit.txt のパス
│
└─リストの一括出力処理─〇─try: with 文で、pathを出力モードで開いてファイルオブジェクトをf にセットする
                          │    │
                          │    └─リストの全要素を一括出力する─ f.writelines(new_data)
                          │
                          〇─except (OSError, UnicodeEncodeError) as e:
                                │
                                └─ "ファイル出力エラー" と表示する
```

```python
from pathlib import Path

data = ["apple", "banana", "cherry"]

# リストの各要素に改行を付加した新しいリストを作る
new_data = [item + "\n" for item in data]

path = Path("fruit.txt")

# リストの全要素を一括で出力する
try:
    with path.open("w", encoding="utf-8") as f:
        f.writelines(new_data)
except (OSError, UnicodeEncodeError) as error:
    print("ファイル出力エラー")
```

#### 2.8.5 行単位の出力

```
行単位のファイル出力（例外処理）
│
├─準備┬─出力ファイルのパスを用意する─path←”data.txt”のパス
│      └─出力する変数を用意する┬─text = "こんにちは"
│                                └─number = 123
│
└─行単位のファイル出力処理
      │
      └─〇─ try: with文で、pathを出力モードで開いてファイルオブジェクトをf にセットする
          │    │
          │    ├─f.write でtextを出力する
          │    └─f.write でnumberを文字列に変換したstr(number) を出力する
          │
          〇─ except (OSError, UnicodeEncodeError) as e:
                └─ "ファイル出力エラー" と表示する
```

```python
from pathlib import Path

path = Path("data.txt")
text = "こんにちは"
number = 123

# textとnumberを行単位で出力する
try:
    with path.open("w", encoding="utf-8") as f:
        f.write(text)
        f.write(str(number))
except (OSError, UnicodeEncodeError) as error:
    print("ファイル出力エラー")
```

#### 2.8.6 例外を発生させる

```
関数：sqrt
  │
  ├─目的：平方根を計算する
  ├─引数
  │    └─x ：平方根を求める値
  ├─戻り値：x の平方根の値
  │
  └─処理
        └─◇─xは負である
            │    └─ValueError("負の平方根は計算できません")を発生させる
            │
            └─else
                  └─x ** 0.5　の値を返す

計算処理
  │
  ├─tkxlibからget_float 関数をインポートする
  ├─キーボードからnumberに小数を入力する
  └─〇─try:
      │  ├─sqrt関数でnumberの平方根を計算して答えをresultに代入する
      │  └─resultを小数点以下1桁に丸めて "平方根＝〇〇. 〇"の形式で表示する
      │
      〇─except ValueError as e:
          └─"エラー\n" とe を表示する
```

```python
from tkxlib import get_float


def sqrt(x):
    """平方根を計算します。"""
    if x < 0:
        raise ValueError("負の平方根は計算できません")
    else:
        return x ** 0.5


number = get_float("小数> ")

try:
    result = sqrt(number)
    print(f"平方根＝{round(result, 1)}")
except ValueError as error:
    print("エラー\n", error)
```
