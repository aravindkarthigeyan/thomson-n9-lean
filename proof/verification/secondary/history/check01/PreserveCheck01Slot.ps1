$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$slot = [IO.Path]::GetFullPath((Join-Path $root 'work/n9-independent-verification/.lean_slot'))
$dest = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'preserved-check01-slot'))
$work = [IO.Path]::GetFullPath((Join-Path $root 'work')) + [IO.Path]::DirectorySeparatorChar
foreach ($p in @($slot, $dest)) {
    if (-not $p.StartsWith($work, [StringComparison]::OrdinalIgnoreCase)) { throw 'Outside intended work directory' }
    $cursor = $p
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Reparse path refused' }
        }
        $cursor = [IO.Path]::GetDirectoryName($cursor)
    }
}
if (Test-Path -LiteralPath $dest) { throw 'Preservation destination already exists' }
$resultPath = Join-Path $PSScriptRoot 'runs/n9-complete-v4-20261006-check-01/process/result.json'
$resultHash = (Get-FileHash -LiteralPath $resultPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($resultHash -cne 'f809dcdd18b4b13fe41b337a481704b04a06d5fec075dacbade56d7a790fa66f') { throw 'Unexpected timeout result' }
$result = Get-Content -Raw -LiteralPath $resultPath | ConvertFrom-Json
if ($result.outcome -cne 'INCONCLUSIVE_TIMEOUT' -or $result.cleanup_complete -ne $true -or $result.manifest_unchanged -ne $true -or @($result.changed_bindings).Count -ne 0) { throw 'Timeout cleanup not confirmed' }
$running = @(Get-Process -Name bash,lean,lake,nanoda_bin,lean4export -ErrorAction SilentlyContinue)
if ($running.Count -ne 0) { throw 'Relevant process still running' }
$items = @(Get-ChildItem -LiteralPath $slot -Force)
if ($items.Count -ne 1 -or $items[0].Name -cne 'owner.txt' -or $items[0].PSIsContainer) { throw 'Unexpected slot contents' }
$source = Join-Path $slot 'owner.txt'
if ((Get-Item -LiteralPath $source -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Owner is a reparse point' }
$owner = Get-Content -Raw -LiteralPath $source
if ($owner.Trim() -cne 'second_kernel run n9-complete-v4-20261006-export-01 pid 6873 since 2026-10-06T09:55:49-04:00') { throw 'Different owner' }
$hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
$size = (Get-Item -LiteralPath $source).Length
[IO.Directory]::CreateDirectory($dest) | Out-Null
$target = Join-Path $dest 'owner.txt'
[IO.File]::Copy($source, $target, $false)
if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant() -cne $hash -or (Get-Item -LiteralPath $target).Length -ne $size) { throw 'Preserved bytes differ' }
if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -cne $hash) { throw 'Owner changed before removal' }
if (@(Get-Process -Name bash,lean,lake,nanoda_bin,lean4export -ErrorAction SilentlyContinue).Count -ne 0) { throw 'Relevant process appeared' }
Remove-Item -LiteralPath $source -ErrorAction Stop
if (@(Get-ChildItem -LiteralPath $slot -Force).Count -ne 0) { throw 'Slot not empty; preserve it' }
Remove-Item -LiteralPath $slot -ErrorAction Stop
$receipt = [ordered]@{
    status = 'OWNED_TIMEOUT_SLOT_PRESERVED_AND_EMPTY_DIRECTORY_REMOVED'
    source = $source
    preserved = $target
    bytes = $size
    sha256 = $hash
    timeoutResult = $resultPath
    timeoutResultSha256 = $resultHash
    ownedCleanupConfirmed = $true
    noRelevantProcessObservedTwice = $true
    recursiveDeletion = $false
    proofSourcesOrObjectsChanged = $false
    completedUtc = [DateTime]::UtcNow.ToString('o')
}
$json = $receipt | ConvertTo-Json -Depth 5
$receiptPath = Join-Path $dest 'RECEIPT.json'
$stream = [IO.File]::Open($receiptPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
try {
    $bytes = [Text.UTF8Encoding]::new($false).GetBytes($json)
    $stream.Write($bytes, 0, $bytes.Length)
} finally { $stream.Dispose() }
$json
