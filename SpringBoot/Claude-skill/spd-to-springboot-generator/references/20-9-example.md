## 20.9 完全な変換例

### 与えられたSPD

この例は会員の一覧と登録だけを扱うので、`MemberForm` に主キーの `id` を置いていない。
更新も扱う場合は、エンティティの主キーと同じ名前・型のフィールドを置く（`## 20.6`「主キーのフィールド」）。

```
エンティティ：Member
├─目的：会員を表すエンティティ
├─テーブル：members
├─フィールド
│  ├─番号：@主キー @自動採番 Long id
│  └─名前：@必須 @文字数(20) String name
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター

フォーム：MemberForm
├─目的：会員登録画面の入力項目
├─フィールド
│  └─名前：String name　＠必須、＠20文字以内
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
└─自動生成：MemberRepository
      ├─全件検索
      └─新規作成

コントローラー：MemberController
├─目的：会員の一覧・登録を扱う
├─ベースパス：/members
├─インジェクション
│  └─会員サービス：MemberService memberService
├─メソッド：list
│  ├─目的：会員の一覧を表示する
│  ├─マッピング：GET
│  ├─引数：なし
│  └─処理
│        ├─memberServiceを使って、全件を読み出した結果をmemberListとしてテンプレートに渡す
│        └─"member/list"を返す
└─メソッド：create
     ├─目的：入力された会員を登録する
     ├─マッピング：POST
     ├─引数
     │    └─入力内容：@検証 MemberForm memberForm
     └─処理
           ├─◇─検証結果にエラーがある
           │  └─"member/form"を返す
           ├─memberServiceのcreateでmemberFormから会員を登録し、memberとする
           ├─"会員 {member.getId()} を登録した"をログに出す
           ├─"登録しました"をフラッシュメッセージとして渡す
           └─ベースパスにリダイレクトする
```

### 生成されるコード

**Member.java**

```java
/*
エンティティ：Member
├─目的：会員を表すエンティティ
├─テーブル：members
├─フィールド
│  ├─番号：@主キー @自動採番 Long id
│  └─名前：@必須 @文字数(20) String name
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター
*/

package com.example.app.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

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
/*
サービス：MemberService
├─目的：会員に関する業務処理を行う
├─インジェクション
│  └─会員リポジトリ：MemberRepository memberRepository
└─自動生成：MemberRepository
      ├─全件検索
      └─新規作成
*/

package com.example.app.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.app.entity.Member;
import com.example.app.form.MemberForm;
import com.example.app.repository.MemberRepository;

// 会員に関する業務処理を行う
@Service
public class MemberService {

    private final MemberRepository memberRepository; // 会員リポジトリ

    public MemberService(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }

    // 自動生成：全件検索
    @Transactional(readOnly = true)
    public List<Member> findAll() {
        return memberRepository.findAll();
    }

    // 自動生成：新規作成
    @Transactional
    public Member create(MemberForm memberForm) {
        var member = new Member();
        member.setName(memberForm.getName());
        return memberRepository.save(member);
    }
}
```

**MemberController.java**

```java
/*
コントローラー：MemberController
├─目的：会員の一覧・登録を扱う
├─ベースパス：/members
├─インジェクション
│  └─会員サービス：MemberService memberService
├─メソッド：list
│  ├─目的：会員の一覧を表示する
│  ├─マッピング：GET
│  ├─引数：なし
│  └─処理
│        ├─memberServiceを使って、全件を読み出した結果をmemberListとしてテンプレートに渡す
│        └─"member/list"を返す
└─メソッド：create
     ├─目的：入力された会員を登録する
     ├─マッピング：POST
     ├─引数
     │    └─入力内容：@検証 MemberForm memberForm
     └─処理
           ├─◇─検証結果にエラーがある
           │  └─"member/form"を返す
           ├─memberServiceのcreateでmemberFormから会員を登録し、memberとする
           ├─"会員 {member.getId()} を登録した"をログに出す
           ├─"登録しました"をフラッシュメッセージとして渡す
           └─ベースパスにリダイレクトする
*/

package com.example.app.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

// 会員の一覧・登録を扱う
@Controller
@RequestMapping("/members")
public class MemberController {

    // SPDに無いため Logger log を補った
    private static final Logger log = LoggerFactory.getLogger(MemberController.class);

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
    // SPDに無いため Model model を補った
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
        var member = memberService.create(memberForm);
        log.info("会員 {} を登録した", member.getId());
        redirectAttrs.addFlashAttribute("message", "登録しました");
        return "redirect:/members";
    }
}
```

**MemberRepository.java**

```java
/*
リポジトリ：MemberRepository
├─目的：会員の永続化を行う
├─対象：Member
├─主キー：Long
└─検索メソッド：なし
*/

package com.example.app.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.app.entity.Member;

// 会員の永続化を行う
public interface MemberRepository extends JpaRepository<Member, Long> {
}
```

**MemberForm.java**

```java
/*
フォーム：MemberForm
├─目的：会員登録画面の入力項目
├─フィールド
│  └─名前：String name　＠必須、＠20文字以内
└─自動生成
     ├─コンストラクタ：引数なし
     ├─ゲッター
     └─セッター
*/

package com.example.app.form;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

// 会員登録画面の入力項目
public class MemberForm {

    @NotBlank
    @Size(max = 20)
    private String name; // 名前

    // 自動生成：コンストラクタ：引数なし
    public MemberForm() {
    }

    // 自動生成：ゲッター
    public String getName() {
        return name;
    }

    // 自動生成：セッター
    public void setName(String name) {
        this.name = name;
    }
}
```

