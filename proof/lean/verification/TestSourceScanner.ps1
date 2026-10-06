$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LeanSource.ps1')
$InputText = @'
/- theorem outer : False
  /- namespace Wrong -/
theorem below : False -/
namespace Real
theorem real' : True := by trivial -- theorem fake : False
def text := "theorem fake2 : False /- -- \""
def raw := r##"/- theorem fake3 : False -/"##
def quote := '"'
lemma next : True := by trivial
end Real
'@
$Code = [ThomsonN9LeanSourceV1]::CodeOnly($InputText)
$Names = @($Code -split '\r?\n' | ForEach-Object {
    if ($_ -match "^(?:theorem|lemma)\s+([\p{L}_][\p{L}\p{N}_'.]*)") { $Matches[1] }
})
if (($Names -join ',') -cne "real',next") { throw ('Wrong inventory: ' + ($Names -join ',')) }
if (($Code -split '\n').Count -ne ($InputText -split '\n').Count) { throw 'Line count changed.' }
foreach ($Bad in @('/- unclosed', '"unclosed', 'r##"unclosed"#')) {
    $Rejected = $false
    try { [void][ThomsonN9LeanSourceV1]::CodeOnly($Bad) } catch { $Rejected = $true }
    if (-not $Rejected) { throw ('Accepted invalid lexical input: ' + $Bad) }
}
Write-Output 'PASS: nested comments, line comments, ordinary/raw strings, quote character, apostrophe names, and three malformed-input controls.'
