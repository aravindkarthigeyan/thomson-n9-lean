param([string]$Lake = 'lake')
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
Set-Location -LiteralPath $Root
$Log = Join-Path $PSScriptRoot 'SDP_BUILD.log'
$Targets = @(
    'ThomsonN9.SDP.Summation', 'ThomsonN9.SDP.CircleKernel',
    'ThomsonN9.SDP.ProjectionComplex', 'ThomsonN9.SDP.Counting',
    'ThomsonN9.SDP.GeometryBounds', 'ThomsonN9.SDP.ResidualBound',
    'ThomsonN9.SDP.RepeatedIndices', 'ThomsonN9.SDP.Symmetrization',
    'ThomsonN9.SDP.FactoredKernels', 'ThomsonN9.SDP.CertificateBound', 'ThomsonN9.Endgame',
    'ThomsonN9.SDP.PolynomialKernel'
)
foreach ($Target in $Targets) {
    Write-Output ('Building ' + $Target) | Tee-Object -FilePath $Log -Append
    & $Lake build $Target 2>&1 | Tee-Object -FilePath $Log -Append
    if ($LASTEXITCODE -ne 0) { throw ('Lean build failed: ' + $Target) }
}
Write-Output 'PASS: every new SDP and endgame module built serially.' | Tee-Object -FilePath $Log -Append
