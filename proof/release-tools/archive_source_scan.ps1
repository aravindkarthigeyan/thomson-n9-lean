param([Parameter(Mandatory = $true)][string]$ProjectRoot)
$ErrorActionPreference = 'Stop'
. (Join-Path $ProjectRoot 'verification/LeanSource.ps1')
$Forbidden = '\b(sorry|admit|axiom|unsafe|native_decide|native_eval|implemented_by|ofReduceBool|ofReduceNat|extern)\b|\bdebug\.(skipKernelTC|byAsSorry)\b'
foreach ($File in (Get-ChildItem -LiteralPath $ProjectRoot -File -Filter '*.lean' -Recurse)) {
    $Code = [ThomsonN9LeanSourceV1]::CodeOnly([IO.File]::ReadAllText($File.FullName))
    if ($Code -match $Forbidden) { throw ('Forbidden source shortcut: ' + $File.FullName) }
}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $ProjectRoot 'verification/CheckSource.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Extracted package source inventory failed.' }
Write-Output 'PASS: extracted package and all frozen Lean fixtures passed source scans.'
