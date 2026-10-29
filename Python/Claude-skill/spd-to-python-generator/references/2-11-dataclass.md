### 2.11 データクラス

#### 2.11.1 データクラスの定義

```
データクラス: Person
│
├─目的：個人を表すクラス
└─属性
      ├─氏名: name: str
      └─年齢: age: int
```

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Person:
    """個人を表すクラス。"""

    name: str
    age: int
```

#### 2.11.2 属性値の検査（バリデーション）

```
データクラス: Person
│
├─目的：個人を表すクラス
├─属性
│    ├─氏名: name: str
│    └─年齢: age: int
│
└─メソッド: __post_init__
    │
    ├─目的: age のバリデーション
    ├─引数: なし
    ├─戻り値: なし
    └─処理
          └─◇─ ageは負
                      └─ ValueError( "年齢は負にできません")　を発生させる
```

```python
from dataclasses import dataclass


@dataclass(frozen=True)
class Person:
    """個人を表すクラス。"""

    name: str
    age: int

    def __post_init__(self) -> None:
        """ageのバリデーション。"""
        if self.age < 0:
            raise ValueError("年齢は負にできません")
```
