# build-claude.ps1
# Gemini スキル（C/Gemini-skill）の SKILL.md から、claude.ai 用のスキルを作る。
# Gemini 版のファイルを直したら、このスクリプトを実行する。
#
# 使い方（C/Claude-skill/build フォルダーで）:
#   powershell -ExecutionPolicy Bypass -File build-claude.ps1
#
# 出力（C/Claude-skill フォルダー）:
#   spd-to-c-generator/SKILL.md          ← Gemini の SKILL.md のうち、いつも使うセクション（$rules で 'SKILL' としたもの）
#   spd-to-c-generator/references/*.md   ← 残りのセクションを、節ごとに分けたもの
#   spd-to-c-generator.zip               ← claude.ai にアップロードするファイル
#
# 行う変換:
#   - SKILL.md を見出しで分け、$rules でファイル名を決めたセクションを references に移す
#   - 「ガイドライン」の書き方を「規約」に置き換える
#   - SKILL.md の description を書き換え、セクション0のあとに「references の構成」（references-section.md）を差し込む
#
# 分け方（$rules）にない「## 」「### 」の見出しが元の SKILL.md に増えたら、エラーで止まる。$rules に足すこと。
# このスクリプトは UTF-8（BOM付き）で保存すること（Windows PowerShell 5.1 が日本語を正しく読むため）。

$ErrorActionPreference = 'Stop'

$buildDir  = $PSScriptRoot
$claudeDir = Split-Path -Parent $buildDir
$geminiDir = Join-Path (Split-Path -Parent $claudeDir) 'Gemini-skill'

$skillName   = 'spd-to-c-generator'
$description = 'SPD（構造化プログラム設計図）から、C言語入門者向けの読みやすいCコードを生成する。├─・◇・↻を使った木構造の設計図（Cファイル先頭のブロックコメント内も含む）を渡されたときに使う。SPDのない、C言語でのコードの提案や、要件定義からのC言語の仕様書作成にも使う'

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

# ---- 節ごとの分け方 ----
# 見出しの書き出し → 置き場所（'SKILL' は SKILL.md に残す。それ以外は references のファイル名）。
# 同じファイル名の見出しは1つのファイルにまとめる。下の順序が SKILL.md の一覧の順序になる。
$rules = @(
    @('## 0. ',          'SKILL'),
    @('## 0.5 ',         'SKILL'),
    @('### 0.5.',        'SKILL'),
    @('## 0.6 ',         'SKILL'),
    @('## 0.7 ',         'SKILL'),
    @('## 共通ルール',   'SKILL'),
    @('### 1. ',         'SKILL'),
    @('### 2. ',         'SKILL'),
    @('### 3. ',         'SKILL'),
    @('### 4. ',         'SKILL'),
    @('### 5. ',         'SKILL'),
    @('### 6. ',         'SKILL'),
    @('### 7. ',         'SKILL'),
    @('### 8. ',         '08-libraries.md'),
    @('### 9. ',         'SKILL'),
    @('### 10. ',        'SKILL'),
    @('## SPDモード',    'SKILL'),
    @('### 11. ',        'SKILL'),
    @('### 12. ',        'SKILL'),
    @('### 13. ',        'SKILL'),
    @('### 14. ',        '14-control.md'),
    @('### 15. ',        '15-types.md'),
    @('### 16. ',        '15-types.md'),
    @('### 16.5 ',       '15-types.md'),
    @('### 17. ',        '17-function.md'),
    @('### 18. ',        '18-c-rules.md'),
    @('### 18.1 ',       '18-1-examples.md'),
    @('### 18.5 ',       '18-5-multifile.md'),
    @('### 19. ',        'SKILL'),
    @('### 20. ',        'SKILL'),
    @('## 通常モード',   '21-normal-mode.md'),
    @('### 21. ',        '21-normal-mode.md'),
    @('### 22. ',        '21-normal-mode.md'),
    @('### 23. ',        '21-normal-mode.md'),
    @('### 24. ',        '21-normal-mode.md'),
    @('### 25. ',        '21-normal-mode.md'),
    @('### 26. ',        '21-normal-mode.md')
)

