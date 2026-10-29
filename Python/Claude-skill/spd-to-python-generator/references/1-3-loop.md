### 1.3 繰り返し（`↻`）

#### 1.3.1 パターンA：for

```text
└─ ↻─ for: number ← numbers
          └─ numberをコンソールに表示する
```

```python
for number in numbers:
    print(number)
```

#### 1.3.2 パターンB：while

```text
└─ ↻─ while: numberが0でない間繰り返す
          └─ 処理
```

```python
while number != 0:
    処理
```

#### 1.3.3 パターンC：無限ループ + break

```text
├─ 合計の計算─ ↻─ while: True
│                     ├─ 変数numberにキーボードから整数を入力する
│                     ├─ ◇─ numberは0である
│                     │          └─ breakでループを脱出する
│                     └─ totalにnumberを加算する
```

```python
# 合計の計算
while True:
    number = int(input("整数> "))
    if number == 0:
        break
    total += number
```
