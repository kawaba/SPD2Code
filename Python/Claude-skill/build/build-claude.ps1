# build-claude.ps1
# Gemini スキル（Python/Gemini-skill）の2つのスキルから、claude.ai 用のスキルを作る。
# Gemini 版のファイルを直したら、このスクリプトを実行する。
#
# 使い方（Python/Claude-skill/build フォルダーで）:
#   powershell -ExecutionPolicy Bypass -File build-claude.ps1
#
# 出力（Python/Claude-skill フォルダー）:
#   spd-to-python-generator/SKILL.md                  ← Gemini の SKILL.md（description・知識ファイルの参照を書き換え、更新履歴を外す）
#   spd-to-python-generator/references/*.md           ← 変換パターン集を節ごとに分けたものと、更新履歴（history.md）
#   spd-to-python-generator.zip                       ← claude.ai にアップロードするファイル
#   requirements-to-python-generator/SKILL.md         ← Gemini の SKILL.md（description だけを書き換える）
#   requirements-to-python-generator.zip
#
# 行う変換（spd-to-python-generator）:
#   - 変換パターン集の先頭の見出しと説明を取り除き、節ごとのファイルに分ける（$rules）
#   - 「知識ファイル「spd-pattern-python-code.md」の 1.6節」を「`references/1-6-function.md` の 1.6節」に置き換える
#   - SKILL.md の第10章を「変換パターン集（references）」（references-section.md）に差し替え、第11章（更新履歴）を history.md に移す
#
# 分け方（$rules）にない「## 」「### 」の見出しが変換パターン集に増えたら、エラーで止まる。$rules に足すこと。
# このスクリプトは UTF-8（BOM付き）で保存すること（Windows PowerShell 5.1 が日本語を正しく読むため）。

$ErrorActionPreference = 'Stop'

$buildDir  = $PSScriptRoot
$claudeDir = Split-Path -Parent $buildDir
$geminiDir = Join-Path (Split-Path -Parent $claudeDir) 'Gemini-skill'

$spdName = 'spd-to-python-generator'
$reqName = 'requirements-to-python-generator'
$descriptions = @{
    $spdName = 'SPD（構造化プログラム設計図）から、Python入門教育向けの読みやすいPythonコードを生成する。「関数:」「クラス:」「データクラス:」で始まるSPDや、├─・◇・↻・〇を使った木構造の設計図（ファイル先頭のdocstring内も含む）を渡されたときに使う'
    $reqName = '自然文の要件定義（目的・入力・出力・処理条件など）から、Python入門教育向けの仕様書とPythonコードを生成する。SPDではなく文章で要件が書かれているときに使う'
}

$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Text([string]$path) {
    return ([IO.File]::ReadAllText($path, $utf8)).TrimStart([char]0xFEFF) -replace "`r`n", "`n"
}

# $pairs の1つ目を2つ目に置き換える。見つからなければ止める（元の文が変わったことに気づくため）
function Edit-Pairs([string]$text, [array]$pairs, [string]$what) {
    foreach ($p in $pairs) {
        if ($p -isnot [array] -or $p.Count -ne 2) { throw "置き換えの組の書き方が誤っています（$what）" }
        if (-not $text.Contains($p[0])) { throw "置き換える文が見つかりません（$what）: $($p[0].Substring(0, [Math]::Min(40, $p[0].Length)))" }
        $text = $text.Replace($p[0], $p[1])
    }
    return $text
}

function Set-Description([string]$skill, [string]$name) {
    $d = $descriptions[$name]
    if ($d.Length -gt 200) { throw "description が200文字を超えています（$name）: $($d.Length) 文字" }
    if ($d -match ': | #') { throw "description に「: 」か「 #」があります（$name。YAML として読めなくなる）" }
    if (-not [regex]::IsMatch($skill, "\A---\nname: $name\n")) { throw "SKILL.md の name が $name ではありません" }
    return ([regex]'(?m)^description: .*$').Replace($skill, "description: $d", 1)
}

function Assert-NoGemini([string]$text, [string]$what) {
    $m = [regex]::Match($text, '.*(知識ファイル|spd-pattern-python-code|Gem).*')
    if ($m.Success) { throw "Gemini 用の書き方が残っています（$what）: $($m.Value)" }
}

