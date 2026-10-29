# build-claude.ps1
# Gemini スキル（Java/Gemini-skill）の SKILL.md とナレッジ（ガイドライン.txt・pom.xml）から、claude.ai 用のスキルを作る。
# Gemini 版のファイルを直したら、このスクリプトを実行する。
#
# 使い方（Java/Claude-skill/build フォルダーで）:
#   powershell -ExecutionPolicy Bypass -File build-claude.ps1
#
# 出力（Java/Claude-skill フォルダー）:
#   spd-to-java-generator/SKILL.md          ← Gemini の SKILL.md（description・ナレッジの参照を書き換える）
#   spd-to-java-generator/references/*.md   ← ガイドライン.txt を節ごとに分けたもの
#   spd-to-java-generator/references/pom.xml
#   spd-to-java-generator.zip               ← claude.ai にアップロードするファイル
#
# 行う変換:
#   - ガイドライン.txt の先頭の見出しと説明、共通ルールの範囲を示す行を取り除き、節ごとのファイルに分ける（$rules）
#   - 「ナレッジ」「ガイドライン」の書き方を、references のファイルや「この規約」に置き換える
#   - SKILL.md の description を書き換え、「references の構成」（references-section.md）を差し込む
#
# 分け方（$rules）にない「# 」「## 」の見出しが元の規約に増えたら、エラーで止まる。$rules に足すこと。
# このスクリプトは UTF-8（BOM付き）で保存すること（Windows PowerShell 5.1 が日本語を正しく読むため）。

$ErrorActionPreference = 'Stop'

$buildDir  = $PSScriptRoot
$claudeDir = Split-Path -Parent $buildDir
$geminiDir = Join-Path (Split-Path -Parent $claudeDir) 'Gemini-skill'

$skillName   = 'spd-to-java-generator'
$description = 'SPD（構造化プログラム設計図）から、Java入門教育向けのJavaコードを生成する。「クラス:」「抽象クラス:」「インタフェース:」「レコード:」「メソッド:」で始まるSPDや、├─・◇・↻・〇・λ・▽を使った木構造の設計図（Javaファイル先頭のブロックコメント内も含む）を渡されたときに使う'

$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Text([string]$path) {
    return ([IO.File]::ReadAllText($path, $utf8)).TrimStart([char]0xFEFF) -replace "`r`n", "`n"
}

# $pairs の1つ目を2つ目に置き換える。見つからなければ止める（元の規約の文が変わったことに気づくため）
function Edit-Pairs([string]$text, [array]$pairs, [string]$what) {
    foreach ($p in $pairs) {
        if ($p -isnot [array] -or $p.Count -ne 2) { throw "置き換えの組の書き方が誤っています（$what）" }
        if (-not $text.Contains($p[0])) { throw "置き換える文が見つかりません（$what）: $($p[0].Substring(0, [Math]::Min(40, $p[0].Length)))" }
        $text = $text.Replace($p[0], $p[1])
    }
    return $text
}

# ---- 節ごとの分け方 ----
# 見出しの書き出し → ファイル名。同じファイル名の見出しは1つのファイルにまとめる。
# 下の順序が SKILL.md の一覧の順序になる。「### 」「#### 」の見出しは、ここにあるものだけで分ける。
$rules = @(
    @('## 0. ',                 '00-unfilled.md'),
    @('## 最重要ルール',        '01-general.md'),
    @('## 1. ',                 '01-general.md'),
    @('## 2. ',                 '01-general.md'),
    @('## 3. ',                 '01-general.md'),
    @('## 4.',                  '04-input.md'),
    @('## 5. ',                 '05-round.md'),
    @('## 6. ',                 '01-general.md'),
    @('## 7. ',                 '01-general.md'),
    @('## 8. ',                 '01-general.md'),
    @('## 9. ',                 '09-1-overview.md'),
    @('### 9.1 ',               '09-1-overview.md'),
    @('### 9.2 ',               '09-2-symbols.md'),
    @('### 9.3 ',               '09-3-reading.md'),
    @('### 9.4 ',               '09-4-1-branch.md'),
    @('#### 分岐（',            '09-4-1-branch.md'),
    @('#### 繰り返し（',        '09-4-2-loop.md'),
    @('#### 例外処理（',        '09-4-3-exception.md'),
    @('#### ラムダ式（',        '09-4-4-lambda.md'),
    @('#### ストリーム処理（',  '09-4-5-stream.md'),
    @('### 9.5 ',               '09-5-types.md'),
    @('### 9.6 ',               '09-6-members.md'),
    @('### 9.7 ',               '09-7-java.md'),
    @('### 9.8 ',               '09-8-example.md'),
    @('### 9.9 ',               '09-9-checklist.md'),
    @('### 9.10 ',              '09-10-notes.md')
)

