### 2.9 クラスの定義

移譲メソッドの自動生成を除く、クラスの構成要素をすべて含む例である。
クラス宣言部と属性は省略できない。属性がない場合は `属性：なし` と書く。それ以外は必要な構成要素だけを書く。

```
クラス: Member
│
├─目的：会員を表すクラス
├─属性
│    ├─番号：uid: int
│    ├─名前：name: str
│    └─年齢：_age: int   ※ _を付けているので仮想属性age を作成することを意味する
│
├─特殊メソッド  ※自動生成される
│    │
│    ├─コンストラクタ         ※__init__の引数はuid 、name、age となる。age は仮想属性
│    ├─表示メソッド          ※__str__ と__repr__を生成する
│    └─等値メソッド <- uid   ※__eq__と__hash__はuid で比較する
│
├─メソッド：age  ※セッターなので@age.setter が付く
│    │
│    ├─目的：age のセッター
│    ├─引数
│    │    └─年齢：age_value: int
│    │
│    ├─戻り値：なし
│    └─処理
│          ├─◇─age_value は負である
│          │          └─ValueError("年齢は0 以上" ）を発生する
│          │
│          └─_ageにage_value を代入する
│
├─メソッド: membership_fee
│    │
│    ├─目的: 会費額を返す
│    ├─引数: なし
│    ├─戻り値: 会費 -> int
│    │
│    └─処理
│        └─ FEEを返す
│
├─クラス変数
│      └─会費: FEE: int = 5000
│
├─クラスメソッド: from_csv
│      │※メソッド宣言に@classmethodデコレーターが付く
│      │※属性にアクセスでき、第１引数はclsである
│      │※この例は、代替コンストラクタの作成例
│      │
│      ├─目的: CSV 文字列からインスタンスを作って返す
│      ├─引数
│      │    └─CSV 文字列: csv: str
│      │
│      ├─戻り値: Memberインスタンス -> Member
│      │
│      └─処理
│          ├─csv をコンマで区切ってリストdtを作る
│          ├─dtから番号（w_uid ）、氏名（w_name）、年齢（w_age ）を取り出す
│          │      │
│          │      └─〇─try
│          │          │  ├─要素を変数に取り出す─w_uid, w_name, w_age ← dt
│          │          │  ├─w_uid を整数化してw_uid に再代入する
│          │          │  └─w_age を整数化してw_age に再代入する
│          │          │
│          │          〇─except Exception as e:
│          │              └─ValueError("csv が不正")を発生させる
│          │
│          │    ※インスタンス生成には cls(...) を使う
│          └─w_uid 、w_name、w_age からインスタンスを作って返す
│
└─スタティックメソッド: is_adult
      │※メソッド宣言に@staticmethodデコレーターが付く
      │※クラスと概念的に強く結びついているが、インスタンスの状態は不要な場合に作る
      │※属性にアクセスできず、引数にclsをとらない
      │※Member.is_adult(20) のようにクラス名を付けて呼び出す
      │
      ├─目的: 年齢が18歳以上（成人）かどうかを判定する
      ├─引数
      │    └─年齢: age: int
      │
      ├─戻り値: 成人かどうか -> bool
      │
      └─処理
          └─ ageが18以上かどうか（age >= 18）を判定して返す
```

```python
class Member:
    """会員を表すクラス。"""

    # 会費
    FEE = 5000

    # __init__の引数はuid、name、ageとなる。ageは仮想属性
    def __init__(self, uid: int, name: str, age: int) -> None:
        self.uid = uid
        self.name = name
        self._age = age

    # __str__と__repr__を生成する
    def __str__(self) -> str:
        return f"Member({self.uid}, {self.name}, {self._age})"

    def __repr__(self) -> str:
        return (f"Member(uid={self.uid!r}, name={self.name!r}, "
                f"age={self._age!r})")

    # __eq__と__hash__はuidで比較する
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Member):
            return NotImplemented
        return self.uid == other.uid

    def __hash__(self) -> int:
        return hash(self.uid)

    # _を付けているので仮想属性ageを作成することを意味する
    @property
    def age(self) -> int:
        """年齢を返します。"""
        return self._age

    # セッターなので@age.setterが付く
    @age.setter
    def age(self, age_value: int) -> None:
        """ageのセッター。"""
        if age_value < 0:
            raise ValueError("年齢は0以上")
        self._age = age_value

    def membership_fee(self) -> int:
        """会費額を返します。"""
        return Member.FEE

    # メソッド宣言に@classmethodデコレーターが付く
    # 属性にアクセスでき、第1引数はclsである
    # この例は、代替コンストラクタの作成例
    @classmethod
    def from_csv(cls, csv: str) -> "Member":
        """CSV文字列からインスタンスを作って返します。"""
        dt = csv.split(",")
        try:
            w_uid, w_name, w_age = dt
            w_uid = int(w_uid)
            w_age = int(w_age)
        except Exception as error:
            raise ValueError("csvが不正")
        # インスタンス生成には cls(...) を使う
        return cls(w_uid, w_name, w_age)

    # メソッド宣言に@staticmethodデコレーターが付く
    # クラスと概念的に強く結びついているが、インスタンスの状態は不要な場合に作る
    # 属性にアクセスできず、引数にclsをとらない
    # Member.is_adult(20) のようにクラス名を付けて呼び出す
    @staticmethod
    def is_adult(age: int) -> bool:
        """年齢が18歳以上（成人）かどうかを判定します。"""
        return age >= 18
```