# ---- 節ごとの分け方 ----
# 見出しの書き出し → ファイル名・節番号。同じファイル名の見出しは1つのファイルにまとめる。
# 下の順序が SKILL.md の一覧の順序になる。
$rules = @(
    @('## 1. ',   '1-1-comment.md',           ''),
    @('### 1.1 ', '1-1-comment.md',           '1.1'),
    @('### 1.2 ', '1-2-branch.md',            '1.2'),
    @('### 1.3 ', '1-3-loop.md',              '1.3'),
    @('### 1.4 ', '1-4-exception.md',         '1.4'),
    @('### 1.5 ', '1-5-comprehension.md',     '1.5'),
    @('### 1.6 ', '1-6-function.md',          '1.6'),
    @('### 1.7 ', '1-7-class.md',             '1.7'),
    @('## 2. ',   '2-1-sequence.md',          ''),
    @('### 2.1 ', '2-1-sequence.md',          '2.1'),
    @('### 2.2 ', '2-2-branch.md',            '2.2'),
    @('### 2.3 ', '2-3-loop.md',              '2.3'),
    @('### 2.4 ', '2-4-list.md',              '2.4'),
    @('### 2.5 ', '2-5-dict.md',              '2.5'),
    @('### 2.6 ', '2-6-function.md',          '2.6'),
    @('### 2.7 ', '2-7-file-directory.md',    '2.7'),
    @('### 2.8 ', '2-8-exception-file-io.md', '2.8'),
    @('### 2.9 ', '2-9-class.md',             '2.9'),
    @('### 2.10 ','2-10-inheritance.md',      '2.10'),
    @('### 2.11 ','2-11-dataclass.md',        '2.11'),
    @('### 2.12 ','2-12-import-class.md',     '2.12'),
    @('## 3. ',   '3-unfilled.md',            '3'),
    @('### 3.',   '3-unfilled.md',            '')
)

$sectionFile = @{}
foreach ($r in $rules) { if ($r[2]) { $sectionFile[$r[2]] = $r[1] } }

# 節番号から、その節があるファイルを探す（3.4 → 3）
function Find-SectionFile([string]$num) {
    $n = $num
    while ($true) {
        if ($sectionFile.ContainsKey($n)) { return $sectionFile[$n] }
        $i = $n.LastIndexOf('.')
        if ($i -lt 0) { throw "節番号に対応するファイルがありません: $num" }
        $n = $n.Substring(0, $i)
    }
}

# 「1.6節」を「`references/1-6-function.md` の 1.6節」にする
function Convert-SectionRefs([string]$text) {
    return [regex]::Replace($text, '(?<![\d.])([1-3]\.\d+)節', {
        param($m)
        return "``references/$(Find-SectionFile $m.Groups[1].Value)`` の $($m.Value)"
    })
}

# ---- 読み込み ----
$spdDir  = Join-Path $geminiDir $spdName
$skill   = Read-Text (Join-Path $spdDir 'SKILL.md')
$pattern = Read-Text (Join-Path $spdDir 'spd-pattern-python-code.md')
$reqSkill = Read-Text (Join-Path (Join-Path $geminiDir $reqName) 'SKILL.md')

function Get-Version([string]$text, [string]$pattern, [string]$what) {
    $m = [regex]::Match($text, $pattern)
    if (-not $m.Success) { throw "版数が見つかりません: $what" }
    return $m.Groups[1].Value
}
$vars = @{
    SKILL   = Get-Version $skill   '（v(\d+\.\d+\.\d+) — 更新履歴は第11章を参照）' 'SKILL.md'
    PATTERN = Get-Version $pattern '（v(\d+\.\d+\.\d+) — 更新履歴は第4章を参照）'  'spd-pattern-python-code.md'
}