function Assert-NoGemini([string]$text, [string]$what) {
    $m = [regex]::Match($text, '.*(ナレッジ|ガイドライン|知識ファイル|Gem).*')
    if ($m.Success) { throw "Gemini 用の書き方が残っています（$what）: $($m.Value)" }
}

# ---- 読み込み ----
$source = Read-Text (Join-Path $geminiDir 'SKILL.md')

if ($description.Length -gt 200) { throw "description が200文字を超えています: $($description.Length) 文字" }
if ($description -match ': | #') { throw 'description に「: 」か「 #」があります（YAML として読めなくなる）' }
if (-not [regex]::IsMatch($source, "\A---\nname: $skillName\n")) { throw "SKILL.md の name が $skillName ではありません" }
$source = ([regex]'(?m)^description: .*$').Replace($source, "description: $description", 1)

$source = Edit-Pairs $source @(
    @('## 0. このガイドラインの使い方（最初に確認する）', '## 0. この規約の使い方（最初に確認する）'),
    @('このセクションは、本ガイドラインの**他のすべての規則に優先する**。', 'このセクションは、この規約の**他のすべての規則に優先する**。'),
    @('#### 25.3 ガイドライン適用の強化手順', '#### 25.3 規約適用の強化手順')
) 'SKILL.md'

# ---- 節ごとに分ける ----
# 最初の見出しより前（フロントマター・タイトル・前書き）は SKILL.md に残す。
$files    = [ordered]@{ 'SKILL' = New-Object System.Collections.Generic.List[string] }
$current  = 'SKILL'
$inFence  = $false
foreach ($line in $source -split "`n") {
    if ($line -match '^\s*```') { $inFence = -not $inFence }
    if (-not $inFence -and $line -match '^#{2,3} ') {
        $rule = $null
        foreach ($r in $rules) { if ($line.StartsWith($r[0])) { $rule = $r; break } }
        if (-not $rule) { throw "分け方が決まっていない見出しがあります: $line （`$rules に足すこと）" }
        $current = $rule[1]
        if (-not $files.Contains($current)) { $files[$current] = New-Object System.Collections.Generic.List[string] }
    }
    $files[$current].Add($line)
}

# 区切り線（---）が続いたり、末尾に残ったりしないようにする
function Clean-Rules([string]$t) {
    $t = [regex]::Replace($t, '(\n---\s*)(\n---\s*)+', '$1')
    return [regex]::Replace($t.Trim("`n"), '(\n---\s*)+\z', '')
}

$outputs = [ordered]@{}
$order = @($rules | ForEach-Object { $_[1] } | Where-Object { $_ -ne 'SKILL' } | Select-Object -Unique)
foreach ($name in $order) {
    if (-not $files.Contains($name)) { throw "元の SKILL.md に節がありません: $name" }
    $t = Clean-Rules ($files[$name] -join "`n")
    if ($t.StartsWith('---')) { $t = $t.Substring(3).TrimStart() }
    Assert-NoGemini $t $name
    $outputs["references/$name"] = $t + "`n"
}

# ---- SKILL.md ----
$skill = Clean-Rules ($files['SKILL'] -join "`n")
$section = Read-Text (Join-Path $buildDir 'references-section.md')
$skill = Edit-Pairs $skill @(
    ,@("`n---`n`n## 0.5 ", ("`n" + $section.TrimEnd("`n") + "`n`n---`n`n## 0.5 "))
) 'SKILL.md'
$skill += "`n"
Assert-NoGemini $skill 'SKILL.md'

# references への参照が、すべて実在するファイルを指しているか確かめる。どのファイルも SKILL.md から参照されているか確かめる
foreach ($t in @($skill) + @($outputs.Values)) {
    foreach ($m in [regex]::Matches($t, '`references/([\w.-]+)`')) {
        if (-not $outputs.Contains("references/$($m.Groups[1].Value)")) { throw "存在しないファイルを参照しています: $($m.Value)" }
    }
}
foreach ($k in $outputs.Keys) {
    if (-not $skill.Contains("``$k``")) { throw "SKILL.md の「references の構成」に載っていないファイルがあります: $k （references-section.md に足すこと）" }
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
