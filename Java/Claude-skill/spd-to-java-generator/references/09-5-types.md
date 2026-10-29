### 9.5 型定義のパターン

SPDが型定義を表す場合の規約（アクセス修飾子・継承・実装の記号は `## 9.2`）。
1つのSPDファイル内に並ぶすべてのパート（クラス宣言・各コンストラクタ・各メソッド）は、**同じ `.java` ファイル内の同じクラス**に属するものとして生成する。

##### 9.5.1 クラス定義

クラスのメンバーはすべて、クラス宣言から縦線（`│`）で連結した1本の木として書く。
```
クラス：GeneralMember          ※SPD のタイトル。クラス名を指定する
│
├─目的：一般会員を表すクラス
│
├─フィールド
│  ├─番号：int uid            ※フィールドの説明と型、フィールド変数名を書く
│  └─名前：String name
│
│※記述した項目のメンバを自動生成する（自動生成したいものだけを記述する）
├─自動生成
│  ├─コンストラクタ：引数なし
│  ├─コンストラクタ：全引数
│  ├─ゲッター
│  ├─セッター
│  ├─toString
│  ├─等値判定 ← uid            ※equals()とhashCode()の両方
│  └─移譲メソッド
│
│※必要な場合に定義する（この例はCSV 文字列から初期化するオーバーロード）
├─コンストラクタ
│    ├─引数
│    │    └─CSV 文字列：String csv
│    └─処理
│          ├─csvをカンマで区切って配列itemsに代入する
│          ├─items[0]の前後の空白を除き、intに変換してuidに代入する
│          └─items[1]の前後の空白を除いてnameに代入する
│
│※インスタンスメソッドと同義
├─メソッド：membership_fee
│  ├─目的：会費額を返す
│  ├─引数：なし
│  ├─戻り値: int 、会費の額     ※戻り値型と説明を読点で区切って書く
│  └─処理
│        └─FEE の値を返す
│
├─クラス変数：
│  └─会費額：# final int FEE = 5000
│
├─クラスメソッド: printFee
│  ├─目的：会費額をコンソールに表示する
│  ├─引数：なし
│  ├─戻り値：なし
│  └─処理
│        └─FEE を "会費=〇〇" の書式でコンソールに表示する
│
│  ※mainメソッドは、目的、引数、戻り値を省略してよい
└─クラスメソッド：main
     └─処理
          ├─（100, "田中宏" ）でインスタンスを作って変数memberに代入する
          └─memberをコンソールに表示する
```

* 先頭行 `クラス: …` がクラス宣言（修飾子省略時は `public`）。**クラス名は必須**で、他の項目はすべて省略でき、**並び順も任意**である。
* 書けるメンバーノードは6種類（`目的:` を除く）：`フィールド`／`自動生成`／`クラス変数`／`コンストラクタ`／`メソッド:`（＝`インスタンスメソッド:`）／`クラスメソッド:`（mainを含む）。記法・生成規則は `## 9.6` に従う。
* `目的`／`フィールド`／`自動生成` は1クラスに1回だけ（複数あれば不整合として指摘）。他のノードは複数定義してよい。
* `目的:` はクラス宣言の直上に1行コメント（`// …`）として記載する。
* クラス変数（`## 9.6.1`）・クラスメソッド（`## 9.6.6`）は独立SPDで定義してもよい。後続SPDに独立のメソッド／クラス変数定義が並ぶ場合は、それらを同クラスに実装する。
* 旧表記（`属性`／`自動生成のリスト`／`コンストラクタ：オーバーロード` など）は `## 9.2` の別名表どおり黙って読み替える。

上の例から生成されるコード

```java
// 一般会員を表すクラス
public class GeneralMember {
    protected static final int FEE = 5000; // 会費額

    private int uid;     // 番号
    private String name; // 名前

    // 自動生成：コンストラクタ：引数なし
    public GeneralMember() {
    }

    // 自動生成：コンストラクタ：全引数
    public GeneralMember(int uid, String name) {
        this.uid = uid;
        this.name = name;
    }

    // コンストラクタノード（CSV 文字列からの初期化）
    public GeneralMember(String csv) {
        var items = csv.split(",");
        this.uid = Integer.parseInt(items[0].trim());
        this.name = items[1].trim();
    }

    // 自動生成：ゲッター／セッター
    public int getUid() {
        return uid;
    }

    public String getName() {
        return name;
    }

    public void setUid(int uid) {
        this.uid = uid;
    }

    public void setName(String name) {
        this.name = name;
    }

    // 自動生成：toString
    @Override
    public String toString() {
        return "GeneralMember[uid=" + uid + ", name=" + name + "]";
    }

    // 自動生成：等値判定 ← uid
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof GeneralMember other)) {
            return false;
        }
        return uid == other.uid;
    }

    @Override
    public int hashCode() {
        return Objects.hash(uid);
    }

    /**
     * 会費額を返す
     * @return 会費の額
     */
    public int membership_fee() {
        return FEE;
    }

    /** 会費額をコンソールに表示する */
    public static void printFee() {
        System.out.printf("会費=%d%n", FEE);
    }

    public static void main(String[] args) {
        var member = new GeneralMember(100, "田中宏");
        System.out.println(member);
    }
}
```

