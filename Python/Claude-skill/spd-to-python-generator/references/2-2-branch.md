### 2.2 分岐

#### 2.2.1 if文

```
平方根を計算する
│
├─変数x にキーボードから整数を入力する
├─◇─xは負
│        └─x *= -1
├─x の平方根を計算して、変数value に代入する
└─value を表示する
```

```python
x = int(input("整数> "))

# 負の値は符号を反転してから平方根を計算する
if x < 0:
    x *= -1

value = x ** 0.5
print(value)
```

#### 2.2.2 if-else文

タイトル（`結果の表示`）は、生成コードの対応する位置に `#` コメントとして転記する。

```
サイコロゲーム
│
├─tkxlibからdice関数をインポートする
├─サイコロを振って（dice()）出目を変数numberに代入する
│
└─結果の表示─◇─numberは6 である
                │    └─"当たり" と表示する
                └─else
                      └─"はずれ" と表示する
```

```python
from tkxlib import dice

number = dice()

# 結果の表示
if number == 6:
    print("当たり")
else:
    print("はずれ")
```

#### 2.2.3 if-elif文

```
身長の階級（if-elif 文）
│
├─キーボードから身長（cm）を変数heightに入力する（入力プロンプトは "身長>"）
│
└─身長の階級を求める─◇─180cm 以上
                        │    └─"A"と表示する
                        ◇─170cm 以上
                        │    └─"B"と表示する
                        ◇─160cm 以上
                        │    └─"C"と表示する
                        └─else
                              └─"D"と表示する
```

```python
height = float(input("身長>"))

# 身長の階級を求める
if height >= 180:
    print("A")
elif height >= 170:
    print("B")
elif height >= 160:
    print("C")
else:
    print("D")
```
