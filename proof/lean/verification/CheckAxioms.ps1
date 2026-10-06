param([string]$Lake = 'lake', [string]$LogName = 'EXTENSION_AXIOMS.log')
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
Set-Location -LiteralPath $Root
$Expected = @(Select-String -LiteralPath (Join-Path $Root 'Solution.lean') -Pattern '^#print axioms\s+(\S+)' |
    ForEach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object -Unique -CaseSensitive)
$SavedLeanNumThreads = $env:LEAN_NUM_THREADS
try {
    $env:LEAN_NUM_THREADS = '1'
    $ErrorActionPreference = 'Continue'
    $Output = @('RESOURCE ENV: LEAN_NUM_THREADS=1; explicit compiler argument: -j1.') +
        @(& $Lake env lean -j1 Solution.lean 2>&1)
    $Code = $LASTEXITCODE
} finally {
    $ErrorActionPreference = 'Stop'
    $env:LEAN_NUM_THREADS = $SavedLeanNumThreads
}
$Output | Tee-Object -FilePath (Join-Path $PSScriptRoot $LogName)
if ($Code -ne 0) { throw ('Independent Solution.lean check failed: ' + $Code) }
$Text = $Output -join "`n"
$Reports = [regex]::Matches($Text, "'(\S+)' depends on axioms:\s*\[([^\]]*)\]", 'Singleline')
$Seen = [Collections.Generic.HashSet[string]]::new()
$Allowed = @('propext', 'Classical.choice', 'Quot.sound')
foreach ($Report in $Reports) {
    $Name = $Report.Groups[1].Value
    [void]$Seen.Add($Name)
    $Axioms = @($Report.Groups[2].Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    $Unexpected = @($Axioms | Where-Object { $_ -cnotin $Allowed })
    if ($Unexpected.Count -ne 0) { throw ('Unapproved dependency for ' + $Name + ': ' + ($Unexpected -join ', ')) }
}
foreach ($Report in [regex]::Matches($Text, "'(\S+)' does not depend on any axioms")) {
    [void]$Seen.Add($Report.Groups[1].Value)
}
$Missing = @($Expected | Where-Object { -not $Seen.Contains($_) })
if ($Missing.Count -ne 0) { throw ('Missing printed dependency report: ' + ($Missing -join ', ')) }
Write-Output ('PASS: all {0} requested declarations were checked; dependency closures use only the three standard axioms.' -f $Expected.Count)
