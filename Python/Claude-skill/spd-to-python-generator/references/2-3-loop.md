### 2.3 繰り返し

#### 2.3.1 for文（集計）

```
リストの要素を集計する
│
├─データの準備─整数のリストを作成して、変数numbers に代入する
│                    └─要素は(10, 20, 30)
│
├─合計の計算┬─total = 0とする
│            └─↻─for:number←numbers
│                │
│                └─numberをtotal に加算する
│
├─平均の計算─平均を計算して変数ave に代入する
│                └─平均はtotalをnumbersの要素数で割り、小数点以下1桁までに丸める
│
└─結果の表示┬─合計を"合計＝〇〇"の書式でコンソールに表示する
              └─平均を"平均＝〇〇"の書式でコンソールに表示する
```

```python
numbers = [10, 20, 30]

# 合計の計算
total = 0
for number in numbers:
    total += number

# 平均の計算
ave = round(total / len(numbers), 1)

# 結果の表示
print(f"合計＝{total}")
print(f"平均＝{ave}")
```

#### 2.3.2 for文（オブジェクトのリスト）

```
データクラス：Product
│
├─目的：製品を表すデータクラス
└─属性
      ├─製品コード：code: str
      ├─製品名：name: str
      ├─価格：price: int
      └─在庫：stock: bool

オブジェクトのリスト
│
├─データの準備─Productクラスのインスタンスを3 つ作って、リストproductsに代入する
│                      └─products ←[Product(MT890, ステンレスネジ ,280, False),
│                                      Product(MT810, タッピングネジ ,160, True ),
│                                      Product(MT900, スクリューネジ ,350, True )]
│
└─表示処理─↻─for:p←products
              │
              └─商品名（p.name）と価格（p.price ）をコロンとタブで区切って表示する
```

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Product:
    """製品を表すデータクラス。"""

    code: str
    name: str
    price: int
    stock: bool


products = [Product("MT890", "ステンレスネジ", 280, False),
            Product("MT810", "タッピングネジ", 160, True),
            Product("MT900", "スクリューネジ", 350, True)]

# 商品名と価格をコロンとタブで区切って表示する
for p in products:
    print(f"{p.name}:\t{p.price}")
```

#### 2.3.3 while文（無限ループ）

```
電卓プログラム
│
├─準備─total = 0とする
├─合計の計算─↻─while:True  ※無限ループ
│              │
│              ├─変数numberにキーボードから整数を入力する
│              ├─◇─numberは0である
│              │        └─breakでループを脱出する
│              ├─numberをコンソールに表示する
│              └─totalにnumberを加算する
│
└─結果の表示┬─終了時の区切りとして"------"を表示する
              └─"合計= 〇〇"の形式でtotal を表示する
```

```python
total = 0

# 合計の計算
while True:  # 無限ループ
    number = int(input("整数> "))
    if number == 0:
        break
    print(number)
    total += number

# 結果の表示
print("------")
print(f"合計= {total}")
```

#### 2.3.4 while文（ウォルラス演算子）

```
電卓プログラム（while 文、入力して条件判定のパターン）
│
├─変数の準備┬─total = 0とする
│            └─変数numberを用意する
│
├─合計の計算
│    └─↻─while:numberにキーボードから整数を入力し、それが0 でない間繰り返す
│        │
│        ├─numberをコンソールに表示する
│        └─totalにnumberを加算する
│
└─結果の表示┬─終了時の区切りとして"------"を表示する
              └─"合計= 〇〇"の形式でtotalを表示する
```

```python
total = 0

# 入力した整数が0でない間、合計に加算する
while (number := int(input("整数> "))) != 0:
    print(number)
    total += number

# 結果の表示
print("------")
print(f"合計= {total}")
```
