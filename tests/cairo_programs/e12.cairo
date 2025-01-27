%builtins range_check

from src.bn254.towers.e12 import E12, e12
from src.bn254.towers.e6 import E6, e6
from src.bn254.towers.e2 import E2, e2
from starkware.cairo.common.registers import get_fp_and_pc
from src.bn254.fq import BigInt3

func main{range_check_ptr}() {
    alloc_locals;
    %{
        import subprocess
        import random
        import functools
        import re
        from starkware.cairo.common.cairo_secp.secp_utils import split

        P=0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47
        def rgetattr(obj, attr, *args):
            def _getattr(obj, attr):
                return getattr(obj, attr, *args)
            return functools.reduce(_getattr, [obj] + attr.split('.'))

        def rsetattr(obj, attr, val):
            pre, _, post = attr.rpartition('.')
            return setattr(rgetattr(obj, pre) if pre else obj, post, val)

        def fill_e12(e2:str, *args):
            for i in range(12):
                splitted = split(args[i])
                for j in range(3):
                    rsetattr(ids,e2+str(i)+'.d'+str(j),splitted[j])
            return None

        def parse_fp_elements(input_string:str):
            pattern = re.compile(r'\[([^\[\]]+)\]')
            substrings = pattern.findall(input_string)
            sublists = [substring.split(' ') for substring in substrings]
            sublists = [[int(x) for x in sublist] for sublist in sublists]
            fp_elements = [x[0] + x[1]*2**64 + x[2]*2**128 + x[3]*2**192 for x in sublists]
            return fp_elements
    %}
    let (__fp__, _) = get_fp_and_pc();

    local x0: BigInt3;
    local x1: BigInt3;
    local x2: BigInt3;
    local x3: BigInt3;
    local x4: BigInt3;
    local x5: BigInt3;
    local x6: BigInt3;
    local x7: BigInt3;
    local x8: BigInt3;
    local x9: BigInt3;
    local x10: BigInt3;
    local x11: BigInt3;

    local y0: BigInt3;
    local y1: BigInt3;
    local y2: BigInt3;
    local y3: BigInt3;
    local y4: BigInt3;
    local y5: BigInt3;
    local y6: BigInt3;
    local y7: BigInt3;
    local y8: BigInt3;
    local y9: BigInt3;
    local y10: BigInt3;
    local y11: BigInt3;

    local z0: BigInt3;
    local z1: BigInt3;
    local z2: BigInt3;
    local z3: BigInt3;
    local z4: BigInt3;
    local z5: BigInt3;
    local z6: BigInt3;
    local z7: BigInt3;
    local z8: BigInt3;
    local z9: BigInt3;
    local z10: BigInt3;
    local z11: BigInt3;
    tempvar x = new E12(
        new E6(new E2(&x0, &x1), new E2(&x2, &x3), new E2(&x4, &x5)),
        new E6(new E2(&x6, &x7), new E2(&x8, &x9), new E2(&x10, &x11)),
    );
    tempvar y = new E12(
        new E6(new E2(&y0, &y1), new E2(&y2, &y3), new E2(&y4, &y5)),
        new E6(new E2(&y6, &y7), new E2(&y8, &y9), new E2(&y10, &y11)),
    );
    tempvar z = new E12(
        new E6(new E2(&z0, &z1), new E2(&z2, &z3), new E2(&z4, &z5)),
        new E6(new E2(&z6, &z7), new E2(&z8, &z9), new E2(&z10, &z11)),
    );
    %{
        random.seed(42)
        inputs=[random.randint(0, P-1) for i in range(24)]

        fill_e12('x', *inputs[0:12])
        fill_e12('y', *inputs[12:24])

        cmd = ['./tools/gnark/main', 'e12', 'mul'] + [str(x) for x in inputs]
        out = subprocess.run(cmd, stdout=subprocess.PIPE).stdout.decode('utf-8')
        print('out', out)
        fp_elements = parse_fp_elements(out)

        assert len(fp_elements) == 12
        fill_e12('z', *fp_elements)
        reduce_counter=0
    %}
    let res = e12.mul(x, y);

    e12.assert_E12(res, z);

    %{ print("reduce_count", reduce_counter) %}
    return ();
}
