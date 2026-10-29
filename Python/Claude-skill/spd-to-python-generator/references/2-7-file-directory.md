### 2.7 ファイルとディレクトリの操作

#### 2.7.1 パスの結合

```
 2つのパスを結合する
│
├─ベースパスの作成──"c:/python" をパスオブジェクトにしてpathに入れる
├─ファイル名を得る──キーボードから入力したファイル名をfname に入れる
├─ベースパスとファイル名を結合してpathに入れる
└─pathを表示する
```

```python
from pathlib import Path

# ベースパスの作成
path = Path("c:/python")

# ファイル名を得る
fname = input("ファイル名> ")

path = path / fname
print(path.as_posix())
```

#### 2.7.2 再帰的にすべてのファイル名を取り出す

```
指定したディレクトリから再帰的にすべてのファイル名を取り出して表示する
│
├─"c:/python/workspace" のパスをpathに入れる
└─↻─for:p←pathの中の全てのパス
    │
    └─◇─pはファイルである
                └─ファイル名を表示する
```

```python
from pathlib import Path

path = Path("c:/python/workspace")

# 再帰的にすべてのパスをたどり、ファイルの名前だけを表示する
for p in path.rglob("*"):
    if p.is_file():
        print(p.name)
```
