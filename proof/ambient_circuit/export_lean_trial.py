"""Export a bounded prefix for kernel-reduction timing; no native_decide.

The destination defaults outside the delivered Lean package while the generic
checker is under development. This is a generated draft, not a checked theorem.
"""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT.parents[1]/'work/n9-lean-drafts'


def integer(value):
    return '('+str(value)+')' if int(value) < 0 else str(value)


def bound(node):
    return '⟨'+integer(node['lo'])+', '+integer(node['hi'])+'⟩'


def operation(node):
    name = 'constant' if node['op'] == 'const' else node['op']
    return '.'+name+' '+' '.join(integer(a) for a in node['args'])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--count',type=int,default=100)
    parser.add_argument('--block-size',type=int,default=128)
    parser.add_argument('--check-block-size',type=int,default=0)
    parser.add_argument('--negative-control',action='store_true')
    parser.add_argument('--circuit',type=Path,
                        default=Path(__file__).with_name('ambient-circuit-k0.json'))
    parser.add_argument('--output',type=Path,default=WORK/'ThomsonN9/Certificates/AmbientCircuitTrial.lean')
    args = parser.parse_args()
    data = json.loads(args.circuit.read_text())
    assert 0 < args.count <= len(data['nodes'])
    nodes = data['nodes'][:args.count]
    assert nodes[0]['op'] == 'input'
    assert 1 <= args.block_size <= 1024
    lines = [
        'import ThomsonN9.Certificates.IntervalCircuit',
        'set_option maxRecDepth 200000',
        'set_option maxHeartbeats 0',
        'namespace ThomsonN9.Certificates.'+args.output.stem,
        'open IntervalCircuit',
        '-- Frozen JSON SHA256: '+hashlib.sha256(args.circuit.read_bytes()).hexdigest(),
        'def scale : ℤ := '+data['scale'],
        'def inputs (i : ℕ) : ScaledInterval := if i = 0 then '+bound(nodes[0])+' else ⟨0,0⟩',
    ]
    blocks = [nodes[i:i+args.block_size] for i in range(0,len(nodes),args.block_size)]
    for k,block in enumerate(blocks):
        lines.append('def nodeBlock'+str(k)+' : Array Node := #[')
        for i,node in enumerate(block):
            lines.append('  ⟨'+operation(node)+', '+bound(node)+'⟩'+(',' if i+1 < len(block) else ''))
        lines.append(']')
    def lookup(first,last):
        if first+1 == last:
            return 'nodeBlock'+str(first)+'[i-'+str(first*args.block_size)+']?.getD ⟨.constant 0 1, ⟨0,0⟩⟩'
        middle = (first+last)//2
        return '(if i < '+str(middle*args.block_size)+' then '+lookup(first,middle)+' else '+lookup(middle,last)+')'
    lines.append('def nodes (i : ℕ) : Node := '+lookup(0,len(blocks)))
    if args.check_block_size:
        assert 1 <= args.check_block_size <= 1024
        chunks = list(range(0,args.count,args.check_block_size))
        for k,start in enumerate(chunks):
            size = min(args.check_block_size,args.count-start)
            lines += [
                'def checkChunk'+str(k)+' : Bool := (List.range '+str(size)+').all',
                '  (fun j => decide (Node.Check scale inputs nodes ('+str(start)+'+j)))',
                'theorem checkChunk'+str(k)+'_pass : checkChunk'+str(k)+' = true := by decide',
            ]
        lines += [
            'def checks : Bool := '+' && '.join('checkChunk'+str(k) for k in range(len(chunks)))+' && true',
            'theorem checks_pass : checks = true := by',
            '  simp [checks, '+', '.join('checkChunk'+str(k)+'_pass' for k in range(len(chunks)))+']',
            'theorem node_checks (i : ℕ) (hi : i < '+str(args.count)+') :',
            '    Node.Check scale inputs nodes i := by',
        ]
        def proof(first,last,indent=2,depth=0):
            space = ' '*indent
            if first+1 == last:
                start = chunks[first]
                j = '(i-'+str(start)+')'
                return [
                    space+'have h := List.all_eq_true.mp checkChunk'+str(first)+'_pass '+j,
                    space+'  (List.mem_range.mpr (by omega))',
                    space+'have heq : '+str(start)+'+'+j+' = i := by omega',
                    space+'simpa only [heq] using (of_decide_eq_true h :',
                    space+'  Node.Check scale inputs nodes ('+str(start)+'+'+j+'))',
                ]
            middle = (first+last)//2
            return ([space+'by_cases h'+str(depth)+' : i < '+str(chunks[middle]),space+'·']+
                    proof(first,middle,indent+2,depth+1)+[space+'·']+
                    proof(middle,last,indent+2,depth+1))
        lines += proof(0,len(chunks))
    else:
        lines += [
            'def checks : Bool := (List.range '+str(args.count)+').all',
            '  (fun i => decide (Node.Check scale inputs nodes i))',
            'theorem checks_pass : checks = true := by decide',
            'theorem node_checks (i : ℕ) (hi : i < '+str(args.count)+') :',
            '    Node.Check scale inputs nodes i := by',
            '  have h := List.all_eq_true.mp checks_pass i (List.mem_range.mpr hi)',
            '  exact of_decide_eq_true h',
        ]
    lines += ['#print axioms checks_pass','#print axioms node_checks']
    if args.negative_control:
        index = next(i for i,n in enumerate(nodes)
                     if n['op'] == 'sqrt' and int(nodes[n['args'][0]]['lo']) > 0)
        lines += [
            'def badNodes (i : ℕ) : Node := if i = '+str(index)+' then',
            '  ⟨'+operation(nodes[index])+', ⟨0,0⟩⟩ else nodes i',
            'def badChecks : Bool := (List.range '+str(args.count)+').all',
            '  (fun i => decide (Node.Check scale inputs badNodes i))',
            'theorem bad_checks_rejected : badChecks = false := by decide',
            '#print axioms bad_checks_rejected',
        ]
    lines.append('end ThomsonN9.Certificates.'+args.output.stem)
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text('\n'.join(lines)+'\n',encoding='utf-8')
    print('Wrote uncompiled trial:',args.count,'nodes,',args.output.stat().st_size,'bytes')


if __name__ == '__main__':
    main()
