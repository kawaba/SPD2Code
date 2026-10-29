### 2.5 辞書の操作

#### 2.5.1 辞書のキーと値を表示する

`for: key ← score` はキーだけを取り出し、`for: key, value ← score.items()` はキーと値の両方を取り出す。

```
辞書のキーと値を表示する
│
├─変数score に成績を表す辞書を代入する
│      └─score←{"id": 1201, "English": 90, "Math": 85, "Language": 92}
│
└─scoreのすべてのキーと値を表示する
      └─↻─for: key, value ← score.items()
          │
          └─キーと値をコロン（:）で区切って表示する
```

```python
score = {"id": 1201, "English": 90, "Math": 85, "Language": 92}

# scoreのすべてのキーと値をコロンで区切って表示する
for key, value in score.items():
    print(f"{key}:{value}")
```

#### 2.5.2 辞書のリストから要素を検索する

```
ユーザーのリストから特定のユーザーを検索する
│
├─ユーザーのリストを作成する:
│  └─users = [
│              {"id": 103, "name": "tanaka", "role": "admin"},
│              {"id": 105, "name": "sasaki", "role": "user"},
│              {"id": 100, "name": "maeda", "role": "user"}, ]
│
└─sasakiを検索して表示する:
      └─↻─for: user ← users
          │
          └─◇─userの名前（name）はsasakiである
                    ├─printでuserのid, name, roleを並べて表示する
                    └─breakでループを抜ける
```

```python
users = [
    {"id": 103, "name": "tanaka", "role": "admin"},
    {"id": 105, "name": "sasaki", "role": "user"},
    {"id": 100, "name": "maeda", "role": "user"},
]

# sasakiを検索して表示する
for user in users:
    if user["name"] == "sasaki":
        print(user["id"], user["name"], user["role"])
        break
```

#### 2.5.3 辞書の並べ替え

```
辞書のリストのソート
│
├─ユーザー辞書のリストを作成する
│      └─users = [
│            {"id": 103, "name": "tanaka", "role": "admin"},
│            {"id": 105, "name": "sasaki", "role": "user"},
│            {"id": 100, "name": "maeda", "role": "user"}, ]
│
├─ユーザー辞書のリストusersを、"id"の降順にソートする
│
└─リストの全要素を表示する─↻─for: user←users
                              │
                              └─userをprintで表示する
```

```python
users = [
    {"id": 103, "name": "tanaka", "role": "admin"},
    {"id": 105, "name": "sasaki", "role": "user"},
    {"id": 100, "name": "maeda", "role": "user"},
]

users.sort(key=lambda user: user["id"], reverse=True)

# リストの全要素を表示する
for user in users:
    print(user)
```
