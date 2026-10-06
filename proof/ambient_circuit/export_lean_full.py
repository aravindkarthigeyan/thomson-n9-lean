"""Emit modular, ordinary-kernel checks for every frozen ambient trace node.

Generation is untrusted. Each 128-node arithmetic declaration is discharged by
ordinary decide. Separate coverage/soundness lemmas consume those declarations.
No Hessian semantic identity is asserted here.
"""
import argparse
import hashlib
import json
from pathlib import Path

from export_lean_trial import bound, operation, ROOT, WORK


def write(path, lines):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text('\n'.join(lines)+'\n',encoding='utf-8')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--circuit',type=Path,
                        default=Path(__file__).with_name('ambient-circuit-k0.json'))
    parser.add_argument('--directory',type=Path,default=WORK)
    parser.add_argument('--data-block-size',type=int,default=16)
    parser.add_argument('--check-block-size',type=int,default=128)
    parser.add_argument('--checks-per-module',type=int,default=32)
    args = parser.parse_args()
    assert 1 <= args.data_block_size <= 128
    assert 1 <= args.check_block_size <= 256
    assert 1 <= args.checks_per_module <= 64
    data = json.loads(args.circuit.read_text())
    nodes, count = data['nodes'],len(data['nodes'])
    sha = hashlib.sha256(args.circuit.read_bytes()).hexdigest()
    prefix = 'ThomsonN9.Certificates.'
    namespace = prefix+'AmbientKernel'
    target = args.directory/'ThomsonN9/Certificates'
    header = ['set_option maxRecDepth 200000','set_option maxHeartbeats 0',
              'namespace '+namespace,'open IntervalCircuit']
    blocks = [nodes[i:i+args.data_block_size] for i in range(0,count,args.data_block_size)]
    lines = ['import ThomsonN9.Certificates.IntervalCircuit',*header,
             '-- Frozen trace SHA256: '+sha,'def nodeCount : ℕ := '+str(count),
             'def scale : ℤ := '+data['scale'],
             'def inputs (i : ℕ) : ScaledInterval := if i = 0 then '+bound(nodes[0])+' else ⟨0,0⟩']
    for k,block in enumerate(blocks):
        lines.append('def nodeBlock'+str(k)+' : Array Node := #[')
        lines += ['  ⟨'+operation(n)+', '+bound(n)+'⟩'+(',' if j+1<len(block) else '')
                  for j,n in enumerate(block)]
        lines.append(']')

    def local_lookup(first,last):
        if first+1 == last:
            return ('nodeBlock'+str(first)+'[i-'+str(first*args.data_block_size)+
                    ']?.getD ⟨.constant 0 1, ⟨0,0⟩⟩')
        middle = (first+last)//2
        return ('(if i < '+str(middle*args.data_block_size)+' then '+
                local_lookup(first,middle)+' else '+local_lookup(middle,last)+')')

    def emit_lookup(first,last):
        name = 'lookup_'+str(first)+'_'+str(last)
        if last-first <= 8:
            body = local_lookup(first,last)
        else:
            middle = (first+last)//2
            left,right = emit_lookup(first,middle),emit_lookup(middle,last)
            body = ('if i < '+str(middle*args.data_block_size)+' then '+left+' i else '+right+' i')
        lines.append('def '+name+' (i : ℕ) : Node := '+body)
        return name

    top = emit_lookup(0,len(blocks))
    lines += ['def nodes (i : ℕ) : Node := '+top+' i','end '+namespace]
    write(target/'AmbientKernelData.lean',lines)

    starts = list(range(0,count,args.check_block_size))
    modules = ['AmbientKernelData']
    check_modules = []
    for module_index,first in enumerate(range(0,len(starts),args.checks_per_module)):
        name = 'AmbientKernelChecks'+str(module_index).zfill(2)
        modules.append(name)
        check_modules.append(name)
        lines = ['import '+prefix+'AmbientKernelData',*header]
        for k in range(first,min(first+args.checks_per_module,len(starts))):
            start = starts[k]
            size = min(args.check_block_size,count-start)
            lines += ['def checkChunk'+str(k)+' : Bool := (List.range '+str(size)+').all',
                      '  (fun j => decide (Node.Check scale inputs nodes ('+str(start)+'+j)))',
                      'theorem checkChunk'+str(k)+'_pass : checkChunk'+str(k)+' = true := by decide',
                      '#print axioms checkChunk'+str(k)+'_pass']
        if first == 0:
            bad = next(i for i,n in enumerate(nodes)
                       if n['op']=='sqrt' and int(nodes[n['args'][0]]['lo']) > 0)
            lines += ['def badNodes (i : ℕ) : Node := if i = '+str(bad)+' then',
                      '  ⟨'+operation(nodes[bad])+', ⟨0,0⟩⟩ else nodes i',
                      'def badChecks : Bool := (List.range '+str(bad+1)+').all',
                      '  (fun i => decide (Node.Check scale inputs badNodes i))',
                      'theorem bad_checks_rejected : badChecks = false := by decide',
                      '#print axioms bad_checks_rejected']
        lines.append('end '+namespace)
        write(target/(name+'.lean'),lines)

    lines = ['import '+prefix+m for m in check_modules]+header
    lines += ['theorem node_checks (i : ℕ) (hi : i < '+str(count)+') :',
              '    Node.Check scale inputs nodes i := by']

    def coverage(first,last,indent=2,depth=0):
        space = ' '*indent
        if first+1 == last:
            start = starts[first]
            j = '(i-'+str(start)+')'
            return [space+'have h := List.all_eq_true.mp checkChunk'+str(first)+'_pass '+j,
                    space+'  (List.mem_range.mpr (by omega))',
                    space+'have heq : '+str(start)+'+'+j+' = i := by omega',
                    space+'simpa only [heq] using (of_decide_eq_true h :',
                    space+'  Node.Check scale inputs nodes ('+str(start)+'+'+j+'))']
        middle = (first+last)//2
        return ([space+'by_cases h'+str(depth)+' : i < '+str(starts[middle]),space+'·']+
                coverage(first,middle,indent+2,depth+1)+[space+'·']+
                coverage(middle,last,indent+2,depth+1))

    lines += coverage(0,len(starts))
    lines += ['theorem all_enclosures (values : ℕ → ℝ)',
              '    (hvalues : ∀ i, ScaledInterval.Contains scale (inputs i) (values i)) :',
              '    ∀ i, i < '+str(count)+' → ScaledInterval.Contains scale (nodes i).bound',
              '      (IntervalCircuit.value values nodes i) :=',
              '  checks_sound (by decide) inputs values nodes '+str(count)+' hvalues node_checks',
              '#print axioms node_checks','#print axioms all_enclosures','end '+namespace]
    write(target/'AmbientKernelAll.lean',lines)
    modules.append('AmbientKernelAll')
    manifest = {'format':'thomson-n9-ambient-lean-trace-modules-v1','circuit_sha256':sha,
                'nodes':count,'data_block_size':args.data_block_size,
                'check_block_size':args.check_block_size,'checks_per_module':args.checks_per_module,
                'modules':[prefix+m for m in modules],
                'files':[{ 'name':m+'.lean','sha256':hashlib.sha256((target/(m+'.lean')).read_bytes()).hexdigest(),
                           'bytes':(target/(m+'.lean')).stat().st_size} for m in modules],
                'status':'generated only; successful serial Lean checking still required'}
    manifest_path = Path(__file__).with_name('lean-trace-manifest.json')
    manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
    script = [
        'param([int]$MemoryMegabytes = 8192, [int]$StartAt = 0)',
        "$ErrorActionPreference = 'Stop'",
        '$Workspace = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)',
        "$LeanRoot = Join-Path $Workspace 'outputs/thomson-n9/lean'",
        "$Bin = Join-Path $Workspace 'work/toolchains/lean-4.34.1-windows/bin'",
        "$Lake = Join-Path $Bin 'lake.exe'",
        "$Lean = Join-Path $Bin 'lean.exe'",
        '$Modules = @('+','.join("'"+prefix+m+"'" for m in modules)+')',
        '$Modules = @($Modules | Select-Object -Skip $StartAt)',
        '$Rows = @()',
        'Push-Location $LeanRoot',
        'try {',
        '  foreach ($Module in $Modules) {',
        '    $Waits = 0',
        '    do {',
        '      $Memory = Get-CimInstance Win32_OperatingSystem',
        '      $Ready = $Memory.FreeVirtualMemory -ge 10485760 -and $Memory.FreePhysicalMemory -ge 7340032',
        '      if (-not $Ready) {',
        '        if ($Waits -ge 20) { throw "Insufficient measured memory headroom before $Module" }',
        '        Write-Output "Waiting for memory headroom before $Module"',
        '        Start-Sleep -Seconds 15',
        '        $Waits += 1',
        '      }',
        '    } while (-not $Ready)',
        "    $Relative = $Module.Replace('.', '/')",
        "    $Source = Join-Path $PSScriptRoot ($Relative + '.lean')",
        "    $Output = Join-Path $LeanRoot ('.lake/build/lib/lean/' + $Relative + '.olean')",
        "    $Log = Join-Path $PSScriptRoot ($Module + '.build.log')",
        "    $Report = Join-Path $Workspace ('outputs/thomson-n9/verification/' + $Module + '.measured.json')",
        '    $Clock = [Diagnostics.Stopwatch]::StartNew()',
        "    & $Lake env powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'MeasureDraft.ps1') -Module $Module -Report $Report -MemoryMegabytes $MemoryMegabytes *> $Log",
        '    $Code = $LASTEXITCODE',
        '    $Clock.Stop()',
        '    $Rows += [ordered]@{ module=$Module; exit_code=$Code; wall_seconds=$Clock.Elapsed.TotalSeconds; log=$Log; report=$Report }',
        "    $Rows | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'ambient-kernel-build.json') -Encoding UTF8",
        '    Write-Output ($Module + ": exit=" + $Code + ", seconds=" + $Clock.Elapsed.TotalSeconds)',
        '    if ($Code -ne 0) { throw ("Lean failed: " + $Module + "; see " + $Log) }',
        '  }',
        '} finally { Pop-Location }',
        'Write-Output "PASS: every requested module built; StartAt=$StartAt"',
        'Write-Output "This does not prove the circuit-to-Hessian semantic identity."',
    ]
    write(args.directory/'BuildAmbientKernel.ps1',script)
    print('Generated',len(modules),'modules for',count,'nodes;',len(starts),'arithmetic proof declarations')
    print('Total source bytes:',sum(f['bytes'] for f in manifest['files']))


if __name__ == '__main__':
    main()