function Assert-NoGemini([string]$text, [string]$what) {
    $m = [regex]::Match($text, '.*(ナレッジ|ガイドライン|Gem).*')
    if ($m.Success) { throw "Gemini 用の書き方が残っています（$what）: $($m.Value)" }
}

# ---- 読み込み ----
$guide = Read-Text (Join-Path $geminiDir 'ガイドライン.txt')
$skill = Read-Text (Join-Path $geminiDir 'SKILL.md')
$pom   = Read-Text (Join-Path $geminiDir 'pom.xml')

$m = [regex]::Match($guide, 'copilot-instructions\.md` v(\d+\.\d+\.\d+)')
if (-not $m.Success) { throw '版数が見つかりません: copilot-instructions.md' }
$vars = @{ COMMON = $m.Groups[1].Value }

# ---- 規約の、スキルの構成にかかわる文を置き換える ----
# 共通ルールの範囲を示す行と、その説明（Gem 用の保守の注意）を取り除く
$common = [regex]::Match($guide, '\n===== 共通ルール（COMMON-RULES）v[\d.]+ ここから =====\n(?:[^\n]+\n)*?\n')
if (-not $common.Success) { throw '共通ルールの開始行が見つかりません（ガイドライン.txt）' }
$guide = $guide.Remove($common.Index, $common.Length).Insert($common.Index, "`n")
$commonEnd = [regex]::Match($guide, '\n===== 共通ルール（COMMON-RULES）v[\d.]+ ここまで =====\n')
if (-not $commonEnd.Success) { throw '共通ルールの終了行が見つかりません（ガイドライン.txt）' }
$guide = $guide.Remove($commonEnd.Index, $commonEnd.Length).Insert($commonEnd.Index, "`n")

$guide = Edit-Pairs $guide @(
    @('この第0章は、本ガイドラインの**他のすべての規則に優先する**。', 'この第0章は、この規約の**他のすべての規則に優先する**。'),
    @('6. 本ガイドラインの**他の節が明示的に求めている**', '6. この規約の**他の節が明示的に求めている**'),
    @('* **実装前に、このガイドライン全体（特に `## 9. SPD記法からのコード生成`）を確認すること。**',
      '* **実装前に、`SKILL.md` の対応表で該当する節を特定し、そのファイルを確認すること**（特に `## 9. SPD記法からのコード生成`。規約のファイルをすべて読む必要はない）。'),
    @('**コンテキストとして提供される `pom.xml` を必ず参照して自動挿入すること。**', '**`references/pom.xml` を必ず参照して自動挿入すること。**'),
    @('**依存ライブラリの正は、ナレッジの `pom.xml` である。**', '**依存ライブラリの正は、`references/pom.xml` である。**')
) 'ガイドライン.txt'

# ---- 節ごとに分ける ----
# 最初の見出しより前（Gemini 用の見出しと説明）は捨てる。
$files    = [ordered]@{}
$headings = @{}
$current  = $null
$inFence  = $false
foreach ($line in $guide -split "`n") {
    if ($line -match '^\s*```') { $inFence = -not $inFence }
    if (-not $inFence -and $line -match '^#{1,4} ') {
        $rule = $null
        foreach ($r in $rules) { if ($line.StartsWith($r[0])) { $rule = $r; break } }
        if ($rule) {
            $current = $rule[1]
            if (-not $files.Contains($current)) {
                $files[$current] = New-Object System.Collections.Generic.List[string]
                $headings[$current] = New-Object System.Collections.Generic.List[string]
            }
            if ($line -match '^#{2,4} (.*)$') { $headings[$current].Add($Matches[1]) }
        } elseif ($current -and $line -match '^#{1,2} ') {
            throw "分け方が決まっていない見出しがあります: $line （`$rules に足すこと）"
        }
    }
    if ($current) { $files[$current].Add($line) }
    elseif ($line -match '^## ') { throw "最初の見出しより前に章があります: $line" }
}

$outputs = [ordered]@{}
$order = @($rules | ForEach-Object { $_[1] } | Select-Object -Unique)
foreach ($name in $order) {
    if (-not $files.Contains($name)) { throw "元の規約に節がありません: $name" }
    $t = ($files[$name] -join "`n").Trim("`n")
    $t = [regex]::Replace($t, '(\n---\s*)+\z', '')
    Assert-NoGemini $t $name
    $outputs["references/$name"] = $t + "`n"
}
$outputs['references/pom.xml'] = $pom.TrimEnd("`n") + "`n"

# ---- SKILL.md ----
$table = New-Object System.Collections.Generic.List[string]
$table.Add('| ファイル | 節 |')
$table.Add('| --- | --- |')
foreach ($name in $order) {
    # 見出しの中の `…` は外す（「`分岐（`◇`）`」のように入れ子になり、表示が崩れるため）
    $h = ($headings[$name] | ForEach-Object { '`' + $_.Replace('`', '') + '`' }) -join '・'
    $table.Add("| ``references/$name`` | $h |")
}
$table.Add('| `references/pom.xml` | 依存ライブラリの見本 |')
$section = Read-Text (Join-Path $buildDir 'references-section.md')
$section = $section.Replace('{{TABLE}}', ($table -join "`n"))
foreach ($k in $vars.Keys) { $section = $section.Replace("{{$k}}", $vars[$k]) }

