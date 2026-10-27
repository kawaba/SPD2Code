## 30.9 完全な変換例

### 与えられたSPD

```
テンプレート：member/list
│
├─目的：会員の一覧を表示する
├─レイアウト：なし
├─タイトル：会員一覧
├─css：css/style.css
│
├─受け取り
│  ├─会員リスト：List<Member> memberList
│  └─メッセージ：String message　※任意
│
└─構成
     ├─［見出し］会員一覧
     ├─［条件表示］messageがある
     │  └─［通知］{message}
     ├─［条件表示］memberListが空である
     │  └─［段落］会員が登録されていません。
     ├─［表（列）］memberListの各要素をmとする
     │  ├─番号：{m.id}
     │  ├─名前：{m.name}
     │  ├─入会日：{m.joinedOn} <<"yyyy年MM月dd日">>
     │  └─操作：
     │        ├─［リンク］編集 → /members/{m.id}/edit
     │        ├─［文字］|
     │        └─［フォーム］→ POST /members/{m.id}/delete
     │              └─削除＜submit＞
     └─［リンク］新規登録 → /members/new
```

### 生成されるテンプレート

```html
<!--/*
テンプレート：member/list
│
├─目的：会員の一覧を表示する
├─レイアウト：なし
├─タイトル：会員一覧
├─css：css/style.css
│
├─受け取り
│  ├─会員リスト：List<Member> memberList
│  └─メッセージ：String message　※任意
│
└─構成
     ├─［見出し］会員一覧
     ├─［条件表示］messageがある
     │  └─［通知］{message}
     ├─［条件表示］memberListが空である
     │  └─［段落］会員が登録されていません。
     ├─［表（列）］memberListの各要素をmとする
     │  ├─番号：{m.id}
     │  ├─名前：{m.name}
     │  ├─入会日：{m.joinedOn} <<"yyyy年MM月dd日">>
     │  └─操作：
     │        ├─［リンク］編集 → /members/{m.id}/edit
     │        ├─［文字］|
     │        └─［フォーム］→ POST /members/{m.id}/delete
     │              └─削除＜submit＞
     └─［リンク］新規登録 → /members/new
*/-->
<!doctype html>
<html xmlns:th="http://www.thymeleaf.org" lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" th:href="@{/css/style.css}">
  <title>会員一覧</title>
</head>
<body>
  <h1>会員一覧</h1>

  <div class="message" th:if="${message}" th:text="${message}">通知</div>

  <p th:if="${#lists.isEmpty(memberList)}">会員が登録されていません。</p>

  <table>
    <thead>
      <tr>
        <th>番号</th>
        <th>名前</th>
        <th>入会日</th>
        <th>操作</th>
      </tr>
    </thead>
    <tbody>
      <tr th:each="m : ${memberList}">
        <td th:text="${m.id}">1</td>
        <td th:text="${m.name}">名前</td>
        <td th:text="${m.joinedOn == null ? '' : #temporals.format(m.joinedOn, 'yyyy年MM月dd日')}">2026年01月01日</td>
        <td>
          <a th:href="@{/members/{id}/edit(id=${m.id})}">編集</a>
          |
          <form th:action="@{/members/{id}/delete(id=${m.id})}" method="post">
            <button type="submit">削除</button>
          </form>
        </td>
      </tr>
    </tbody>
  </table>

  <a th:href="@{/members/new}">新規登録</a>
</body>
</html>
```

