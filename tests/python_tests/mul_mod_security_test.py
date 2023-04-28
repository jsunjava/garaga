import random
import sympy
from tools.py.garaga_mul_mod import test_hack_mul, test_mul_ab, test_mul_ab_sub_c, test_mul_honest_full_field, test_mul_honest_single
from tools.py.garaga_mul_mod import prime, prime2

def generate_prime(n):
    while True:
        # Generate a random n-bit number
        num = random.getrandbits(n)

        # Set the most significant and least significant bits to 1
        num |= (1 << n-1) | 1

        # Check if the number is prime
        if sympy.isprime(num):
            return num

p_stark=generate_prime(5)
p_emul=generate_prime(6)

test_mul_ab()
test_mul_ab_sub_c()
test_mul_honest_full_field(n_cores=1)
test_mul_honest_single(1,2)

try:
    test_hack_mul(n_cores=4)
except Exception as e:
    print(f"Error: {e}")