# ---- 変換パターン集を節ごとに分ける ----
# 「## 1.」より前（見出しと説明）は捨てる。説明の内容は references-section.md に書いてあるので、変わっていないか確かめる。
$i = $pattern.IndexOf("`n## 1. ")
if ($i -lt 0) { throw '変換パターン集に「## 1.」がありません' }
$head = $pattern.Substring(0, $i)
if (-not $head.Contains('本ファイルは変換の**参照表**であり、設計の入力ではない。ここに載っている処理を、与えられたSPDに無いのに補ってはならない。')) {
    throw '変換パターン集の冒頭の説明が変わっています（references-section.md も直すこと）'
}
$body = $pattern.Substring($i + 1)
$j = $body.IndexOf("`n## 4. 更新履歴`n")
if ($j -lt 0) { throw '変換パターン集に「## 4. 更新履歴」がありません' }
$patternHistory = $body.Substring($j + "`n## 4. 更新履歴`n".Length).Trim("`n")
$body = $body.Substring(0, $j)

# 1組だけのときは先頭に「,」を付ける（付けないと PowerShell が1段の配列にしてしまい、1文字ずつ置き換わる）
$body = Edit-Pairs $body @(
    ,@('第1章で形が判定できない場合に参照する、', '変換パターン集の第1章（`references/1-*.md`）で形が判定できない場合に参照する、')
) 'spd-pattern-python-code.md'

$files    = [ordered]@{}
$headings = @{}
$current  = $null
$inFence  = $false
foreach ($line in $body -split "`n") {
    if ($line -match '^\s*```') { $inFence = -not $inFence }
    if (-not $inFence -and $line -match '^#{1,3} ') {
        $rule = $null
        foreach ($r in $rules) { if ($line.StartsWith($r[0])) { $rule = $r; break } }
        if (-not $rule) { throw "分け方が決まっていない見出しがあります: $line （`$rules に足すこと）" }
        $current = $rule[1]
        if (-not $files.Contains($current)) {
            $files[$current] = New-Object System.Collections.Generic.List[string]
            $headings[$current] = New-Object System.Collections.Generic.List[string]
        }
        if ($line -match '^#{2,3} (.*)$') { $headings[$current].Add($Matches[1]) }
    }
    $files[$current].Add($line)
}

$outputs = [ordered]@{}
$order = @($rules | ForEach-Object { $_[1] } | Select-Object -Unique)
foreach ($name in $order) {
    if (-not $files.Contains($name)) { throw "変換パターン集に節がありません: $name" }
    $t = ($files[$name] -join "`n").Trim("`n")
    $t = [regex]::Replace($t, '(\n---\s*)+\z', '')
    $t = Convert-SectionRefs $t
    Assert-NoGemini $t $name
    $outputs["references/$name"] = $t + "`n"
}

# ---- SKILL.md ----
$k = $skill.IndexOf("`n## 11. 更新履歴`n")
if ($k -lt 0) { throw 'SKILL.md に「## 11. 更新履歴」がありません' }
$skillHistory = $skill.Substring($k + "`n## 11. 更新履歴`n".Length).Trim("`n")
$skill = [regex]::Replace($skill.Substring(0, $k), '(\n---\s*)+\z', '').TrimEnd("`n") + "`n"

$outputs['references/history.md'] = (@(
    '# 更新履歴',
    '',
    '## SKILL.md（SPDからのPythonコード生成）',
    '',
    $skillHistory,
    '',
    '## spd-pattern-python-code.md（SPD→Python変換パターン集）',
    '',
    $patternHistory
) -join "`n") + "`n"

$oldChapter10 = @(
    '## 10. 知識ファイル',
    '',
    '- **spd-pattern-python-code.md**：SPD→Python変換パターン集。生成方法に迷ったら必ず参照する。',
    '  - 第1章「変換パターン早見表」：SPD記号（`◇`・`↻`・`〇`）と生成するPythonの対応。まずここで形を判定する。',
    '  - 第2章「作成例」：具体的なプログラムでの変換例。第1章で判断がつかない場合に見る。',
    '  - 第3章「未記入SPDの適用例」：未記入SPDの扱い（第0章）を適用した出力例。'
) -join "`n"

$skill = Set-Description $skill $spdName
$skill = Edit-Pairs $skill @(
    @('— 更新履歴は第11章を参照）', '— 更新履歴は `references/history.md` を参照）'),
    @('4. この指示および知識ファイル', '4. この指示および変換パターン集（`references/`）'),
    @($oldChapter10, '{{CHAPTER10}}')
) 'SKILL.md'
$skill = [regex]::Replace($skill, '知識ファイル「spd-pattern-python-code\.md」(?:の ?)?((?:\d+\.\d+節(?:（[^）]*）)?(?:と ?|・)?)+)', {
    param($m)
    return Convert-SectionRefs $m.Groups[1].Value
})
Assert-NoGemini $skill 'SKILL.md'

