param([switch]$PrintMissingAxioms)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LeanSource.ps1')
$Root = Split-Path -Parent $PSScriptRoot
$Files = @(
    Get-ChildItem -LiteralPath (Join-Path $Root 'ThomsonN9') -Filter '*.lean' -File -Recurse
    Get-ChildItem -LiteralPath $Root -Filter '*.lean' -File
)
foreach ($Directory in @('ClaudeWindow', 'ClaudeL1', 'ClaudeL2b')) {
    $ImportedPath = Join-Path $Root $Directory
    if (Test-Path -LiteralPath $ImportedPath) {
        $Files += @(Get-ChildItem -LiteralPath $ImportedPath -Filter '*.lean' -File -Recurse)
    }
}
$Vendored = @()
$VendorPath = Join-Path $Root 'vendor'
if (Test-Path -LiteralPath $VendorPath) {
    $Vendored = @(Get-ChildItem -LiteralPath $VendorPath -Filter '*.lean' -File -Recurse)
}
$Forbidden = '\b(sorry|admit|axiom|unsafe|native_decide|native_eval|implemented_by|ofReduceBool|ofReduceNat|extern)\b|\bdebug\.(skipKernelTC|byAsSorry)\b'
$Bad = @((@($Files) + @($Vendored)) | Select-String -Pattern $Forbidden)
if ($Bad.Count -ne 0) {
    $Bad | ForEach-Object { Write-Output $_ }
    throw 'Forbidden proof token found.'
}
$Declared = @(
    foreach ($File in $Files) {
        $Scopes = [Collections.Generic.List[string]]::new()
        foreach ($Line in (Get-LeanCodeLines $File.FullName)) {
            if ($Line -match '^namespace\s+([A-Za-z0-9_.]+)\s*$') {
                $Scopes.Add($Matches[1])
            } elseif ($Line -match '^(?:(?:noncomputable|public)\s+)?section(?:\s+[A-Za-z0-9_.]+)?\s*$') {
                $Scopes.Add('')
            } elseif ($Line -match '^end(?:\s+[A-Za-z0-9_.]+)?\s*$') {
                if ($Scopes.Count -eq 0) { throw ('Unmatched scope end: ' + $File.FullName) }
                $Scopes.RemoveAt($Scopes.Count - 1)
            } elseif ($Line -match "^(?:@\[[^\]]+\]\s*)?(?:protected\s+)?(?:theorem|lemma)\s+([\p{L}_][\p{L}\p{N}_'.]*)") {
                $Name = $Matches[1]
                if ($Name.StartsWith('ThomsonN9.')) { $Name } else {
                    $Namespace = @($Scopes | Where-Object { $_ -ne '' }) -join '.'
                    if ($Namespace -eq '') { $Name } else { $Namespace + '.' + $Name }
                }
            }
        }
        if ($Scopes.Count -ne 0) { throw ('Unclosed source scope: ' + $File.FullName) }
    }
) | Sort-Object -Unique -CaseSensitive
$Audited = @(Select-String -LiteralPath (Join-Path $Root 'Solution.lean') -Pattern '^#print axioms\s+(\S+)' |
    ForEach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object -Unique -CaseSensitive)
$Missing = @($Declared | Where-Object { $_ -cnotin $Audited })
if ($PrintMissingAxioms) {
    $Missing | ForEach-Object { Write-Output ('#print axioms ' + $_) }
    exit 0
}
if ($Missing.Count -ne 0) { throw ('Missing axiom audit: ' + ($Missing -join ', ')) }
Write-Output ('PASS: {0} Lean source files; no forbidden proof tokens.' -f $Files.Count)
Write-Output ('PASS: {0} vendored Lean source files; no forbidden proof tokens.' -f $Vendored.Count)
Write-Output ('PASS: all {0} public theorem/lemma declarations have #print axioms entries.' -f $Declared.Count)
$HashFiles = @($Files) + @($Vendored) + @(
    Get-Item -LiteralPath (Join-Path $Root 'lean-toolchain')
    Get-Item -LiteralPath (Join-Path $Root 'lakefile.toml')
    Get-Item -LiteralPath (Join-Path $Root 'lake-manifest.json')
)
foreach ($File in ($HashFiles | Sort-Object FullName)) {
    $Hash = Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256
    $Relative = $File.FullName.Substring($Root.Length + 1).Replace('\', '/')
    Write-Output ($Hash.Hash.ToLowerInvariant() + '  ' + $Relative)
}
