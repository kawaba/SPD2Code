#### 例外処理（`〇`）

##### パターンA：try / catch
```
├─〇─try
│  │  └─ 通常処理
│  〇─catch: 例外型
│        └─ 例外時の処理
```

```java
try {
    通常処理;
} catch (例外型 e) {
    例外時の処理;
}
```

##### パターンB：try-with-resources

`try:` の右にリソース取得式が書かれている場合は try-with-resources にする。
```
├─〇─try: var in = Files.newBufferedReader(path) によりファイルを開く
│  │  └─ 通常処理
│  〇─catch: IOException
│        └─ エラー処理
```

```java
try (var in = Files.newBufferedReader(path)) {
    通常処理;
} catch (IOException e) {
    エラー処理;
}
```

##### パターンC：例外を投げる（`…を投げる`）

`（例外型）を投げる` は `throw new （例外型）(…);` を生成する。
コンストラクタの引数は、その `└─` の子ノードから決める。

| 子ノードの書き方 | 生成する引数 |
|---|---|
| （子ノードなし） | 引数なし（`throw new XxxException();`） |
| 「エラーメッセージは … とする」 | 第1引数（メッセージ） |
| 「原因は … とする」 | 第2引数（`cause`） |

```
├─◇─count は負である
│        └─CheckedNumberExceptionを投げる
│              └─エラーメッセージは "不正な値" + count とする
```
```java
if (count < 0) {
    throw new CheckedNumberException("不正な値" + count);
}
```

- 例外クラスの定義は、SPDに書かれていない限り**生成しない**。ワークスペースにも見つからない場合は、
  報告の【見つからない名前】に載せる（`## 0.8`）。
- 投げた例外が**検査例外**で、それを受ける `〇─catch:` がSPD内に無い場合は、
  囲んでいるメソッドの宣言に `throws` を補う（`## 9.6.6`）。
