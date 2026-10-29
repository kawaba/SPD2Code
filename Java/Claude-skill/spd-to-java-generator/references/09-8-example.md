### 9.8 完全な変換例

与えられたSPDから、次のように**SPD全体をブロックコメントで冒頭に残したうえで**コードを生成する。

```java
import java.util.List;
import jp.kwebs.tools.Tools;

/*
リストの要素を集計する
 │
 ├─ 整数のリストを作成して、変数listに代入する
 │  └─ 要素は(10, 20, 30)
 ├─ 合計を入れる変数int totalを宣言してゼロを代入する
 ├─ ↻─ for: 変数nにlistから毎回１つずつ要素を取り出す
 │    └─ nをtotalに加算する
 ├─ 平均を計算して変数double aveに代入する
 │  └─ 平均は、doubleに変換したtotalをlistの要素数で割り、小数点以下1桁までに四捨五入する
 ├─ 合計を"合計＝〇〇"の書式でコンソールに表示する
 └─ 平均を"平均＝〇〇"の書式でコンソールに表示する
*/
public class ListAggregation {
    public static void main(String[] args) {
        var list = List.of(10, 20, 30);

        int total = 0;
        for (var n : list) {
            total += n;
        }

        double ave = Tools.round((double) total / list.size(), 1);

        System.out.printf("合計＝%d%n", total);
        System.out.printf("平均＝%.1f%n", ave);
    }
}
```
