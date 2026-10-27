## 30.6 レイアウトの共通化

`レイアウト：layout/base` と書かれた場合、`templates/layout/base.html` の
フラグメントを使う形で生成する。

**レイアウト側（`layout/base.html`）**

```html
<!doctype html>
<html xmlns:th="http://www.thymeleaf.org" lang="ja" th:fragment="page(title, content)">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title th:replace="${title}">タイトル</title>
</head>
<body>
  <header>
    <a th:href="@{/}">ホーム</a>
  </header>
  <main th:replace="${content}"></main>
</body>
</html>
```

**画面側**

```html
<!doctype html>
<html xmlns:th="http://www.thymeleaf.org" lang="ja"
      th:replace="~{layout/base :: page(~{::title}, ~{::main})}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>会員一覧</title>
</head>
<body>
  <main>
    <!-- ここに「構成」の内容を置く -->
  </main>
</body>
</html>
```

- **`レイアウト：なし` の場合**（`レイアウト` の行が無い場合も含む。`## 30.2`）は、フラグメントを使わず、`<head>`・`<body>` を持つ
  完全なHTMLとして生成する。`構成` の内容は `<body>` の直下に置く。
- レイアウトを使う画面の `css` は生成しない（`## 30.2`）。CSS はレイアウト側の `<head>` に書く。
- レイアウトファイルそのものを生成するのは、SPDに `テンプレート：layout/base` が
  与えられた場合だけである。**存在しないレイアウトを勝手に作ってはならない。**
  参照先が見つからない場合は `## 0.8` の報告の【見つからない名前】に載せること。

