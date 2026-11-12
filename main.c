#include <stdio.h>
#include <stdlib.h>

long long calcula(int C, int T, int *raios, int *xs, int *ys);

int main(void) {
    int C, T;

    scanf("%d %d", &C, &T);

    int *raios = malloc(C * sizeof(int));
    int *xs = malloc(T * sizeof(int));
    int *ys = malloc(T * sizeof(int));

    for (int i = 0; i < C; i++) {
        scanf("%d", &raios[i]);
    }

    for (int i = 0; i < T; i++) {
        scanf("%d %d", &xs[i], &ys[i]);
    }

    long long total = calcula(C, T, raios, xs, ys);
    printf("%lld\n", total);

    free(raios);
    free(xs);
    free(ys);
    return 0;
}