$table = New-Object System.Collections.Generic.List[string]
$table.Add('| ファイル | 節 |')
$table.Add('| --- | --- |')
foreach ($name in $order) {
    $h = ($headings[$name] | ForEach-Object { '`' + $_ + '`' }) -join '・'
    $table.Add("| ``references/$name`` | $h |")
}
$table.Add('| `references/history.md` | 更新履歴（`SKILL.md`・変換パターン集） |')
$section = Read-Text (Join-Path $buildDir 'references-section.md')
$section = $section.Replace('{{TABLE}}', ($table -join "`n"))
foreach ($v in $vars.Keys) { $section = $section.Replace("{{$v}}", $vars[$v]) }
$skill = $skill.Replace('{{CHAPTER10}}', $section.TrimEnd("`n"))

# references への参照が、すべて実在するファイルを指しているか確かめる
foreach ($t in @($skill) + @($outputs.Values)) {
    foreach ($m in [regex]::Matches($t, '`references/([\w.-]+)`')) {
        if (-not $outputs.Contains("references/$($m.Groups[1].Value)")) { throw "存在しないファイルを参照しています: $($m.Value)" }
    }
}

$spdAll = [ordered]@{ 'SKILL.md' = $skill }
foreach ($o in $outputs.Keys) { $spdAll[$o] = $outputs[$o] }

$reqSkill = Set-Description $reqSkill $reqName
$reqAll = [ordered]@{ 'SKILL.md' = $reqSkill }

# ---- 書き出し ----
Add-Type -AssemblyName System.IO.Compression

function Write-Skill([string]$skillName, $all) {
    $outDir = Join-Path $claudeDir $skillName
    # フォルダーは消さず、中のファイルだけを消す（エクスプローラーなどで開いていても止まらないように）
    if (Test-Path $outDir) { Get-ChildItem -LiteralPath $outDir -Recurse -File -Force | Remove-Item -Force }
    $dirs = @("$skillName/")
    foreach ($key in $all.Keys) {
        $parent = Split-Path -Parent (Join-Path $outDir $key)
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        [IO.File]::WriteAllText((Join-Path $outDir $key), $all[$key], $utf8)
        $d = $key.LastIndexOf('/')
        if ($d -ge 0 -and $dirs -notcontains "$skillName/$($key.Substring(0, $d + 1))") { $dirs += "$skillName/$($key.Substring(0, $d + 1))" }
    }

    # zip の中のパスは「/」で区切る（Compress-Archive は「\」になることがあり、アップロードで失敗するため）。
    # 日時を固定して、内容が同じなら同じ zip になるようにする。
    $zipPath = Join-Path $claudeDir "$skillName.zip"
    if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
    $stamp = New-Object DateTimeOffset(2026, 1, 1, 0, 0, 0, [TimeSpan]::Zero)
    $fs = [IO.File]::Open($zipPath, 'CreateNew')
    try {
        $zip = New-Object IO.Compression.ZipArchive($fs, [IO.Compression.ZipArchiveMode]::Create)
        try {
            foreach ($dir in $dirs) {
                $e = $zip.CreateEntry($dir)
                $e.LastWriteTime = $stamp
            }
            foreach ($key in $all.Keys) {
                $entry = $zip.CreateEntry("$skillName/$key", [IO.Compression.CompressionLevel]::Optimal)
                $entry.LastWriteTime = $stamp
                $bytes = $utf8.GetBytes($all[$key])
                $s = $entry.Open()
                try { $s.Write($bytes, 0, $bytes.Length) } finally { $s.Dispose() }
            }
        } finally { $zip.Dispose() }
    } finally { $fs.Dispose() }

    Write-Host ("Claude スキル：{0}（SKILL.md {1} 文字、ほか {2} ファイル）、{3}" -f $skillName, $all['SKILL.md'].Length, ($all.Count - 1), (Split-Path -Leaf $zipPath))
}

Write-Skill $spdName $spdAll
Write-Skill $reqName $reqAll