> この例では自作クラス型のフィールドが無いため、`移譲メソッド` の記載があっても生成される移譲メソッドは無い（`## 9.6.8`）。

##### 9.5.2 インタフェース定義
```
インタフェース：Versionable
│
├─目的：バージョン番号を返す
│
├─抽象メソッド：version
│      ├─目的：バージョン番号を返す
│      ├─引数：なし
│      └─戻り値：String、バージョン番号
│
└─抽象メソッド：versionEx
       ├─目的：バージョン番号と説明を返す
       ├─引数：なし
       └─戻り値：String、バージョン番号と簡単な説明
```

```java
/** バージョン番号を返す */
public interface Versionable {
    /**
     * バージョン番号を返す
     * @return バージョン番号
     */
    String version();

    /**
     * バージョン番号と説明を返す
     * @return バージョン番号と簡単な説明
     */
    String versionEx();
}
```

インタフェースのメソッドは `抽象メソッド：<名前>` と書く（`## 9.6.9`）。本体のない抽象メソッドを表す。
**インタフェースでは `public abstract` が暗黙**のため、修飾子・`abstract` を書かずに生成する。
`目的:` はインタフェースのJavadocにする。抽象メソッドの `目的:` はそのメソッドのJavadocにする。
戻り値の「型、説明」は型をシグネチャに、説明を `@return` にする。

**インタフェースの継承**

```
インタフェース：DetailedVersionable ─⊳ Versionable
│
├─目的：説明付きのバージョン情報を返す
│
└─抽象メソッド：description
       ├─目的：バージョンの説明を返す
       ├─引数：なし
       └─戻り値：String、バージョンの説明
```

```java
/** 説明付きのバージョン情報を返す */
public interface DetailedVersionable extends Versionable {
    /**
     * バージョンの説明を返す
     * @return バージョンの説明
     */
    String description();
}
```

インタフェースの継承は `─⊳` で書き、`extends` として生成する。親インタフェースは
読点（`、`）または `,` で区切って複数並べてよい（`─⊳ A, B` → `extends A, B`）。
親インタフェースの抽象メソッドを、子インタフェースに書き直す必要はない。
SPDに書かれていない抽象メソッドを補ってはならない。
インタフェースに `---⊳` が書かれていた場合は、不整合として指摘する（`## 9.2`）。

##### 9.5.3 レコード定義
```
レコード: Product
│
├─ 目的: 製品レコード
└─ フィールド
      ├─ 型番: String number
      ├─ 品名: String name
      ├─ 価格: int price
      └─ 在庫の有無: boolean stock
```

```java
/** Product: 製品レコード */
public record Product(
    String number,   // 型番
    String name,     // 品名
    int price,       // 価格
    boolean stock    // 在庫の有無
) {}
```

`フィールド` の各行は `説明: 型 変数名` 形式。型と変数名でコンポーネントを定義し、説明を行末コメントにする。

##### 9.5.4 抽象クラス定義

タイトルを `抽象クラス：<クラス名>` と書くと、`public abstract class …` を生成する。
```
抽象クラス：Member
│
├─目的：会員を表すクラス
│
├─フィールド
│    ├─番号：int uid
│    └─名前：String name
│
├─自動生成
│    ├─# コンストラクタ　　※# はprotected にすることを表す
│    ├─ゲッター
│    ├─セッター
│    └─toString
│
└─抽象メソッド：kai_hi　　　※外部から利用されるのでprotected にしない
      ├─目的：会費額を返す
      ├─引数：なし
      └─戻り値：int 、会費額
```

```java
// 会員を表すクラス
public abstract class Member {
    private int uid;     // 番号
    private String name; // 名前

    // 自動生成：コンストラクタ（＝コンストラクタ：全引数）。# により protected
    protected Member(int uid, String name) {
        this.uid = uid;
        this.name = name;
    }

    /**
     * 会費額を返す
     * @return 会費額
     */
    public abstract int kai_hi();

    // 自動生成：ゲッター／セッター／toString（uid・name の分を `## 9.5.1` と同じ形で生成する）
}
```

* 書けるメンバーノードは `## 9.5.1` の6種類に `抽象メソッド:`（`## 9.6.9`）を加えた7種類。それ以外（`目的`／`フィールド`／`自動生成`／継承・実装の記号／修飾子の既定値／並び順・重複のルール）はすべて `## 9.5.1` と同じ。
* 抽象クラスのコンストラクタはサブクラスからのみ呼ばれるため、`自動生成` のコンストラクタに `#`（protected）を付けるのが定石である（`## 9.6.4`）。上の例の `# コンストラクタ` は種別なしのため `コンストラクタ：全引数` と読み替える（`## 9.2`）。
* `抽象メソッド:` は `目的／引数／戻り値` だけを持ち、**`処理` は書かない**。`クラス：`（非抽象）の定義に書かれていた場合は、不整合として指摘する。
* 抽象メソッドが1つも無くても、タイトルが `抽象クラス：` であれば `abstract` を付けて生成する。
