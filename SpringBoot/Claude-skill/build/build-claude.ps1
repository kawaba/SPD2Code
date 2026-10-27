# build-claude.ps1
# Gemini スキル（SpringBoot/Gemini-skill）の SKILL.md とナレッジ3ファイルから、claude.ai 用のスキルを作る。
# SpringBoot/Gemini-skill/build/build-skill.ps1 の最後に呼ばれる。単独で実行してもよい。
#
# 使い方（SpringBoot/Claude-skill/build フォルダーで）:
#   powershell -ExecutionPolicy Bypass -File build-claude.ps1
#
# 出力（SpringBoot/Claude-skill フォルダー）:
#   spd-to-springboot-generator/SKILL.md          ← Gemini の SKILL.md（description・ナレッジの参照を書き換える）
#   spd-to-springboot-generator/references/*.md   ← ナレッジ3ファイルを節ごとに分けたもの
#   spd-to-springboot-generator/references/pom.xml
#   spd-to-springboot-generator.zip               ← claude.ai にアップロードするファイル
#
# 行う変換:
#   - ナレッジ3ファイルの先頭の見出し（header-*.md）を取り除き、節ごとのファイルに分ける（$rules）
#   - 「`ガイドライン-….txt` の `## 20.2`」を「`references/20-2-controller.md` の `## 20.2`」に置き換える
#   - 残ったファイル名を「共通規約」「Spring Boot 規約」「Thymeleaf 規約」に置き換える
#   - SKILL.md の description を書き換え、「references の構成」（references-section.md）を差し込む
#
# 分け方（$rules）にない「# 」「## 」の見出しが元の規約に増えたら、エラーで止まる。$rules に足すこと。
# このスクリプトは UTF-8（BOM付き）で保存すること（Windows PowerShell 5.1 が日本語を正しく読むため）。

$ErrorActionPreference = 'Stop'

$buildDir  = $PSScriptRoot
$claudeDir = Split-Path -Parent $buildDir
$geminiDir = Join-Path (Split-Path -Parent $claudeDir) 'Gemini-skill'

$skillName   = 'spd-to-springboot-generator'
$description = 'SPD（構造化プログラム設計図）から、Spring Bootのエンティティ・フォーム・リポジトリ・サービス・コントローラーとThymeleafテンプレートを生成する。タイトルが「エンティティ:」「フォーム:」「リポジトリ:」「サービス:」「コントローラー:」「テンプレート:」のSPDを渡されたときに使う'

$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Text([string]$path) {
    return ([IO.File]::ReadAllText($path, $utf8)).TrimStart([char]0xFEFF) -replace "`r`n", "`n"
}

# $pairs の1つ目を2つ目に置き換える。見つからなければ止める（元の規約の文が変わったことに気づくため）
function Edit-Pairs([string]$text, [array]$pairs, [string]$what) {
    foreach ($p in $pairs) {
        if (-not $text.Contains($p[0])) { throw "置き換える文が見つかりません（$what）: $($p[0].Substring(0, [Math]::Min(40, $p[0].Length)))" }
        $text = $text.Replace($p[0], $p[1])
    }
    return $text
}

