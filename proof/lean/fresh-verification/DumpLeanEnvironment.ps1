$ErrorActionPreference = 'Stop'
[pscustomobject]@{
    leanPath = $env:LEAN_PATH
    leanSourcePath = $env:LEAN_SRC_PATH
    leanSysroot = $env:LEAN_SYSROOT
    leanNumThreads = $env:LEAN_NUM_THREADS
    leanExecutable = (Get-Command lean -CommandType Application).Source
} | ConvertTo-Json
