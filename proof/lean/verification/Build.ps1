param([switch]$Clean, [switch]$ListTargets, [string]$Lake = 'lake')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'LeanSource.ps1')
if ($Clean -and $ListTargets) { throw 'Choose either -Clean or -ListTargets.' }
$Root = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
Set-Location -LiteralPath $Root
if ($Clean) {
    $Build = [IO.Path]::GetFullPath((Join-Path $Root '.lake/build'))
    $Prefix = $Root.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if (-not $Build.StartsWith($Prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Refusing to clean a path outside this package.'
    }
    $LakeDirectory = Join-Path $Root '.lake'
    if (Test-Path -LiteralPath $LakeDirectory) {
        $LakeItem = Get-Item -LiteralPath $LakeDirectory
        if (($LakeItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'Refusing to clean through a junction or symbolic-link .lake directory.'
        }
    }
    if (Test-Path -LiteralPath $Build) {
        $Item = Get-Item -LiteralPath $Build
        if (($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'Refusing to recursively clean a junction or symbolic link.'
        }
        Write-Output ('Cleaning only ' + $Build)
        Remove-Item -LiteralPath $Build -Recurse -Force
    }
}
$Modules = [Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)
function AddModule([IO.FileInfo]$File, [string]$Base) {
    $Relative = $File.FullName.Substring($Base.Length + 1)
    $Name = $Relative.Substring(0, $Relative.Length - 5).Replace('\', '.').Replace('/', '.')
    $Modules.Add($Name, $File.FullName)
}
Get-ChildItem -LiteralPath $Root -Filter '*.lean' -File | ForEach-Object { AddModule $_ $Root }
foreach ($Directory in @('ThomsonN9', 'ClaudeWindow', 'ClaudeL1', 'ClaudeL2b', 'vendor')) {
    $Path = Join-Path $Root $Directory
    if (-not (Test-Path -LiteralPath $Path)) { continue }
    $Base = if ($Directory -eq 'vendor') { $Path } else { $Root }
    Get-ChildItem -LiteralPath $Path -Filter '*.lean' -File -Recurse |
        ForEach-Object { AddModule $_ $Base }
}
$Dependencies = @{}
foreach ($Name in $Modules.Keys) {
    $Imports = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($Code in (Get-LeanCodeLines $Modules[$Name])) {
        if ($Code -match '^\s*(?:public\s+)?import\s+(.+)$') {
            foreach ($Import in ($Matches[1].Trim() -split '\s+')) {
                if ($Modules.ContainsKey($Import)) { [void]$Imports.Add($Import) }
            }
        }
    }
    $Dependencies[$Name] = @($Imports | Sort-Object)
}
$Targets = [Collections.Generic.List[string]]::new()
$Visited = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$Active = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
function VisitModule([string]$Name) {
    if ($Visited.Contains($Name)) { return }
    if (-not $Active.Add($Name)) { throw ('Local import cycle at ' + $Name) }
    foreach ($Dependency in $Dependencies[$Name]) { VisitModule $Dependency }
    [void]$Active.Remove($Name)
    [void]$Visited.Add($Name)
    $Targets.Add($Name)
}
foreach ($Name in ($Modules.Keys | Sort-Object)) { VisitModule $Name }
if ($ListTargets) {
    $Targets | ForEach-Object { Write-Output $_ }
    exit 0
}
$SavedLeanNumThreads = $env:LEAN_NUM_THREADS
try {
    $env:LEAN_NUM_THREADS = '1'
    Write-Output 'RESOURCE ENV: LEAN_NUM_THREADS=1; package compiler arguments: -j1.'
    foreach ($Target in $Targets) {
        Write-Output ('Building ' + $Target)
        & $Lake build ('+' + $Target)
        if ($LASTEXITCODE -ne 0) { throw ('Lean build failed: ' + $Target) }
    }
    & $Lake build
    if ($LASTEXITCODE -ne 0) { throw 'Default-target build failed.' }
    Write-Output 'PASS: every package module and all default targets built successfully.'
} finally {
    $env:LEAN_NUM_THREADS = $SavedLeanNumThreads
}