# ---- 節ごとの分け方 ----
# 見出しの書き出し → ファイル名・節番号。同じファイル名の見出しは1つのファイルにまとめる。
# 下の順序が SKILL.md の一覧の順序になる。「### 」の見出しは、ここにあるものだけで分ける。
$rules = @(
    @('common',     '## 0. ',                        '00-unfilled.md',            '0'),
    @('common',     '## 最重要ルール',               '01-general.md',             ''),
    @('common',     '## 実装前チェック',             '01-general.md',             ''),
    @('common',     '## 1. ',                        '01-general.md',             '1'),
    @('common',     '## 2. ',                        '01-general.md',             '2'),
    @('common',     '## 3. ',                        '01-general.md',             '3'),
    @('common',     '## 5. ',                        '01-general.md',             '5'),
    @('common',     '## 6. ',                        '01-general.md',             '6'),
    @('common',     '## 7. ',                        '01-general.md',             '7'),
    @('common',     '## 8. ',                        '01-general.md',             '8'),
    @('common',     '# SPD記法からのコード生成',     '09-0-overview.md',          ''),
    @('common',     '## 9. ',                        '09-0-overview.md',          '9'),
    @('common',     '### 9.2 ',                      '09-2-symbols.md',           '9.2'),
    @('common',     '### 9.3 ',                      '09-3-reading.md',           '9.3'),
    @('common',     '### 9.4 ',                      '09-4-control.md',           '9.4'),
    @('common',     '### 9.5 ',                      '09-5-types.md',             '9.5'),
    @('common',     '### 9.6 ',                      '09-6-members.md',           '9.6'),
    @('common',     '### 9.8 ',                      '09-8-example.md',           '9.8'),
    @('common',     '### 9.9 ',                      '09-9-checklist.md',         '9.9'),
    @('common',     '### 9.10 ',                     '09-10-notes.md',            '9.10'),
    @('common',     '## 10. ',                       '10-skill-operation.md',     '10'),
    @('common',     '## 11. ',                       '11-controller-template.md', '11'),
    @('springboot', '# SPD → Spring Boot',           '20-1-scope.md',             ''),
    @('springboot', '## 20.1 ',                      '20-1-scope.md',             '20.1'),
    @('springboot', '## 20.2 ',                      '20-2-controller.md',        '20.2'),
    @('springboot', '## 20.3 ',                      '20-3-service.md',           '20.3'),
    @('springboot', '## 20.4 ',                      '20-4-repository.md',        '20.4'),
    @('springboot', '## 20.5 ',                      '20-5-entity.md',            '20.5'),
    @('springboot', '## 20.6 ',                      '20-6-form.md',              '20.6'),
    @('springboot', '## 20.7 ',                      '20-7-conventions.md',       '20.7'),
    @('springboot', '## 20.8 ',                      '20-8-checklist.md',         '20.8'),
    @('springboot', '## 20.9 ',                      '20-9-example.md',           '20.9'),
    @('thymeleaf',  '# SPD（テンプレート定義）',     '30-1-scope.md',             ''),
    @('thymeleaf',  '## 30.1 ',                      '30-1-scope.md',             '30.1'),
    @('thymeleaf',  '## 30.2 ',                      '30-2-notation.md',          '30.2'),
    @('thymeleaf',  '## 30.3 ',                      '30-3-nodes.md',             '30.3'),
    @('thymeleaf',  '## 30.4 ',                      '30-4-repeat-condition.md',  '30.4'),
    @('thymeleaf',  '## 30.5 ',                      '30-5-form.md',              '30.5'),
    @('thymeleaf',  '## 30.6 ',                      '30-6-layout.md',            '30.6'),
    @('thymeleaf',  '## 30.7 ',                      '30-7-conventions.md',       '30.7'),
    @('thymeleaf',  '## 30.8 ',                      '30-8-checklist.md',         '30.8'),
    @('thymeleaf',  '## 30.9 ',                      '30-9-example.md',           '30.9')
)

$sectionFile = @{}
foreach ($r in $rules) { if ($r[3]) { $sectionFile[$r[3]] = $r[2] } }

# 節番号から、その節があるファイルを探す（0.8 → 0、9.4.2 → 9.4）
function Find-SectionFile([string]$num) {
    $n = $num.TrimEnd('.')
    while ($true) {
        if ($sectionFile.ContainsKey($n)) { return $sectionFile[$n] }
        $i = $n.LastIndexOf('.')
        if ($i -lt 0) { throw "節番号に対応するファイルがありません: $num" }
        $n = $n.Substring(0, $i)
    }
}

