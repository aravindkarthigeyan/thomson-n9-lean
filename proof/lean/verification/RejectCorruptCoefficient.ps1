param([string]$Lake = 'lake')
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
Set-Location -LiteralPath $Root
$Source = [IO.File]::ReadAllText((Join-Path $Root 'ThomsonN9/ParameterSigns.lean'))
$Old = 'sqrt_enclosure50 173205080756887729352744634150587236694280525381038 3'
$New = 'sqrt_enclosure50 173205080756887729352744634150587236694280525381039 3'
$Index = $Source.IndexOf($Old, [StringComparison]::Ordinal)
if ($Index -lt 0) { throw 'The exact original coefficient was not found.' }
$Corrupt = $Source.Remove($Index, $Old.Length).Insert($Index, $New)
$Directory = Join-Path $Root '.lake/mutation'
New-Item -ItemType Directory -Path $Directory -Force | Out-Null
$File = Join-Path $Directory 'ParameterSigns.lean'
[IO.File]::WriteAllText($File, $Corrupt, [Text.UTF8Encoding]::new($false))
Write-Output 'Changing only the first sqrt(3) lower-enclosure integer by +1.'
Write-Output 'The real certificate source is unchanged.'
$SavedLeanNumThreads = $env:LEAN_NUM_THREADS
try {
    $env:LEAN_NUM_THREADS = '1'
    $ErrorActionPreference = 'Continue'
    $Diagnostic = @('RESOURCE ENV: LEAN_NUM_THREADS=1; explicit compiler argument: -j1.') +
        @(& $Lake env lean -j1 $File 2>&1)
    $Code = $LASTEXITCODE
} finally {
    $ErrorActionPreference = 'Stop'
    $env:LEAN_NUM_THREADS = $SavedLeanNumThreads
}
$Diagnostic | ForEach-Object { Write-Output $_ }
if ($Code -eq 0) { throw 'UNSOUND TEST RESULT: corrupted coefficient was accepted.' }
$Text = $Diagnostic -join "`n"
if ($Text -notmatch 'unsolved goals' -or $Text -notmatch 'False') {
    throw 'Lean failed for a reason other than rejecting the false enclosure.'
}
Write-Output ('PASS: Lean rejected the corrupted certificate, exit code ' + $Code + '.')
exit 0