if ($description.Length -gt 200) { throw "description が200文字を超えています: $($description.Length) 文字" }
if ($description -match ': | #') { throw 'description に「: 」か「 #」があります（YAML として読めなくなる）' }
if (-not [regex]::IsMatch($skill, "\A---\nname: $skillName\n")) { throw "SKILL.md の name が $skillName ではありません" }
$skill = ([regex]'(?m)^description: .*$').Replace($skill, "description: $description", 1)

$skill = Edit-Pairs $skill @(
    @('詳細・具体例・誤記の判断表はナレッジの `## 0` にあります。', '詳細・具体例・誤記の判断表は `references/00-unfilled.md`（`## 0`）にあります。'),
    @('残りの細目はナレッジの `## 0.8` にあります。', '残りの細目は `references/00-unfilled.md` の `## 0.8` にあります。'),
    @('／ガイドラインの他の節が明示的に求めている不整合の指摘。', '／規約の他の節が明示的に求めている不整合の指摘。'),
    @('# ナレッジの参照', '# 詳細な規約の参照'),
    @('詳細な規約は、ナレッジ **`ガイドライン.txt`** に全文があります。', '詳細な規約は、このスキルの `references/` フォルダーに、節ごとのファイルで置いてあります（構成は下の「references の構成」）。'),
    @('＋ **ナレッジの `pom.xml`（実際の依存関係はこちらが正）**', '＋ **`references/pom.xml`（実際の依存関係はこちらが正）**'),
    @('これらはナレッジを読みに行く必要はありません。', 'これらは references を読みに行く必要はありません。'),
    @('（ナレッジを読む前でも常に適用）', '（references を読む前でも常に適用）'),
    @('まずナレッジの該当節を読む。', 'まず `references/` の該当するファイルを読む。'),
    @('**該当する節をすべて特定し、ナレッジから読む**。', '**該当する節をすべて特定し、そのファイルを `references/` から開いて読む**（関係のないファイルは開かない）。'),
    @("`n# 絶対ルール（", ("`n" + $section.TrimEnd("`n") + "`n`n# 絶対ルール（"))
) 'SKILL.md'
Assert-NoGemini $skill 'SKILL.md'

# references への参照が、すべて実在するファイルを指しているか確かめる
foreach ($t in @($skill) + @($outputs.Values)) {
    foreach ($m in [regex]::Matches($t, '`references/([\w.-]+)`')) {
        if (-not $outputs.Contains("references/$($m.Groups[1].Value)")) { throw "存在しないファイルを参照しています: $($m.Value)" }
    }
}

$all = [ordered]@{ 'SKILL.md' = $skill }
foreach ($k in $outputs.Keys) { $all[$k] = $outputs[$k] }

# ---- 書き出し ----
$outDir = Join-Path $claudeDir $skillName
# フォルダーは消さず、中のファイルだけを消す（エクスプローラーなどで開いていても止まらないように）
if (Test-Path $outDir) { Get-ChildItem -LiteralPath $outDir -Recurse -File -Force | Remove-Item -Force }
New-Item -ItemType Directory -Path (Join-Path $outDir 'references') -Force | Out-Null
foreach ($k in $all.Keys) {
    [IO.File]::WriteAllText((Join-Path $outDir $k), $all[$k], $utf8)
}

# zip の中のパスは「/」で区切る（Compress-Archive は「\」になることがあり、アップロードで失敗するため）。
# 日時を固定して、内容が同じなら同じ zip になるようにする。
Add-Type -AssemblyName System.IO.Compression
$zipPath = Join-Path $claudeDir "$skillName.zip"
if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
$stamp = New-Object DateTimeOffset(2026, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
$fs = [IO.File]::Open($zipPath, 'CreateNew')
try {
    $zip = New-Object IO.Compression.ZipArchive($fs, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($dir in @("$skillName/", "$skillName/references/")) {
            $d = $zip.CreateEntry($dir)
            $d.LastWriteTime = $stamp
        }
        foreach ($k in $all.Keys) {
            $entry = $zip.CreateEntry("$skillName/$k", [IO.Compression.CompressionLevel]::Optimal)
            $entry.LastWriteTime = $stamp
            $bytes = $utf8.GetBytes($all[$k])
            $s = $entry.Open()
            try { $s.Write($bytes, 0, $bytes.Length) } finally { $s.Dispose() }
        }
    } finally { $zip.Dispose() }
} finally { $fs.Dispose() }

Write-Host ("Claude スキル：SKILL.md {0} 文字、references {1} ファイル、{2}" -f $skill.Length, $outputs.Count, (Split-Path -Leaf $zipPath))
