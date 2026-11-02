.section .text
.globl power

// long long int power(long long int base, long long int exp) {
//     if (exp == 0) return 1;
//     return my_mul(base, power(base, exp - 1));
// }
//
// Arguments (ARMv8 convention):
//   X0 = base
//   X1 = exp
//   X0 = return value

power:
    // --- Prologue: allocate stack frame, save regs this call modifies ---
    SUB  SP, SP, 16        // reserve 16 bytes (16-byte aligned)
    STUR LR,  [SP, 8]      // save return address (power and my_mul are called below)
    STUR X19, [SP, 0]      // save caller's X19 (X19 holds base across the recursive call)

    ADD  X19, X0, XZR      // X19 = base  (save it in a callee-saved reg,
                            //              since base is needed AFTER the
                            //              recursive call returns, and X0
                            //              will get overwritten by then)

    CBNZ X1, recurse        // if (exp != 0) goto recurse
    MOV  X0, #1        
    B    done

recurse:
    SUB  X1, X1, #1        // arg2 = exp - 1
                            // X0 already holds base, so it's ready as arg1
    BL   power              // recursive call: power(base, exp-1) -> result in X0

    // Now compute my_mul(base, result)
    ADD  X1, X0, XZR        // X1 = result of recursive call (2nd arg to my_mul)
    ADD  X0, X19, XZR       // X0 = base (1st arg to my_mul) -- restored from X19
    BL   my_mul              // X0 = base * result

done:
    // --- Epilogue: restore regs, deallocate stack frame, return ---
    LDUR X19, [SP, 0]       // restore caller's X19
    LDUR LR,  [SP, 8]       // restore return address
    ADD  SP, SP, 16         // deallocate stack frame
    BR   LR                 // return to caller
