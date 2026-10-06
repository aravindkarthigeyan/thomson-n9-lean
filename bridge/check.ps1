param(
  [Parameter(Mandatory = $true)][string]$LeanExe,
  [Parameter(Mandatory = $true)][string]$N9Project,
  [Parameter(Mandatory = $true)][string]$N7Project
)

$ErrorActionPreference = 'Stop'
$LeanExe = (Resolve-Path -LiteralPath $LeanExe).Path
$N9Project = (Resolve-Path -LiteralPath $N9Project).Path
$N7Project = (Resolve-Path -LiteralPath $N7Project).Path
$expectedUpstreamHash = '2cf12e8ca6bd6ebfb31ae7343ca87ed75a3ba37cbe3d6eb5abbfae483dafbaae'
$upstream = Join-Path $N7Project 'ComparatorChallenges/ThomsonN7.lean'
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $upstream).Hash.ToLowerInvariant() -ne $expectedUpstreamHash) {
  throw 'The upstream challenge source is not the inspected pinned version.'
}
$version = (& $LeanExe --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $version -notmatch 'version 4\.34\.1,') {
  throw 'This bridge requires Lean 4.34.1.'
}
$manifest = Get-Content -Raw -LiteralPath (Join-Path $N9Project 'lake-manifest.json') | ConvertFrom-Json
$mathlib = $manifest.packages | Where-Object { $_.name -eq 'mathlib' }
if ($mathlib.rev -ne 'd13f23b723b8a846827a245b89c10fc7d3f11612') {
  throw 'The N9 project does not have the inspected Mathlib pin.'
}
$build = Join-Path $PSScriptRoot 'build'
$upstreamBuild = Join-Path $build 'ComparatorChallenges'
New-Item -ItemType Directory -Path $upstreamBuild -Force | Out-Null
$paths = @($build, (Join-Path $N9Project '.lake/build/lib/lean'))
$paths += Get-ChildItem -LiteralPath (Join-Path $N9Project '.lake/packages') -Directory |
  ForEach-Object { Join-Path $_.FullName '.lake/build/lib/lean' }
$oldLeanPath = $env:LEAN_PATH
$started = [DateTime]::UtcNow
try {
  $env:LEAN_PATH = $paths -join [IO.Path]::PathSeparator
  # Build the actual upstream challenge in isolation, not its N7 proof package.
  & $LeanExe -j 1 --root $N7Project -o (Join-Path $upstreamBuild 'ThomsonN7.olean') $upstream 2>&1 |
    Tee-Object -FilePath (Join-Path $PSScriptRoot 'upstream-build.log')
  if ($LASTEXITCODE -ne 0) { throw "Upstream challenge compile failed: $LASTEXITCODE" }
  $source = Join-Path $PSScriptRoot 'UpstreamN7Bridge.lean'
  & $LeanExe -j 1 --root $PSScriptRoot -o (Join-Path $build 'UpstreamN7Bridge.olean') $source 2>&1 |
    Tee-Object -FilePath (Join-Path $PSScriptRoot 'bridge-build.log')
  if ($LASTEXITCODE -ne 0) { throw "Bridge compile failed: $LASTEXITCODE" }
  $log = Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'bridge-build.log')
  if ($log -match 'sorryAx' -or $log -notmatch 'PASS: bridge declaration type is definitionally equal') {
    throw 'The bridge axiom/type audit did not pass.'
  }
  $axiomLines = @($log -split '\r?\n' | Where-Object { $_ -match 'depends on axioms:' })
  if ($axiomLines.Count -ne 3) { throw 'Expected exactly three bridge axiom reports.' }
  foreach ($line in $axiomLines) {
    if ($line -notmatch '\[propext, Classical\.choice, Quot\.sound\]$') {
      throw "Unexpected axiom report: $line"
    }
  }
  [ordered]@{
    status = 'PASS'
    started_utc = $started.ToString('o')
    completed_utc = [DateTime]::UtcNow.ToString('o')
    lean_version = $version
    mathlib_commit = $mathlib.rev
    upstream_repository = 'https://github.com/huwngtran/thomson-n7-lean'
    upstream_commit = '25f2fa53119273458cfbb3c4230904bffdd61e53'
    upstream_source_sha256 = $expectedUpstreamHash
    bridge_source_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash.ToLowerInvariant()
    checker_source_sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $PSCommandPath).Hash.ToLowerInvariant()
    axioms = @('propext', 'Classical.choice', 'Quot.sound')
    target_type_definitionally_equal = $true
    lean_comparator_invoked = $false
    independent_kernel_recheck_of_bridge = $false
  } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'check-result.json') -Encoding utf8
}
finally {
  $env:LEAN_PATH = $oldLeanPath
}
