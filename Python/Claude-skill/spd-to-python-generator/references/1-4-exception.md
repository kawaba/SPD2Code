### 1.4 例外処理（`〇`）

#### 1.4.1 パターンA：try / except

```text
└─ 〇─try:
     │   └─ 通常処理
     〇─except (OSError, UnicodeDecodeError) as e:
          └─ "ファイル入力エラー"と表示する
```

```python
try:
    通常処理
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```

SPDの `as e` は、生成コードでは `as error` とする。

#### 1.4.2 パターンB：with文を含むtry

```text
└─ 〇─try: with文で、pathの入力用ファイルオブジェクトをfile_objにセットする
     │   └─ ↻─ for: line ← file_obj
     │             └─ lineをコンソールに表示する
     〇─except (OSError, UnicodeDecodeError) as e:
          └─ "ファイル入力エラー"と表示する
```

```python
try:
    with path.open("r", encoding="utf-8") as file_obj:
        for line in file_obj:
            print(line, end="")
except (OSError, UnicodeDecodeError) as error:
    print("ファイル入力エラー")
```
