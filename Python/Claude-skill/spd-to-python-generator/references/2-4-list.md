### 2.4 リストの操作

#### 2.4.1 2次元リストを扱うリスト内包表記

```
体重と身長のリストをBMIのリストに変換する
│
├─変数dataに[[65.5, 172.8],[50.8, 158.2],[75.7, 178.3]]を代入する
├─リスト内包表記で新しいリストbmiを作成する
│    ├─for: weight, height ← data  ※アンパック
│    └─変換: weight / (height / 100) ** 2
└─bmiを表示する
```

```python
data = [[65.5, 172.8], [50.8, 158.2], [75.7, 178.3]]

bmi = [weight / (height / 100) ** 2 for weight, height in data]  # アンパック

print(bmi)
```

#### 2.4.2 インデックスを付けるenumerate関数

```
項番付きで表示する
│
├─リストを用意する─animals←["dog", "cat", "rabbit"]
│
└─要素をインデックス付きで表示する
                  │
                  └─↻─for: i, animal← enumerate(animals)
                      └─iとanimalを並べて表示する
```

```python
animals = ["dog", "cat", "rabbit"]

# 要素をインデックス付きで表示する
for i, animal in enumerate(animals):
    print(i, animal)
```

#### 2.4.3 複数のリストを合併するzip関数

```
名前のリストと身長のリストを並べて表示する
│
├─名前のリストと身長のリストを用意する
│    ├─names←[ "田中", "佐藤", "山田"]
│    └─heights←[175.3, 163.5, 182.1]
│
└─名前と身長を並べて表示する─↻─ for: name, height← zip(names, heights)
                                     └─nameとheightを並べて表示する
```

```python
names = ["田中", "佐藤", "山田"]
heights = [175.3, 163.5, 182.1]

# 名前と身長を並べて表示する
for name, height in zip(names, heights):
    print(name, height)
```
