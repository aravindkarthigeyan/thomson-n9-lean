param(
    [ValidateSet('Plan', 'Freeze', 'Build')][string]$Mode = 'Plan',
    [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
    [Parameter(Mandatory = $true)][string]$SourceRoot,
    [Parameter(Mandatory = $true)][string]$SnapshotRoot,
    [Parameter(Mandatory = $true)][string]$ExternalPackages,
    [Parameter(Mandatory = $true)][string]$Lake,
    [Parameter(Mandatory = $true)][string]$Lean,
    [string]$Supplement,
    [string]$ProfileTable,
    [string]$ExpectedManifestSha256,
    [double]$MinFreeCommitGiB = 12.5,
    [double]$MinFreePhysicalGiB = 6.5,
    [int]$GateTimeoutSeconds = 7200
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Utf8 = [Text.UTF8Encoding]::new($false)
$PowerShell = (Get-Command powershell.exe -CommandType Application).Source
if ($MinFreeCommitGiB -lt 11.75 -or $MinFreePhysicalGiB -lt 6.5) {
    throw 'Adaptive verification requires large-gate commitment >=11.75 GiB and physical memory >=6.5 GiB.'
}
foreach ($Variable in @('WorkspaceRoot', 'SourceRoot', 'SnapshotRoot', 'ExternalPackages', 'Lake', 'Lean')) {
    Set-Variable -Name $Variable -Value ([IO.Path]::GetFullPath((Get-Variable $Variable -ValueOnly)))
}
function IsWithin([string]$Path, [string]$Directory) {
    $Prefix = $Directory.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    $Path.Equals($Directory, [StringComparison]::OrdinalIgnoreCase) -or
        $Path.StartsWith($Prefix, [StringComparison]::OrdinalIgnoreCase)
}
function AssertPlainPath([string]$Path) {
    $Cursor = [IO.Path]::GetFullPath($Path)
    while ($Cursor) {
        if (Test-Path -LiteralPath $Cursor) {
            $Item = Get-Item -LiteralPath $Cursor -Force
            if (($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw ('Source path traverses a reparse point: ' + $Cursor)
            }
        }
        $Cursor = Split-Path -Parent $Cursor
    }
}
function PlainFiles([string]$Directory) {
    AssertPlainPath $Directory
    foreach ($Item in (Get-ChildItem -LiteralPath $Directory -Force)) {
        if (($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw ('Unexpected reparse point: ' + $Item.FullName)
        }
        if ($Item.PSIsContainer) { PlainFiles $Item.FullName } else { $Item }
    }
}
function Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function AssertExecutingDriver([string]$ExecutingPath, $FrozenFiles) {
    AssertPlainPath $ExecutingPath
    $Rows = @($FrozenFiles | Where-Object { $_.path -ceq 'fresh-verification/FreezeRebuild.ps1' })
    if ($Rows.Count -ne 1 -or (Hash $ExecutingPath) -cne $Rows[0].sha256) {
        throw 'Executing clean-build driver does not match its frozen source hash.'
    }
}
function JsonFile([string]$Path, $Value) {
    [IO.File]::WriteAllText($Path, ($Value | ConvertTo-Json -Depth 20), $Utf8)
}
function NormalizeAxiom([string]$Printed) {
    $Name = $Printed.Trim()
    if ($Name -cin @('propext','Classical.choice','Quot.sound')) { return $Name }
    # Only the two observed one-universe spellings under pp.universes are aliases.
    if ($Name -ceq 'Classical.choice.{u}') { return 'Classical.choice' }
    if ($Name -ceq 'Quot.sound.{u}') { return 'Quot.sound' }
    throw ('Unexpected printed axiom: ' + $Printed)
}
function AssertAxiomReports([string]$Text,[string[]]$Requested) {
    $Expected = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($Name in $Requested) {
        if (-not $Expected.Add($Name)) { throw ('Duplicate requested axiom report: ' + $Name) }
    }
    $Seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $Pattern = "(?m)^'(\S+)' (?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)[\t\r ]*$"
    $Reports = [regex]::Matches($Text,$Pattern)
    foreach ($Report in $Reports) {
        $Name = $Report.Groups[1].Value
        if (-not $Expected.Contains($Name)) { throw ('Unexpected axiom report: ' + $Name) }
        if (-not $Seen.Add($Name)) { throw ('Duplicate printed axiom report: ' + $Name) }
        if ($Report.Groups[2].Success) {
            foreach ($Axiom in ($Report.Groups[2].Value -split ',')) { [void](NormalizeAxiom $Axiom) }
        }
    }
    $Markers = [regex]::Matches($Text,'depends on axioms:|does not depend on any axioms')
    if ($Markers.Count -ne $Reports.Count) { throw 'Malformed axiom report.' }
    foreach ($Name in $Requested) {
        if (-not $Seen.Contains($Name)) { throw ('Missing axiom report: ' + $Name) }
    }
}
function RelativeDestination([string]$Relative) {
    if ([IO.Path]::IsPathRooted($Relative)) { throw ('Absolute destination: ' + $Relative) }
    $Result = [IO.Path]::GetFullPath((Join-Path $SnapshotRoot $Relative))
    if (-not (IsWithin $Result $SnapshotRoot) -or $Result -eq $SnapshotRoot) {
        throw ('Destination escapes snapshot: ' + $Relative)
    }
    if ($Relative -match '(^|[\\/])\.lake([\\/]|$)' -or
        $Relative -match '\.(olean|ilean|o|obj|ir|trace)(\.|$)') {
        throw ('Proof object or build destination forbidden: ' + $Relative)
    }
    $Result
}
if (-not (IsWithin $SnapshotRoot $WorkspaceRoot) -or $SnapshotRoot -eq $WorkspaceRoot -or
    (IsWithin $SnapshotRoot $SourceRoot) -or (IsWithin $SourceRoot $SnapshotRoot)) {
    throw 'Snapshot must be a separate new directory inside the workspace.'
}
AssertPlainPath $SnapshotRoot
AssertPlainPath $ExternalPackages
$Inventory = [Collections.Generic.Dictionary[string,object]]::new([StringComparer]::OrdinalIgnoreCase)
function AddSource([string]$Path, [string]$Destination, [string]$Role) {
    AssertPlainPath $Path
    [void](RelativeDestination $Destination)
    if ($Inventory.ContainsKey($Destination)) { throw ('Duplicate destination: ' + $Destination) }
    $Item = Get-Item -LiteralPath $Path
    if ($Item.PSIsContainer) { throw ('Not a file: ' + $Path) }
    $Inventory.Add($Destination, [ordered]@{source=$Item.FullName; path=$Destination.Replace('\','/');
        role=$Role; bytes=$Item.Length; sha256=(Hash $Item.FullName)})
}
function AddPackageFile([IO.FileInfo]$File, [string]$Role) {
    AddSource $File.FullName ($File.FullName.Substring($SourceRoot.Length + 1)) $Role
}
if ($Mode -ne 'Build') {
    foreach ($File in (Get-ChildItem -LiteralPath $SourceRoot -File)) {
        if ($File.Extension -in @('.lean', '.md') -or $File.Name -match '(^|[._-])(LICENSE|COPYING|NOTICE)($|[._-])' -or
            $File.Name -in @('lean-toolchain','lakefile.toml','lake-manifest.json')) {
            AddPackageFile $File 'package source or metadata'
        }
    }
    foreach ($Directory in @('ThomsonN9','ClaudeWindow','ClaudeL1','ClaudeL2b','vendor')) {
        foreach ($File in (PlainFiles (Join-Path $SourceRoot $Directory))) {
            if ($File.Extension -in @('.lean','.md','.txt') -or $File.Name -match '(^|[._-])(LICENSE|COPYING|NOTICE)($|[._-])') {
                AddPackageFile $File 'local or imported proof source'
            }
        }
    }
    foreach ($File in (Get-ChildItem -LiteralPath (Join-Path $SourceRoot 'verification') -File)) {
        if ($File.Extension -eq '.ps1') { AddPackageFile $File 'verification script' }
        if ($File.Name -in @('RESOURCE_CONTROLS.md','SOURCE_AUDIT_REPAIR.md')) {
            AddPackageFile $File 'verification design and audit-scope documentation'
        }
    }
    foreach ($Name in @('FinalTargetAudit.lean','DumpLeanEnvironment.ps1','FreezeRebuild.ps1')) {
        AddSource (Join-Path $PSScriptRoot $Name) ('fresh-verification/' + $Name) 'fresh verification fixture'
    }
    if (-not $ProfileTable) { throw 'Adaptive Plan/Freeze requires an explicit immutable source-bound profile table.' }
    AddSource ([IO.Path]::GetFullPath($ProfileTable)) 'fresh-verification/MemoryProfiles.json' 'historical resource profiles; scheduling only, not proof premises'
    $ProvenanceDirectory = Join-Path (Split-Path -Parent $SourceRoot) 'verification'
    foreach ($Name in @('CLAUDE_FORMAL_IMPORT.json','CLAUDE_L1_IMPORT.json','CLAUDE_L2B_IMPORT.json')) {
        AddSource (Join-Path $ProvenanceDirectory $Name) ('frozen-provenance/' + $Name) 'source-import provenance, not a fresh build report'
    }
    $Tests = @()
    if ($Supplement) {
        $Extra = Get-Content -LiteralPath $Supplement -Raw | ConvertFrom-Json
        foreach ($File in $Extra.files) { AddSource $File.source $File.destination $File.role }
        $Tests = @($Extra.tests)
    }
    foreach ($Test in $Tests) {
        [void](RelativeDestination $Test.path)
        if (-not $Inventory.ContainsKey($Test.path)) { throw ('Test is not frozen: ' + $Test.path) }
        if ($Test.expectation -notin @('pass','reject')) { throw 'Invalid test expectation.' }
        if ($Test.expectation -eq 'reject' -and -not $Test.expectedDiagnostic) {
            throw 'Expected rejection requires a specific mathematical diagnostic.'
        }
        if ($Test.expectation -eq 'reject' -and @($Test.expectedErrorLines).Count -eq 0) {
            throw 'Expected rejection requires the exact permitted proof-error line numbers.'
        }
    }
    $Files = @($Inventory.Values | Sort-Object path)
    $ReadPatterns = 'readFile|readBinFile|include_str|include_bytes|run_io|IO\.FS'
    $Reads = @($Files | Where-Object { $_.path.EndsWith('.lean') } | ForEach-Object {
        Select-String -LiteralPath $_.source -Pattern $ReadPatterns
    })
    if ($Reads.Count) { throw ('Review compile-time data reads before freeze: ' + ($Reads -join '; ')) }
    . (Join-Path $SourceRoot 'verification/LeanSource.ps1')
    $Forbidden = '\b(sorry|admit|axiom|unsafe|native_decide|native_eval|implemented_by|ofReduceBool|ofReduceNat|extern)\b|\bdebug\.(skipKernelTC|byAsSorry)\b'
    foreach ($File in ($Files | Where-Object {$_.path.EndsWith('.lean')})) {
        $Code = [ThomsonN9LeanSourceV1]::CodeOnly([IO.File]::ReadAllText($File.source))
        if ($Code -match $Forbidden) { throw ('Forbidden proof shortcut in frozen source/fixture: ' + $File.path) }
    }
    if ($Mode -eq 'Plan') {
        [pscustomobject]@{mode='PLAN ONLY'; snapshot=$SnapshotRoot; files=$Files.Count;
            leanFiles=@($Files | Where-Object {$_.path.EndsWith('.lean')}).Count;
            supplementalTests=$Tests.Count; noCompilerLaunched=$true; filesWritten=0} | ConvertTo-Json
        exit 0
    }
    $Categories = @($Tests | ForEach-Object { $_.categories })
    foreach ($Category in @('bernstein','window','refined','lp','sos','hessian')) {
        if ($Category -cnotin $Categories) { throw ('Missing explicitly selected fresh control category: ' + $Category) }
    }
    if (Test-Path -LiteralPath $SnapshotRoot) { throw 'Freeze destination already exists; choose a new path.' }
    New-Item -ItemType Directory -Path $SnapshotRoot | Out-Null
    foreach ($File in $Files) {
        $Destination = RelativeDestination $File.path
        New-Item -ItemType Directory -Path (Split-Path -Parent $Destination) -Force | Out-Null
        Copy-Item -LiteralPath $File.source -Destination $Destination
        if ((Hash $Destination) -cne $File.sha256 -or (Hash $File.source) -cne $File.sha256) {
            throw ('Source changed while freezing: ' + $File.path)
        }
    }
    $Manifest = [ordered]@{schema=1; claim='source-only snapshot, NOT a build result';
        resourcePolicy='adaptive-v3 exact-source profiles; retained process handle';
        createdUtc=[DateTime]::UtcNow.ToString('o'); sourceRoot=$SourceRoot; snapshotRoot=$SnapshotRoot;
        externalPackages=$ExternalPackages; lake=$Lake; lean=$Lean;
        lakeSha256=(Hash $Lake); leanSha256=(Hash $Lean); files=$Files; tests=$Tests}
    JsonFile (Join-Path $SnapshotRoot 'FREEZE.json') $Manifest
    Write-Output ('FROZEN, NOT BUILT: ' + $SnapshotRoot)
    Write-Output ('Manifest SHA256: ' + (Hash (Join-Path $SnapshotRoot 'FREEZE.json')))
    exit 0
}

$ManifestPath = Join-Path $SnapshotRoot 'FREEZE.json'
if (-not $ExpectedManifestSha256 -or (Hash $ManifestPath) -cne $ExpectedManifestSha256) {
    throw 'Build requires the exact explicitly supplied frozen manifest SHA256.'
}
$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
AssertExecutingDriver $PSCommandPath $Manifest.files
foreach ($Pair in @(@($SourceRoot,$Manifest.sourceRoot),@($SnapshotRoot,$Manifest.snapshotRoot),
    @($ExternalPackages,$Manifest.externalPackages),@($Lake,$Manifest.lake),@($Lean,$Manifest.lean))) {
    if ($Pair[0] -cne $Pair[1]) { throw 'Build arguments do not match the frozen manifest.' }
}
if ((Hash $Lake) -cne $Manifest.lakeSha256 -or (Hash $Lean) -cne $Manifest.leanSha256) {
    throw 'Toolchain executable changed after freeze.'
}
function VerifyFrozenSources {
    foreach ($File in $Manifest.files) {
        if ((Hash (RelativeDestination $File.path)) -cne $File.sha256) { throw ('Frozen source changed: ' + $File.path) }
    }
    $ExpectedLean = @($Manifest.files | Where-Object { $_.path.EndsWith('.lean') } | ForEach-Object {$_.path})
    $ActualLean = @(
        Get-ChildItem -LiteralPath $SnapshotRoot -Filter '*.lean' -File
        foreach ($Directory in @('ThomsonN9','ClaudeWindow','ClaudeL1','ClaudeL2b','vendor','fresh-verification','frozen-tests')) {
            $Path = Join-Path $SnapshotRoot $Directory
            if (Test-Path -LiteralPath $Path) { PlainFiles $Path | Where-Object {$_.Extension -eq '.lean'} }
        }
    ) | ForEach-Object {$_.FullName.Substring($SnapshotRoot.Length+1).Replace('\','/')}
    foreach ($Path in $ActualLean) {
        if ($Path -cnotin $ExpectedLean) { throw ('Unfrozen Lean source in snapshot: ' + $Path) }
    }
}
VerifyFrozenSources
$ResourceProfiles = Get-Content -LiteralPath (Join-Path $SnapshotRoot 'fresh-verification/MemoryProfiles.json') -Raw | ConvertFrom-Json
$ModuleSources = @{}
foreach ($File in $Manifest.files) {
    if ($File.path.EndsWith('.lean') -and $File.path -notmatch '^(fresh-verification|frozen-tests)/') {
        $Module = $File.path -replace '^vendor/','' -replace '\.lean$','' -replace '/','.'
        if ($ModuleSources.ContainsKey($Module)) { throw ('Duplicate resource-policy module: ' + $Module) }
        $ModuleSources[$Module] = $File
    }
}
if (Test-Path -LiteralPath (Join-Path $SnapshotRoot '.lake')) {
    throw 'Build requires an initially absent local .lake directory; use a new source-only snapshot.'
}
$Run = Join-Path $SnapshotRoot ('fresh-evidence/' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ'))
New-Item -ItemType Directory -Path $Run -Force | Out-Null
$Lock = Get-Content -LiteralPath (Join-Path $SnapshotRoot 'lake-manifest.json') -Raw | ConvertFrom-Json
$DependencyReports = @()
foreach ($Package in $Lock.packages) {
    if ($Package.type -cne 'git') { throw 'Only pinned git dependencies are supported.' }
    $Path = Join-Path $ExternalPackages $Package.name
    AssertPlainPath $Path
    $Head = @(& git -C $Path rev-parse HEAD)
    if ($LASTEXITCODE -ne 0 -or $Head.Count -ne 1 -or $Head[0] -cne $Package.rev) { throw ('Dependency revision mismatch: ' + $Package.name) }
    $Dirty = @(& git -C $Path status --porcelain --untracked-files=no)
    if ($LASTEXITCODE -ne 0 -or $Dirty.Count) { throw ('Dirty dependency: ' + $Package.name) }
    $ExtraLean = @(& git -C $Path ls-files --others --exclude-standard -- '*.lean')
    if ($LASTEXITCODE -ne 0 -or $ExtraLean.Count) { throw ('Untracked Lean dependency source: ' + $Package.name) }
    $Origin = @(& git -C $Path remote get-url origin)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read dependency origin.' }
    $DependencyReports += [ordered]@{name=$Package.name; url=$Package.url; origin=$Origin; rev=$Head[0]; path=$Path}
}
JsonFile (Join-Path $Run 'dependencies.json') $DependencyReports
function ExternalObjectInventory([string]$Output) {
    $Rows = [Collections.Generic.List[object]]::new()
    $Directories = [Collections.Generic.List[object]]::new()
    foreach ($Package in $Lock.packages) {
        $Directory = Join-Path (Join-Path $ExternalPackages $Package.name) '.lake/build/lib/lean'
        $Present = Test-Path -LiteralPath $Directory -PathType Container
        $Directories.Add([ordered]@{package=$Package.name; directory=$Directory; present=$Present;
            status=$(if ($Present) {'cached object directory present'} else {'no cached object directory; not a build result'})})
        if (-not $Present) { continue }
        foreach ($Item in (PlainFiles $Directory)) {
            $Relative = $Item.FullName.Substring($ExternalPackages.Length + 1).Replace('\','/')
            if ($Relative -match '/(ThomsonN9|ClaudeL1|ClaudeL2b|ClaudeWindow|Delsarte|Solution|Challenge)(/|\.)') {
                throw ('Local proof root found in external dependency cache: ' + $Relative)
            }
            if ($Item.Name -match '\.(olean|ilean)(\.|$)') {
                $Rows.Add([ordered]@{path=$Relative; bytes=$Item.Length; sha256=(Hash $Item.FullName)})
            }
        }
    }
    JsonFile $Output @($Rows.ToArray() | Sort-Object path)
    JsonFile ([IO.Path]::ChangeExtension($Output, '.directories.json')) @($Directories.ToArray())
}
ExternalObjectInventory (Join-Path $Run 'external-objects-before.json')
New-Item -ItemType Directory -Path (Join-Path $SnapshotRoot '.lake') | Out-Null
New-Item -ItemType Junction -Path (Join-Path $SnapshotRoot '.lake/packages') -Target $ExternalPackages | Out-Null
$SavedLeanPath = $env:LEAN_PATH
$SavedLeanSourcePath = $env:LEAN_SRC_PATH
$SavedLeanNumThreads = $env:LEAN_NUM_THREADS
$SavedPath = $env:PATH
$env:LEAN_PATH = $null
$env:LEAN_SRC_PATH = $null
$env:LEAN_NUM_THREADS = '1'
$env:PATH = (Split-Path -Parent $Lean) + ';' + $env:PATH
$Sequence = 0
$Reports = [Collections.Generic.List[object]]::new()
function SameArguments([string[]]$Actual,[string[]]$Expected) {
    if ($Actual.Count -ne $Expected.Count) { return $false }
    for ($Index=0; $Index -lt $Actual.Count; $Index++) {
        if ($Actual[$Index] -cne $Expected[$Index]) { return $false }
    }
    return $true
}
function AssertPolicySource([string]$Path) {
    $Rows = @($Manifest.files | Where-Object {$_.path -ceq $Path})
    if ($Rows.Count -ne 1 -or (Hash (Join-Path $SnapshotRoot $Path)) -cne $Rows[0].sha256) {
        throw ('Resource policy requires exact frozen source: ' + $Path)
    }
    return $Rows[0].sha256
}
function GetResourcePolicy([string]$Name,[string]$Executable,[string[]]$Arguments) {
    $Policy = [ordered]@{classification='unprofiled-large'; gateGiB=$MinFreeCommitGiB;
        physicalFloorGiB=$MinFreePhysicalGiB; reason='No exact named command and source-bound profile';
        module=$null; sourceSha256=$null; helperSha256=$null; baselines=@()}
    $ProfileModule = $null
    if ($Executable -ceq $Lake -and (SameArguments $Arguments @('build',('+'+$Name)))) {
        $ProfileModule = $Name
    } elseif ($Name -ceq 'all-axioms' -and $Executable -ceq $PowerShell -and
        (SameArguments $Arguments @('-NoProfile','-ExecutionPolicy','Bypass','-File','verification/CheckAxioms.ps1','-Lake',$Lake,'-LogName','FRESH_AXIOMS.log'))) {
        $ProfileModule = 'Solution'
        $Policy.helperSha256 = AssertPolicySource 'verification/CheckAxioms.ps1'
    } elseif ($Name -cin @('source-scanner-tests','source-audit') -and $Executable -ceq $PowerShell) {
        $Helper = if ($Name -ceq 'source-scanner-tests') {'verification/TestSourceScanner.ps1'} else {'verification/CheckSource.ps1'}
        if (SameArguments $Arguments @('-NoProfile','-ExecutionPolicy','Bypass','-File',$Helper)) {
            $Policy.helperSha256 = AssertPolicySource $Helper
            $Policy.classification = 'explicit-noncompiler-scanner'
            $Policy.gateGiB = 8.5
            $Policy.reason = 'Reviewed named frozen source-only scanner; no Lean invocation'
        }
        return $Policy
    } elseif ($Name -ceq 'default-targets' -and $Executable -ceq $Lake -and (SameArguments $Arguments @('build'))) {
        $Passed = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($Prior in $Reports) { if ($Prior.passed) { [void]$Passed.Add($Prior.name) } }
        if ($Targets.Count -eq $ModuleSources.Count -and $Targets.Count -gt 0 -and
            @($Targets | Where-Object {-not $Passed.Contains($_)}).Count -eq 0) {
            $Policy.classification = 'completed-module-cache-check'
            $Policy.gateGiB = 8.5
            $Policy.reason = 'Every exact local target already passed serially in this run'
        }
        return $Policy
    }
    if (-not $ProfileModule -or -not $ModuleSources.ContainsKey($ProfileModule)) { return $Policy }
    $Source = $ModuleSources[$ProfileModule]
    $SourceHash = AssertPolicySource $Source.path
    if (-not $ResourceProfiles.PSObject.Properties['measured']) { return $Policy }
    $Profile = @($ResourceProfiles.measured | Where-Object {
        $_ -and $_.PSObject.Properties['module'] -and $_.PSObject.Properties['sourceSha256'] -and
        $_.module -ceq $ProfileModule -and $_.sourceSha256 -ceq $SourceHash
    })
    if ($Profile.Count -ne 1) { return $Policy }
    if (-not $Profile[0].PSObject.Properties['observations']) { return $Policy }
    $Valid = @($Profile[0].observations | Where-Object {
        if (-not $_ -or -not $_.PSObject.Properties['metric'] -or
            -not $_.PSObject.Properties['peakBytes']) { return $false }
        $Peak = 0L
        $_.metric -cin @('single-process-private','sampled-owned-tree-commit') -and
            [long]::TryParse([string]$_.peakBytes,[ref]$Peak) -and $Peak -gt 0
    })
    if ($Valid.Count -eq 0 -or $Valid.Count -ne @($Profile[0].observations).Count) { return $Policy }
    $Baselines = @(
        foreach ($Metric in @('single-process-private','sampled-owned-tree-commit')) {
            $Values = @($Valid | Where-Object {$_.metric -ceq $Metric})
            if ($Values.Count) {
                [ordered]@{metric=$Metric; peakBytes=($Values | Measure-Object -Property peakBytes -Maximum).Maximum}
            }
        }
    )
    $Policy.classification = 'exact-source-profile'
    $Policy.module = $ProfileModule
    $Policy.sourceSha256 = $SourceHash
    $Policy.baselines = $Baselines
    $SmallEligible = @($Baselines | Where-Object {
        ($_.metric -ceq 'single-process-private' -and $_.peakBytes -gt 5GB) -or
        ($_.metric -ceq 'sampled-owned-tree-commit' -and $_.peakBytes -gt 6GB)
    }).Count -eq 0
    if ($ProfileModule -ceq 'ThomsonN9.Certificates.AmbientKernelData') {
        $Policy.gateGiB = $MinFreeCommitGiB
    } elseif ($ProfileModule -ceq 'ThomsonN9.Certificates.AmbientKernelAssembly') {
        $Direct = @($Baselines | Where-Object {$_.metric -ceq 'single-process-private'})
        if ($Direct.Count -eq 1 -and $Direct[0].peakBytes -le 6GB -and
            @($Baselines | Where-Object {$_.metric -ceq 'sampled-owned-tree-commit' -and $_.peakBytes -gt 7GB}).Count -eq 0) {
            $Policy.gateGiB = 9.5
        }
    } elseif ($SmallEligible) {
        $Policy.gateGiB = 8.5
    }
    $Policy.reason = 'Exact module/source SHA; reduced gates require direct <=5 GiB/tree <=6 GiB, or Assembly direct <=6 GiB; metric-specific growth check after exit'
    return $Policy
}
function GetProfileGrowth($Policy,[long]$TreePrivate,[long]$LargestPrivate) {
    foreach ($Baseline in $Policy.baselines) {
        $Observed = if ($Baseline.metric -ceq 'single-process-private') {$LargestPrivate} else {$TreePrivate}
        if ($Observed -le 0 -or $Observed -gt 1.25 * $Baseline.peakBytes) {
            [ordered]@{metric=$Baseline.metric; baselineBytes=$Baseline.peakBytes;
                observedBytes=$Observed; limitBytes=1.25 * $Baseline.peakBytes;
                reason=$(if ($Observed -le 0) {'No owned-process sample for required metric'} else {'Comparable peak grew by more than 25%'})}
        }
    }
}
function ProcessIdentity($ProcessRow) {
    return $ProcessRow.CreationDate.ToUniversalTime().Ticks.ToString([Globalization.CultureInfo]::InvariantCulture)
}
function IsOwnedProcess($ProcessRow,$Owned) {
    return $Owned.ContainsKey([int]$ProcessRow.ProcessId) -and
        $Owned[[int]$ProcessRow.ProcessId] -ceq (ProcessIdentity $ProcessRow)
}
function IsStartedRoot($ProcessRow,[int]$StartedId,[DateTime]$StartedAt,[bool]$HasExited) {
    if ($HasExited -or -not $ProcessRow -or [int]$ProcessRow.ProcessId -ne $StartedId) { return $false }
    # CIM truncates its creation timestamp to microseconds; allow that reporting precision only.
    $Delta = $StartedAt.ToUniversalTime().Ticks - $ProcessRow.CreationDate.ToUniversalTime().Ticks
    return $Delta -ge 0 -and $Delta -lt 10
}
function UpdateOwnedProcesses($All,$Owned) {
    $Current = @{}
    foreach ($Row in $All) { $Current[[int]$Row.ProcessId] = $Row }
    do {
        $Added = $false
        foreach ($Row in $All) {
            $ParentId = [int]$Row.ParentProcessId
            if (-not $Owned.ContainsKey($ParentId) -or -not $Current.ContainsKey($ParentId)) { continue }
            if ($Owned[$ParentId] -cne (ProcessIdentity $Current[$ParentId])) { continue }
            if ($Row.CreationDate -lt $Current[$ParentId].CreationDate) { continue }
            $ChildId = [int]$Row.ProcessId
            $Identity = ProcessIdentity $Row
            if (-not $Owned.ContainsKey($ChildId) -or $Owned[$ChildId] -cne $Identity) {
                $Owned[$ChildId] = $Identity
                $Added = $true
            }
        }
    } while ($Added)
}
function WaitForMemory([double]$RequiredCommitGiB) {
    $Watch = [Diagnostics.Stopwatch]::StartNew()
    do {
        $Memory = Get-CimInstance Win32_PerfFormattedData_PerfOS_Memory
        $Commit = ([double]$Memory.CommitLimit - [double]$Memory.CommittedBytes) / 1GB
        $Physical = [double]$Memory.AvailableBytes / 1GB
        if ($Commit -ge $RequiredCommitGiB -and $Physical -ge $MinFreePhysicalGiB) { return }
        if ($Watch.Elapsed.TotalSeconds -gt $GateTimeoutSeconds) { throw 'Memory gate timed out; no module was launched.' }
        Write-Host ('Waiting for memory: commit {0:N2}/{1:N2} GiB; physical {2:N2}/{3:N2} GiB.' -f $Commit,$RequiredCommitGiB,$Physical,$MinFreePhysicalGiB)
        Start-Sleep -Seconds 30
    } while ($true)
}
function QuoteArgument([string]$Value) {
    if ($Value.Contains('"') -or $Value.EndsWith('\')) { throw 'Unsupported quoted process argument.' }
    '"' + $Value + '"'
}
function RunChecked([string]$Name,[string]$Executable,[string[]]$Arguments,
    [string]$Expectation='pass',[string]$ExpectedDiagnostic='', [int[]]$ExpectedErrorLines=@()) {
    if ($env:LEAN_NUM_THREADS -cne '1') { throw 'Single-worker runtime environment was changed.' }
    $Policy = GetResourcePolicy $Name $Executable $Arguments
    WaitForMemory $Policy.gateGiB
    $script:Sequence++
    $Base = Join-Path $Run ('{0:D4}-{1}' -f $script:Sequence,($Name -replace '[^A-Za-z0-9_.-]','_'))
    $Watch = [Diagnostics.Stopwatch]::StartNew()
    $Process = Start-Process -FilePath $Executable -ArgumentList (($Arguments | ForEach-Object {QuoteArgument $_}) -join ' ') -WorkingDirectory $SnapshotRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput ($Base+'.stdout.log') -RedirectStandardError ($Base+'.stderr.log')
    # Windows PowerShell 5.1 needs an eagerly retained handle for ExitCode after Refresh/exit.
    $ProcessHandle = $Process.Handle
    $Owned = [Collections.Generic.Dictionary[int,string]]::new()
    $StartedAt = try {$Process.StartTime} catch {[DateTime]::MinValue}
    $RootRow = Get-CimInstance Win32_Process -Filter ('ProcessId = ' + $Process.Id)
    if (IsStartedRoot $RootRow $Process.Id $StartedAt $Process.HasExited) {
        $Owned[$Process.Id] = ProcessIdentity $RootRow
    }
    $PeakPrivate = 0L
    $PeakWorking = 0L
    $PeakLargestPrivate = 0L
    while (-not $Process.HasExited) {
        $All = @(Get-CimInstance Win32_Process)
        UpdateOwnedProcesses $All $Owned
        $Private = 0L
        $Working = 0L
        foreach ($Child in $All) {
            if (IsOwnedProcess $Child $Owned) {
                $Private += [long]$Child.PrivatePageCount
                $Working += [long]$Child.WorkingSetSize
                $PeakLargestPrivate = [Math]::Max($PeakLargestPrivate,[long]$Child.PrivatePageCount)
            }
        }
        $PeakPrivate = [Math]::Max($PeakPrivate,$Private)
        $PeakWorking = [Math]::Max($PeakWorking,$Working)
        Start-Sleep -Milliseconds 1000
        $Process.Refresh()
    }
    $Process.WaitForExit()
    $Code = $Process.ExitCode
    $Process.Dispose()
    if ($null -eq $Code -or $Code -isnot [int]) {
        throw ('INCOMPLETE_PROCESS_STATUS: No integer exit code was captured for ' + $Name)
    }
    $Text = [IO.File]::ReadAllText($Base+'.stdout.log') + [IO.File]::ReadAllText($Base+'.stderr.log')
    $Passed = if ($Expectation -eq 'pass') {$Code -eq 0} else {
        $Code -ne 0 -and $Text -match $ExpectedDiagnostic -and
            $Text -notmatch 'unknown module|unknown package|object file.*does not exist|out of memory|stack overflow|failed to create|maximum recursion depth'
    }
    if ($Expectation -eq 'reject') {
        $Errors = [regex]::Matches($Text,'(?m)^([^\r\n]+):(\d+):(\d+): error:')
        if ($Errors.Count -eq 0) { $Passed = $false }
        foreach ($DiagnosticError in $Errors) {
            if ([IO.Path]::GetFileName($DiagnosticError.Groups[1].Value) -cne [IO.Path]::GetFileName($Name) -or
                [int]$DiagnosticError.Groups[2].Value -notin $ExpectedErrorLines) { $Passed = $false }
        }
    }
    $Growth = @(GetProfileGrowth $Policy $PeakPrivate $PeakLargestPrivate)
    if ($Growth.Count -gt 0) { $Passed = $false }
    $Report = [ordered]@{name=$Name; executable=$Executable; arguments=$Arguments; exitCode=$Code;
        expectation=$Expectation; passed=$Passed; seconds=$Watch.Elapsed.TotalSeconds;
        sampledPeakPrivateBytes=$PeakPrivate; sampledPeakWorkingBytes=$PeakWorking;
        sampledLargestOwnedPrivateBytes=$PeakLargestPrivate; resourcePolicy=$Policy;
        resourceOutcome=$(if ($Growth.Count) {'INCONCLUSIVE_RESOURCE'} else {'WITHIN_SAMPLED_PROFILE_OR_UNPROFILED'});
        profileGrowthViolations=$Growth; ownedProcessIdentities=@($Owned.GetEnumerator() | ForEach-Object {
            [ordered]@{pid=$_.Key; creationUtcTicks=$_.Value}});
        stdout=$Base+'.stdout.log'; stderr=$Base+'.stderr.log';
        stdoutSha256=(Hash ($Base+'.stdout.log')); stderrSha256=(Hash ($Base+'.stderr.log'));
        effectiveEnvironment=@{LEAN_NUM_THREADS=$env:LEAN_NUM_THREADS};
        compilerThreadControl='explicit -j1 for direct Lean; package moreLeanArgs=-j1 for Lake builds'}
    $Reports.Add($Report)
    JsonFile ($Base+'.json') $Report
    JsonFile (Join-Path $Run 'steps.json') @($Reports.ToArray())
    if ($Growth.Count -gt 0) {
        throw ('INCONCLUSIVE_RESOURCE: ' + $Name + ' lacks a required owned-process sample or exceeded its comparable historical peak by more than 25%; use a new large-gate run.')
    }
    if (-not $Passed) { throw ('Step failed: ' + $Name + ', exit ' + $Code) }
    Write-Host ('PASS: ' + $Name)
    return $Text
}
try {
    Set-Location -LiteralPath $SnapshotRoot
    $LeanVersion = @(& $Lean --version)
    if ($LASTEXITCODE -ne 0) { throw 'Lean version command failed.' }
    $LakeVersion = @(& $Lake --version)
    if ($LASTEXITCODE -ne 0) { throw 'Lake version command failed.' }
    $Version = @($LeanVersion) + @($LakeVersion)
    JsonFile (Join-Path $Run 'toolchain.json') @{version=$Version; leanSha256=(Hash $Lean); lakeSha256=(Hash $Lake);
        driverSha256=(Hash $PSCommandPath);
        resourceProfileSha256=(Hash (Join-Path $SnapshotRoot 'fresh-verification/MemoryProfiles.json'));
        effectiveEnvironment=@{LEAN_NUM_THREADS=$env:LEAN_NUM_THREADS}; compilerThreadArgument='-j1'}
    $Environment = & $Lake env $PowerShell -NoProfile -ExecutionPolicy Bypass -File fresh-verification/DumpLeanEnvironment.ps1
    if ($LASTEXITCODE -ne 0) { throw 'Cannot obtain isolated Lake environment.' }
    $EnvironmentText = $Environment -join "`n"
    [IO.File]::WriteAllText((Join-Path $Run 'lake-environment.json'),$EnvironmentText,$Utf8)
    $ParsedEnvironment = $EnvironmentText | ConvertFrom-Json
    if ($ParsedEnvironment.leanNumThreads -cne '1') { throw 'Lake did not preserve LEAN_NUM_THREADS=1.' }
    if ([IO.Path]::GetFullPath($ParsedEnvironment.leanExecutable) -cne $Lean) { throw 'Lake resolves a different Lean executable.' }
    foreach ($PathText in ($ParsedEnvironment.leanPath -split ';')) {
        if (-not $PathText) { continue }
        $Path = if ([IO.Path]::IsPathRooted($PathText)) {[IO.Path]::GetFullPath($PathText)} else {
            [IO.Path]::GetFullPath((Join-Path $SnapshotRoot $PathText))
        }
        if (-not ((IsWithin $Path (Join-Path $SnapshotRoot '.lake/build/lib/lean')) -or
            (IsWithin $Path (Join-Path $SnapshotRoot '.lake/packages')) -or
            (IsWithin $Path $ExternalPackages) -or (IsWithin $Path (Split-Path -Parent (Split-Path -Parent $Lean))))) {
            throw ('Unapproved Lean import path: ' + $Path)
        }
    }
    foreach ($PathText in ($ParsedEnvironment.leanSourcePath -split ';')) {
        if (-not $PathText) { continue }
        $Path = if ([IO.Path]::IsPathRooted($PathText)) {[IO.Path]::GetFullPath($PathText)} else {
            [IO.Path]::GetFullPath((Join-Path $SnapshotRoot $PathText))
        }
        if (-not ((IsWithin $Path $SnapshotRoot) -or (IsWithin $Path $ExternalPackages) -or
            (IsWithin $Path (Split-Path -Parent (Split-Path -Parent $Lean))))) {
            throw ('Unapproved Lean source path: ' + $Path)
        }
    }
    $Targets = @(& $PowerShell -NoProfile -ExecutionPolicy Bypass -File verification/Build.ps1 -ListTargets)
    if ($LASTEXITCODE -ne 0) { throw 'Cannot derive complete topological target list.' }
    [IO.File]::WriteAllLines((Join-Path $Run 'targets.txt'),[string[]]$Targets,$Utf8)
    foreach ($Target in $Targets) { [void](RunChecked $Target $Lake @('build',('+'+$Target))) }
    [void](RunChecked 'default-targets' $Lake @('build'))
    [void](RunChecked 'source-scanner-tests' $PowerShell @('-NoProfile','-ExecutionPolicy','Bypass','-File','verification/TestSourceScanner.ps1'))
    [void](RunChecked 'source-audit' $PowerShell @('-NoProfile','-ExecutionPolicy','Bypass','-File','verification/CheckSource.ps1'))
    [void](RunChecked 'all-axioms' $PowerShell @('-NoProfile','-ExecutionPolicy','Bypass','-File','verification/CheckAxioms.ps1','-Lake',$Lake,'-LogName','FRESH_AXIOMS.log'))
    $FinalText = RunChecked 'final-target-types' $Lake @('env',$Lean,'-j1','fresh-verification/FinalTargetAudit.lean')
    AssertAxiomReports $FinalText @('ThomsonN9.thomson_nine_complete','ThomsonN9.thomson_nine',
        'ThomsonN9.thomson_nine_unique','ThomsonN9.optimalConfiguration_admissible',
        'ThomsonN9.thomson_nine_fixed','ThomsonN9.thomson_nine_fixed_unique')
    [void](RunChecked 'corrupt-coefficient' $PowerShell @('-NoProfile','-ExecutionPolicy','Bypass','-File','verification/RejectCorruptCoefficient.ps1','-Lake',$Lake))
    foreach ($Test in $Manifest.tests) {
        $Diagnostic = if ($Test.expectation -eq 'reject') {$Test.expectedDiagnostic} else {''}
        $ErrorLines = if ($Test.expectation -eq 'reject') {@($Test.expectedErrorLines)} else {@()}
        $TestText = RunChecked $Test.path $Lake @('env',$Lean,'-j1',$Test.path) $Test.expectation $Diagnostic $ErrorLines
        if ($Test.expectation -eq 'pass') {
            $Requested = @(Select-String -LiteralPath (Join-Path $SnapshotRoot $Test.path) -Pattern '^#print axioms\s+(\S+)' |
                ForEach-Object {$_.Matches[0].Groups[1].Value})
            AssertAxiomReports $TestText $Requested
        }
    }
    VerifyFrozenSources
    $Objects = @()
    foreach ($Target in $Targets) {
        $Path = Join-Path $SnapshotRoot ('.lake/build/lib/lean/' + $Target.Replace('.','/') + '.olean')
        if (-not (Test-Path -LiteralPath $Path)) { throw ('Missing fresh module object: ' + $Target) }
        foreach ($Object in (Get-ChildItem -LiteralPath (Split-Path -Parent $Path) -File)) {
            $Stem = [IO.Path]::GetFileNameWithoutExtension($Path)
            if ($Object.Name -eq ($Stem+'.olean') -or $Object.Name.StartsWith($Stem+'.olean.') -or
                $Object.Name -eq ($Stem+'.ilean')) {
                $Objects += [ordered]@{module=$Target; path=$Object.FullName.Substring($SnapshotRoot.Length+1).Replace('\','/');
                    sha256=(Hash $Object.FullName)}
            }
        }
    }
    JsonFile (Join-Path $Run 'local-objects.json') $Objects
    ExternalObjectInventory (Join-Path $Run 'external-objects-after.json')
    $ExternalBefore = Get-Content -LiteralPath (Join-Path $Run 'external-objects-before.json') -Raw | ConvertFrom-Json
    $ExternalAfter = Get-Content -LiteralPath (Join-Path $Run 'external-objects-after.json') -Raw | ConvertFrom-Json
    $AfterMap = @{}
    foreach ($Object in $ExternalAfter) { $AfterMap[$Object.path] = $Object.sha256 }
    foreach ($Object in $ExternalBefore) {
        if (-not $AfterMap.ContainsKey($Object.path) -or $AfterMap[$Object.path] -cne $Object.sha256) {
            throw ('Previously cached external object changed: ' + $Object.path)
        }
    }
    $BeforeNames = @($ExternalBefore | ForEach-Object {$_.path})
    JsonFile (Join-Path $Run 'external-objects-newly-built.json') @($ExternalAfter | Where-Object {$_.path -cnotin $BeforeNames})
    AssertExecutingDriver $PSCommandPath $Manifest.files
    $EvidenceFiles = @(
        foreach ($File in (Get-ChildItem -LiteralPath $Run -Force | Sort-Object Name)) {
            AssertPlainPath $File.FullName
            if ($File.PSIsContainer) { throw 'Fresh evidence must be a flat file inventory.' }
            if ($File.Name -ceq 'RESULT.json') { continue }
            [ordered]@{path=$File.Name; bytes=$File.Length; sha256=(Hash $File.FullName)}
        }
    )
    JsonFile (Join-Path $Run 'RESULT.json') @{status='PASS'; claim='clean project-source rebuild with pinned cached external dependencies';
        manifestSha256=$ExpectedManifestSha256; modules=$Targets.Count; supplementalTests=@($Manifest.tests).Count;
        stepsSha256=(Hash (Join-Path $Run 'steps.json')); targetsSha256=(Hash (Join-Path $Run 'targets.txt'));
        driverSha256=(Hash $PSCommandPath); evidenceFiles=$EvidenceFiles;
        finalTheoremsChecked=6; completedUtc=[DateTime]::UtcNow.ToString('o')}
    Write-Output ('COMPLETE CLEAN PROJECT-SOURCE VERIFICATION: ' + $Run)
} catch {
    $Status = if ($_.Exception.Message.StartsWith('INCONCLUSIVE_RESOURCE:')) {'INCONCLUSIVE_RESOURCE'} else {'INCOMPLETE'}
    JsonFile (Join-Path $Run 'RESULT.json') @{status=$Status; error=$_.Exception.Message; completedUtc=[DateTime]::UtcNow.ToString('o')}
    throw
} finally {
    $env:LEAN_PATH = $SavedLeanPath
    $env:LEAN_SRC_PATH = $SavedLeanSourcePath
    $env:LEAN_NUM_THREADS = $SavedLeanNumThreads
    $env:PATH = $SavedPath
}