# 元のファイルを見出しで分け、$files（ファイル名 → 行の一覧）と $headings（ファイル名 → 見出しの一覧）に足す。
# 最初の見出しより前（Gemini 用の見出し）は捨てる。
function Split-Source([string]$src, [string]$text) {
    $current = $null
    $inFence = $false
    foreach ($line in $text -split "`n") {
        if ($line -match '^\s*```') { $inFence = -not $inFence }
        if (-not $inFence -and $line -match '^#{1,3} ') {
            $rule = $null
            foreach ($r in $rules) {
                if ($r[0] -eq $src -and $line.StartsWith($r[1])) { $rule = $r; break }
            }
            if ($rule) {
                $current = $rule[2]
                if (-not $files.Contains($current)) {
                    $files[$current] = New-Object System.Collections.Generic.List[string]
                    $headings[$current] = New-Object System.Collections.Generic.List[string]
                }
                if ($line -match '^#{2,3} (.*)$') { $headings[$current].Add($Matches[1]) }
            } elseif ($current -and $line -match '^#{1,2} ') {
                throw "分け方が決まっていない見出しがあります（$src）: $line （`$rules に足すこと）"
            }
        }
        if ($current) { $files[$current].Add($line) }
        elseif ($line -match '^## ') { throw "最初の見出しより前に章があります（$src）: $line" }
    }
}

# 「`ガイドライン-….txt` の `## 20.2`・`## 20.3`」を references のファイルへの参照にし、残ったファイル名を規約の名前にする
function Convert-References([string]$text) {
    $text = [regex]::Replace($text, '`ガイドライン-(?:共通|SpringBoot|Thymeleaf)\.txt` の ((?:`#{2,3} [\d.]+`・?)+)', {
        param($m)
        $list = $m.Groups[1].Value
        $trail = ''
        if ($list.EndsWith('・')) { $list = $list.TrimEnd('・'); $trail = '・' }
        $secs = @([regex]::Matches($list, '`#{2,3} ([\d.]+)`') | ForEach-Object { $_ })
        $targets = @($secs | ForEach-Object { Find-SectionFile $_.Groups[1].Value })
        if (@($targets | Select-Object -Unique).Count -eq 1) {
            return "``references/$($targets[0])`` の $list$trail"
        }
        $parts = for ($i = 0; $i -lt $secs.Count; $i++) { "``references/$($targets[$i])`` の $($secs[$i].Value)" }
        return ($parts -join '・') + $trail
    })
    # 前後の文字が日本語なら、`…` を囲んでいた空白も取る（「Spring Boot 規約（…） に従う」とならないように）
    $names = @{
        '共通'       = '共通規約（`references/` の `00`〜`11` で始まるファイル）'
        'SpringBoot' = 'Spring Boot 規約（`references/20-*.md`）'
        'Thymeleaf'  = 'Thymeleaf 規約（`references/30-*.md`）'
    }
    return [regex]::Replace($text, '(?:(?<=[^\x00-\x7F]) )?`ガイドライン-(共通|SpringBoot|Thymeleaf)\.txt`(?: (?=[^\x00-\x7F]))?', {
        param($m)
        return $names[$m.Groups[1].Value]
    })
}

function Assert-NoGemini([string]$text, [string]$what) {
    $m = [regex]::Match($text, '.*(ナレッジ|ガイドライン-|Gemini).*')
    if ($m.Success) { throw "Gemini 用の書き方が残っています（$what）: $($m.Value)" }
}

# ---- 読み込み ----
$common     = Read-Text (Join-Path $geminiDir 'ガイドライン-共通.txt')
$springboot = Read-Text (Join-Path $geminiDir 'ガイドライン-SpringBoot.txt')
$thymeleaf  = Read-Text (Join-Path $geminiDir 'ガイドライン-Thymeleaf.txt')
$skill      = Read-Text (Join-Path $geminiDir 'SKILL.md')
$pom        = Read-Text (Join-Path $geminiDir 'pom.xml')

function Get-Version([string]$pattern, [string]$what) {
    $m = [regex]::Match($common + $springboot + $thymeleaf, $pattern)
    if (-not $m.Success) { throw "版数が見つかりません: $what" }
    return $m.Groups[1].Value
}
$vars = @{
    COMMON     = Get-Version 'copilot-instructions\.md` v(\d+\.\d+\.\d+)' 'copilot-instructions.md'
    CORE       = Get-Version 'SPD-CORE v(\d+\.\d+\.\d+)'                  'spd-core'
    SPRINGBOOT = Get-Version 'SPRINGBOOT-JAVA v(\d+\.\d+\.\d+)'           'springboot-java'
    THYMELEAF  = Get-Version 'THYMELEAF v(\d+\.\d+\.\d+)'                 'thymeleaf'
}

