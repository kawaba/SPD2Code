## 20.9 完全な変換例

### 与えられたSPD

```
エンティティ：Member
├─目的：会員を表すエンティティ
├─テーブル：members
├─フィールド
│  ├─番号：@主キー @自動採番 Long id
│  └─名前：@必須 @桁数(20) String name
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター

フォーム：MemberForm
├─目的：会員登録画面の入力項目
├─フィールド
│  └─名前：String name　＠必須、20文字以内
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター

リポジトリ：MemberRepository
├─目的：会員の永続化を行う
├─対象：Member
├─主キー：Long
└─検索メソッド：なし

サービス：MemberService
├─目的：会員に関する業務処理を行う
├─インジェクション
│  └─会員リポジトリ：MemberRepository memberRepository
├─メソッド：findAll
│  ├─目的：全会員を取得する
│  ├─トランザクション：参照のみ
│  ├─引数：なし
│  ├─戻り値：List<Member>、全会員のリスト
│  └─処理
│        └─memberRepositoryのfindAllの結果を返す
└─メソッド：create
     ├─目的：会員を登録する
     ├─トランザクション：更新あり
     ├─引数
     │    └─入力フォーム：MemberForm form
     ├─戻り値：なし
     └─処理
           ├─Memberのインスタンスを作って変数memberに代入する
           ├─formのnameをmemberのnameに設定する
           └─memberRepositoryのsaveをmemberを引数にして呼び出す

コントローラー：MemberController
├─目的：会員の一覧・登録を扱う
├─ベースパス：/members
├─インジェクション
│  └─会員サービス：MemberService memberService
├─メソッド：list
│  ├─目的：会員の一覧を表示する
│  ├─マッピング：GET
│  ├─引数
│  │    └─モデル：Model model
│  ├─戻り値：String、表示するテンプレート名
│  └─処理
│        ├─memberServiceを使って、全件を読み出した結果をmemberListとしてテンプレートに渡す
│        └─"member/list"を返す
└─メソッド：create
     ├─目的：入力された会員を登録する
     ├─マッピング：POST
     ├─引数
     │    └─入力内容：@検証 MemberForm memberForm
     ├─戻り値：String、表示するテンプレート名またはリダイレクト先
     └─処理
           ├─◇─resultにエラーがある
           │  └─"member/form"を返す
           ├─memberServiceを使って、memberFormから会員を登録する
           ├─"登録しました"をフラッシュメッセージとして渡す
           └─ベースパスにリダイレクトする
```

### 生成されるコード

**Member.java**

```java
package com.example.app.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/*
エンティティ：Member
├─目的：会員を表すエンティティ
├─テーブル：members
├─フィールド
│  ├─番号：@主キー @自動採番 Long id
│  └─名前：@必須 @桁数(20) String name
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター
*/

// 会員を表すエンティティ
@Entity
@Table(name = "members")
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id; // 番号

    @Column(nullable = false, length = 20)
    private String name; // 名前

    // 自動生成：コンストラクタ：引数なし
    public Member() {
    }

    // 自動生成：ゲッター
    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    // 自動生成：セッター
    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

**MemberService.java**

```java
package com.example.app.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.app.entity.Member;
import com.example.app.form.MemberForm;
import com.example.app.repository.MemberRepository;

/*
サービス：MemberService
├─目的：会員に関する業務処理を行う
├─インジェクション
│  └─会員リポジトリ：MemberRepository memberRepository
├─メソッド：findAll
│  ├─目的：全会員を取得する
│  ├─トランザクション：参照のみ
│  ├─引数：なし
│  ├─戻り値：List<Member>、全会員のリスト
│  └─処理
│        └─memberRepositoryのfindAllの結果を返す
└─メソッド：create
     ├─目的：会員を登録する
     ├─トランザクション：更新あり
     ├─引数
     │    └─入力フォーム：MemberForm form
     ├─戻り値：なし
     └─処理
           ├─Memberのインスタンスを作って変数memberに代入する
           ├─formのnameをmemberのnameに設定する
           └─memberRepositoryのsaveをmemberを引数にして呼び出す
*/

// 会員に関する業務処理を行う
@Service
public class MemberService {

    private final MemberRepository memberRepository; // 会員リポジトリ

    public MemberService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    /**
     * 全会員を取得する
     *
     * @return 全会員のリスト
     */
    @Transactional(readOnly = true)
    public List<Member> findAll() {
        return memberRepository.findAll();
    }

    /**
     * 会員を登録する
     *
     * @param form 入力フォーム
     */
    @Transactional
    public void create(MemberForm form) {
        var member = new Member();
        member.setName(form.getName());
        memberRepository.save(member);
    }
}
```

**MemberController.java**

```java
package com.example.app.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.app.form.MemberForm;
import com.example.app.service.MemberService;

import jakarta.validation.Valid;

/*
コントローラー：MemberController
├─目的：会員の一覧・登録を扱う
├─ベースパス：/members
├─インジェクション
│  └─会員サービス：MemberService memberService
├─メソッド：list
│  ├─目的：会員の一覧を表示する
│  ├─マッピング：GET
│  ├─引数
│  │    └─モデル：Model model
│  ├─戻り値：String、表示するテンプレート名
│  └─処理
│        ├─memberServiceを使って、全件を読み出した結果をmemberListとしてテンプレートに渡す
│        └─"member/list"を返す
└─メソッド：create
     ├─目的：入力された会員を登録する
     ├─マッピング：POST
     ├─引数
     │    └─入力内容：@検証 MemberForm memberForm
     ├─戻り値：String、表示するテンプレート名またはリダイレクト先
     └─処理
           ├─◇─resultにエラーがある
           │  └─"member/form"を返す
           ├─memberServiceを使って、memberFormから会員を登録する
           ├─"登録しました"をフラッシュメッセージとして渡す
           └─ベースパスにリダイレクトする
*/

// 会員の一覧・登録を扱う
@Controller
@RequestMapping("/members")
public class MemberController {

    private final MemberService memberService; // 会員サービス

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    /**
     * 会員の一覧を表示する
     *
     * @param model モデル
     * @return 表示するテンプレート名
     */
    @GetMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため
    public String list(Model model) {
        model.addAttribute("memberList", memberService.findAll());
        return "member/list";
    }

    /**
     * 入力された会員を登録する
     *
     * @param memberForm 入力内容
     * @param result 検証結果
     * @param redirectAttrs リダイレクト先へ渡す属性
     * @return 表示するテンプレート名またはリダイレクト先
     */
    // SPDに無いため BindingResult result を補った
    // SPDに無いため RedirectAttributes redirectAttrs を補った
    @PostMapping({"", "/"}) // 末尾の / の有無どちらでも受け付けるため
    public String create(@Valid MemberForm memberForm,
                         BindingResult result,
                         RedirectAttributes redirectAttrs) {
        if (result.hasErrors()) {
            return "member/form";
        }
        memberService.create(memberForm);
        redirectAttrs.addFlashAttribute("message", "登録しました");
        return "redirect:/members";
    }
}
```

**MemberRepository.java**（SPDは同様に冒頭へ残す。以下は本体のみ）

```java
public interface MemberRepository extends JpaRepository<Member, Long> {
}
```

**MemberForm.java**（同上）

```java
// 会員登録画面の入力項目
public class MemberForm {

    @NotBlank
    @Size(max = 20)
    private String name; // 名前

    // 自動生成：コンストラクタ：引数なし
    public MemberForm() {
    }

    // 自動生成：ゲッター／セッター
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

