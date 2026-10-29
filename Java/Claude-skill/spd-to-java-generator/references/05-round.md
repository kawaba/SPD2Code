## 5. 四捨五入（丸め処理）

* 小数点以下の桁数を指定して四捨五入する場合は、`jp.kwebs.tools.Tools` クラスの `round` メソッドを使用すること。
* 整数へ四捨五入する場合（小数点以下0桁）は、標準クラスの `Math.round()` を使用すること。
* `Tools.round` の代わりに `Math.round`・`BigDecimal`・`String.format` による丸めを使わないこと。
```java
import jp.kwebs.tools.Tools;

// static double Tools.round(double value, int digits) … value を小数点以下 digits 桁で四捨五入
double result = Tools.round(3.14159, 2);  // → 3.14
double tax    = Tools.round(price * 0.1, 1);

// 整数への四捨五入は標準クラスを使う
long rounded = Math.round(3.7);       // → 4
int n        = (int) Math.round(3.7); // → 4
```