# ---- 規約の、スキルの構成にかかわる文を置き換える ----
$common = Edit-Pairs $common @(
    @('- 実装前に、この `ガイドライン-共通.txt` 全体を確認してからコード生成・修正を行うこと。',
      '- 実装前に、`SKILL.md` の対応表で該当する節を特定し、そのファイルを確認してからコード生成・修正を行うこと（規約のファイルをすべて読む必要はない）。'),
    @('- ナレッジの `ガイドライン-SpringBoot.txt`・`ガイドライン-Thymeleaf.txt` は、該当するSPDからコードを生成するときに必ず読む（`## 10`）。',
      '- Spring Boot 規約（`references/20-*.md`）・Thymeleaf 規約（`references/30-*.md`）は、該当するSPDからコードを生成するときに、必要な節のファイルを必ず読む（`## 10`）。'),
    @('### 10.1 ナレッジの構成と振り分け', '### 10.1 規約のファイルの構成と振り分け'),
    @('このスキルは、本体（`SKILL.md`）と、ナレッジの次の4ファイルでできている。',
      'このスキルは、本体（`SKILL.md`）と、`references/` フォルダーの次のファイルでできている。規約は節ごとにファイルを分けてあり、ファイル名は節番号で始まる（一覧は `SKILL.md` の「references の構成」）。'),
    @('| `pom.xml` | 依存ライブラリの見本 |', '| `references/pom.xml` | 依存ライブラリの見本 |')
) 'ガイドライン-共通.txt'

# ---- 節ごとに分ける ----
$files    = [ordered]@{}
$headings = @{}
Split-Source 'common'     $common
Split-Source 'springboot' $springboot
Split-Source 'thymeleaf'  $thymeleaf

$outputs = [ordered]@{}
$order = @($rules | ForEach-Object { $_[2] } | Select-Object -Unique)
foreach ($name in $order) {
    if (-not $files.Contains($name)) { throw "元の規約に節がありません: $name" }
    $t = ($files[$name] -join "`n").Trim("`n")
    $t = [regex]::Replace($t, '(\n---\s*)+\z', '')
    $t = Convert-References $t
    Assert-NoGemini $t $name
    $outputs["references/$name"] = $t + "`n"
}
$outputs['references/pom.xml'] = $pom.TrimEnd("`n") + "`n"

# ---- SKILL.md ----
$table = New-Object System.Collections.Generic.List[string]
$table.Add('| ファイル | 節 |')
$table.Add('| --- | --- |')
foreach ($name in $order) {
    $h = ($headings[$name] | ForEach-Object { '`' + $_ + '`' }) -join '・'
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
    @('詳細・具体例はナレッジ `ガイドライン-共通.txt` の `## 0` にあります', '詳細・具体例は `ガイドライン-共通.txt` の `## 0` にあります'),
    @('# ナレッジの参照', '# 詳細な規約の参照'),
    @('詳細な規約はナレッジにあります。', '詳細な規約は、このスキルの `references/` フォルダーに、節ごとのファイルで置いてあります（構成は下の「references の構成」）。'),
    @('（ナレッジを読む前でも常に適用）', '（references を読む前でも常に適用）'),
    @('まずナレッジの該当節を読む。', 'まず `references/` の該当するファイルを読む。'),
    @('**該当する節をすべて特定し、ナレッジから読む**。', '**該当する節をすべて特定し、そのファイルを `references/` から開いて読む**（関係のないファイルは開かない）。'),
    @('＋ `pom.xml`', '＋ `references/pom.xml`'),
    @("`n# スキルでの運用（", ("`n" + $section.TrimEnd("`n") + "`n`n# スキルでの運用（"))
) 'SKILL.md'
$skill = Convert-References $skill
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
