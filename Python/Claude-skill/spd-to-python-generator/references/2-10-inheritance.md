### 2.10 継承

#### 2.10.1 Memberクラスを継承するGeneralMemberクラス

```
クラス: GeneralMember(Member)
│
├─目的：一般会員のクラス
├─属性
│    └─レッスンメニュー: lesson_menu: list[str]
│
└─特殊メソッド
      │
      └─コンストラクタ
```

```python
class GeneralMember(Member):
    """一般会員のクラス。"""

    def __init__(self, uid: int, name: str, age: int,
                 lesson_menu: list[str]) -> None:
        super().__init__(uid, name, age)
        self.lesson_menu = lesson_menu
```

#### 2.10.2 コンストラクタのないサブクラス

```
クラス: SeniorMember(Member)
│
├─目的：メソッドだけのクラス
├─属性：なし
├─特殊メソッド：なし
│
└─メソッド: membership_fee   ※オーバーライドメソッド
    │
    ├─目的: 会費額を返す
    ├─引数: なし
    ├─戻り値: 会費 -> int
    └─処理
          └─ FEE * 0.6　を整数に丸めた額を返す
```

```python
class SeniorMember(Member):
    """メソッドだけのクラス。"""

    # オーバーライドメソッド
    def membership_fee(self) -> int:
        """会費額を返します。"""
        return round(Member.FEE * 0.6)
```

#### 2.10.3 ミックスイン

```
クラス: JsonMixin
│
├─属性：なし
├─特殊メソッド：なし
│
└─メソッド: to_json
    │
    ├─目的: 属性をJSON形式の文字列にして返す
    ├─引数: なし
    ├─戻り値: クラス属性のJSON形式の文字列 -> str
    └─処理
          └─ return json.dumps(self.__dict__, ensure_ascii=False)

※継承を利用してJsonMixinのto_jsonメソッドを取り込む
クラス: GeneralMember(JsonMixin, Member)
│
├─目的：一般会員のクラス
├─属性
│    └─レッスンメニュー: lesson_menu: list[str]
│
└─特殊メソッド
      │
      └─コンストラクタ
```

```python
import json


class JsonMixin:
    """属性のJSON変換機能を提供するミックスイン。"""

    def to_json(self) -> str:
        """属性をJSON形式の文字列にして返します。"""
        return json.dumps(self.__dict__, ensure_ascii=False)


class GeneralMember(JsonMixin, Member):
    """一般会員のクラス。"""

    def __init__(self, uid: int, name: str, age: int,
                 lesson_menu: list[str]) -> None:
        super().__init__(uid, name, age)
        self.lesson_menu = lesson_menu
```
