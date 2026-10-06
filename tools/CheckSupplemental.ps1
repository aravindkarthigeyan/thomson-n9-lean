param([string]$Python = 'python', [string]$Lake = 'lake', [switch]$ValidateOnly)
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
& $Python (Join-Path $PSScriptRoot 'verify_publication.py')
if ($LASTEXITCODE -ne 0) { throw 'Publication inventory failed' }
$FreezePath = Join-Path $Root 'proof/evidence/clean/FREEZE.json'
$PublicHash = '12b45fcabf1a32e6760ef4663070e4292521e34636b0073d888daa14ba2a96d6'
if ((Get-FileHash -LiteralPath $FreezePath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $PublicHash) {
    throw 'Unexpected public audit specification'
}
$Freeze = Get-Content -Raw -LiteralPath $FreezePath | ConvertFrom-Json
$LeanRoot = Join-Path $Root 'proof/lean'
if (@($Freeze.tests).Count -ne 17) { throw 'Unexpected supplemental fixture count' }
foreach ($Test in $Freeze.tests) {
    $Path = [IO.Path]::GetFullPath((Join-Path $LeanRoot $Test.path))
    if (-not $Path.StartsWith($LeanRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw 'Invalid fixture path' }
    if ($Test.expectation -notin @('pass', 'reject')) { throw 'Invalid expected outcome' }
}
if ($ValidateOnly) {
    Write-Output 'PASS: public inventory, public FREEZE hash, and 17 fixture paths validated; Lean not run.'
    exit 0
}
Push-Location -LiteralPath $LeanRoot
try {
    & powershell -NoProfile -ExecutionPolicy Bypass -File verification/TestSourceScanner.ps1
    if ($LASTEXITCODE -ne 0) { throw 'Source scanner tests failed' }
    & $Lake env lean -j1 fresh-verification/FinalTargetAudit.lean
    if ($LASTEXITCODE -ne 0) { throw 'Final theorem type audit failed' }
    foreach ($Test in $Freeze.tests) {
        $Lines = @(& $Lake env lean -j1 $Test.path 2>&1)
        $Code = $LASTEXITCODE
        $Text = ($Lines | ForEach-Object { $_.ToString() }) -join "`n"
        $Text
        if ($Test.expectation -eq 'pass') {
            if ($Code -ne 0) { throw ('Fixture failed: ' + $Test.path) }
        } else {
            $Errors = [regex]::Matches($Text, '(?m)^([^\r\n]+):(\d+):(\d+): error:')
            $ErrorLines = @($Errors | ForEach-Object { [int]$_.Groups[2].Value } | Sort-Object -Unique)
            $WrongFile = @($Errors | Where-Object {
                [IO.Path]::GetFileName($_.Groups[1].Value) -cne [IO.Path]::GetFileName($Test.path)
            }).Count -ne 0
            if ($null -eq $Code -or $Code -isnot [int] -or $Code -eq 0 -or
                $Errors.Count -eq 0 -or $WrongFile -or
                $Text -notmatch $Test.expectedDiagnostic -or
                $Text -match 'unknown module|unknown package|object file.*does not exist|out of memory|stack overflow|failed to create|maximum recursion depth' -or
                @(Compare-Object @($Test.expectedErrorLines) $ErrorLines).Count -ne 0) {
                throw ('Expected exact kernel rejection missing: ' + $Test.path)
            }
        }
    }
    Write-Output 'PASS: public supplemental audit completed.'
} finally {
    Pop-Location
}
