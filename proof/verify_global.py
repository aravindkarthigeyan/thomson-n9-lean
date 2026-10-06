"""Replay all finite arithmetic premises of GLOBAL_PROOF.md; no solver required."""
import argparse
from fractions import Fraction as F
import hashlib
import json
from pathlib import Path
import re
import sys
import time

if not __debug__:
    raise RuntimeError('Exact verification requires assertions; do not use Python -O.')

ROOT = Path(__file__).resolve().parent
for directory in ('certificates', 'near_sharp', 'rigidity'):
    sys.path.insert(0, str(ROOT/directory))

from check_local import check as check_local, selftest
from check_lp import check as check_lp
from check_hermite import check as check_hermite
from check_bernstein import check as check_bernstein
from check_refined_windows import check as check_refined
from check_sos_integer import check as check_sos
from check_window_gram import verify as check_windows
from check_antipodal_window import verify as check_antipodal
from check_exact_gram import LOWER, UPPER


def lean_radius(name):
    source = (ROOT/'lean/ThomsonN9/Candidate.lean').read_text(encoding='utf-8')
    marker = 'def '+name+' : \u211a :='
    assert source.count(marker) == 1
    body = source.split(marker, 1)[1].split('\n\n', 1)[0]
    match = re.fullmatch(r'\s*([0-9]+)\s*/\s*([0-9]+)\s*', body)
    assert match is not None, 'Candidate radius definition is no longer the audited literal fraction'
    return F(int(match.group(1)), int(match.group(2)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path,
                        default=ROOT/'verification/global-chain.check.json')
    parser.add_argument('--bernstein', action='store_true',
                        help='Use the direct finite polynomial cover instead of the Hermite argument')
    parser.add_argument('--mutations', action='store_true',
                        help='Also replay nine adversarial suites (requires pinned python-flint)')
    parser.add_argument('--refined', action='store_true',
                        help='Also prove the narrower six contact windows after antipodal exclusion')
    parser.add_argument('--reduced', action='store_true',
                        help='Use the separately frozen 60-digit certificate and its Bernstein cover')
    args = parser.parse_args()
    if args.reduced:
        args.bernstein = True
    if args.reduced and args.mutations:
        parser.error('--mutations currently targets the original certificate; run reduced standalone controls separately')
    started = time.monotonic()
    sources = [
        'certificates/local.json', 'sdp/lp-separation.json',
        'sdp/lp-separation-05593.json', 'near_sharp/hermite.json',
        'near_sharp/near-sharp-d10.json', 'rigidity/window_gram.json',
    ]
    if args.bernstein:
        sources[3] = 'near_sharp/bernstein-minorant.json'
    refined_source = 'near_sharp/refined-windows.json'
    if args.reduced:
        sources[3] = 'near_sharp/reduced/bernstein-reduced.json'
        sources[4] = 'near_sharp/reduced/near-sharp-d10-reduced-D60.json'
        refined_source = 'near_sharp/reduced/refined-windows-reduced.json'
    if args.refined:
        sources.append(refined_source)
    data = {p: json.loads((ROOT/p).read_text()) for p in sources}
    reports = {}

    def run(name, function, *arguments):
        print('Checking '+name+' ...', flush=True)
        result = function(*arguments)
        assert result.get('passed') is True or result.get('result') == 'PASS'
        reports[name] = result
        print('PASS: '+name, flush=True)
        return result

    selftest()
    local = run('local', check_local, data[sources[0]])
    covariance = run('covariance', check_lp, data[sources[1]])
    separation = run('separation', check_lp, data[sources[2]])
    if args.bernstein:
        minorant = run('bernstein', check_bernstein, data[sources[3]])
        sos = run('three_point', check_sos, data[sources[4]], None, True, True, data[sources[3]])
    else:
        minorant = run('hermite', check_hermite, data[sources[3]])
        sos = run('three_point', check_sos, data[sources[4]], data[sources[3]], True, True)
    windows = run('gram_windows', check_windows, data[sources[5]])
    antipodal = run('antipodal', check_antipodal)

    # Match independently checked objects, not their cached JSON reports.
    assert F(*data[sources[0]]['radius_lower']) == LOWER
    assert F(*data[sources[0]]['radius_upper']) == UPPER
    assert lean_radius('radiusLower') == LOWER
    assert lean_radius('radiusUpper') == UPPER
    rlo, rhi = map(F, minorant['radius_interval'])
    if args.bernstein:
        assert (rlo, rhi) == (LOWER, UPPER)
    else:
        assert LOWER < rlo < rhi < UPPER
    threshold = F(6439996633, 250000000)
    energy_upper = F(minorant['energy_upper'])
    assert F(local['energy_interval'][1]) < threshold
    assert energy_upper < threshold == F(separation['energy_threshold'])
    assert F(covariance['minimum_inner_product']) == -1
    assert F(separation['minimum_inner_product']) == -1
    upper = F(separation['maximum_inner_product_strictly_below'])
    assert upper == F(5593, 10000)
    assert F(data[sources[4]]['maximum_inner_product']) == upper
    assert F(data[sources[4]]['minimum_inner_product']) == -1
    assert F(data[sources[4]]['raw_energy']) == energy_upper
    coefficients = minorant['minorant'] if args.bernstein else minorant['coefficients_monomial']
    assert list(map(F, data[sources[4]]['minorant'])) == list(map(F, coefficients))
    loss = F(sos['energy_loss'])
    exterior = F(minorant['exterior_slack_lower'])
    assert loss == 36*F(sos['residual_l1']) < exterior
    assert exterior == F(1, 10**(46 if args.bernstein else 92))
    assert sos['spectrum_localization_threshold_met'] is True

    a2 = F(data[sources[1]]['coefficients_legendre'][2])
    assert a2 > 0
    covariance_error = 4*(threshold-F(covariance['bound']))/(3*a2)
    assert 0 < covariance_error < F(1, 4)
    # ||M-3I||_F < 1/2 gives M > (5/2)I. Cauchy-Binet has 84 triples.
    anchor = F(5, 2)**3/84
    assert anchor == F(125, 672)
    assert F(data[sources[5]]['anchor_gram_determinant_strict_lower_bound']) == anchor
    epsilon = F(data[sources[5]]['inner_product_half_width'])
    assert epsilon == F(antipodal['inner_product_half_width']) == F(1, 10000)
    assert antipodal['triple_color_cases'] == 49
    assert windows['nine_cliques'] > 0 and windows['self_compatible_nodes'] == 0
    localization_epsilon = epsilon
    if args.refined:
        refined = run('refined_windows', check_refined, data[refined_source],
                      (ROOT/sources[4]).read_bytes())
        assert list(map(F, refined['minorant'])) == list(map(F, coefficients))
        assert tuple(map(F, refined['radius_interval'])) == (LOWER, UPPER)
        assert list(map(F, refined['domain_t'])) == [F(-3, 4), upper]
        assert refined['old_six_windows_inside_domain'] is True
        assert loss < F(refined['exterior_slack_lower'])
        localization_epsilon = F(refined['window_half_width'])
        assert 0 < localization_epsilon < epsilon
    # These are true algebraic windows. Rational enclosures are only filters.
    gram_error = 9*localization_epsilon
    alignment_radius = 2*gram_error
    assert gram_error < 1
    assert alignment_radius < F(local['local_chord_radius']) == F(1, 500)
    assert F(local['local_energy_coefficient']) == F(1, 50)
    assert F(local['hessian_lower']) == F(7, 50)

    code = ['verify_global.py', 'certificates/check_local.py',
            'certificates/check_lp.py', 'certificates/polynomial.py',
            'certificates/check_sos_integer.py', 'near_sharp/check_hermite.py',
            'near_sharp/check_bernstein.py',
            'near_sharp/check_refined_windows.py',
            'near_sharp/exact_interval.py', 'rigidity/check_exact_gram.py',
            'rigidity/check_window_gram.py', 'rigidity/check_antipodal_window.py',
            'lean/ThomsonN9/Candidate.lean']
    adversarial = None
    if args.mutations:
        from verification.run_mutations import run_all
        adversarial = run_all(args.report.parent/'mutations', sos)
        code.append('verification/run_mutations.py')
    result = {
        'result': 'PASS',
        'python_version': sys.version,
        'lean_radius_literals_matched': True,
        'minorant_method': 'direct Bernstein cover' if args.bernstein else 'Hermite remainder',
        'certificate_variant': 'reduced 60-digit' if args.reduced else 'original 170-digit',
        'scope': 'All exact arithmetic premises and cross-stage constants replayed; analytic bridges are in GLOBAL_PROOF.md, not Lean.',
        'energy_upper': str(energy_upper), 'energy_loss': str(loss),
        'exterior_slack_lower': str(exterior),
        'loss_to_slack_ratio': str(loss/exterior),
        'squared_covariance_error_upper': str(covariance_error),
        'anchor_determinant_strict_lower': str(anchor),
        'contact_window_half_width': str(localization_epsilon),
        'gram_frobenius_error_upper': str(gram_error),
        'alignment_radius_upper': str(alignment_radius),
        'local_radius': local['local_chord_radius'],
        'local_energy_coefficient': local['local_energy_coefficient'],
        'seconds': time.monotonic()-started,
        'sha256': {p: hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in sources+code},
        'checks': reports,
        'adversarial': adversarial,
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(result, indent=2)+'\n')
    print('PASS: complete arithmetic chain and cross-stage compatibility', flush=True)
    print('Energy loss:', float(loss), 'Exterior slack:', float(exterior))
    print('Alignment radius:', alignment_radius, '<', local['local_chord_radius'])
    print('Report:', args.report)


if __name__ == '__main__':
    main()
