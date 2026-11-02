.section .text
.globl my_mul

// long long int my_mul(long long int a, long long int b)
// Multiplies by repeated addition so the program only uses the
// instructions covered in the course. X0 = a, X1 = b, result in X0.
my_mul:
    ADD  X2, XZR, XZR      // product = 0
mul_loop:
    CBZ  X1, mul_done      // stop when b reaches 0
    ADD  X2, X2, X0        // product += a
    SUB  X1, X1, #1        // b--
    B    mul_loop
mul_done:
    ADD  X0, X2, XZR       // return product
    BR   LR
