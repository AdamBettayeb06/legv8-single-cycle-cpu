#include <stdio.h>

extern long long int power(long long int base, long long int exp);

int main(void)
{
    long long int tests[][2] = { {2, 10}, {3, 4}, {5, 0}, {7, 3} };
    for (int i = 0; i < 4; i++)
        printf("power(%lld, %lld) = %lld\n", tests[i][0], tests[i][1],
               power(tests[i][0], tests[i][1]));
    return 0;
}
