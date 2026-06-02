#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

int main() {
    // Intervalo de amostragem em microssegundos (0.1 segundos)
    long intervalo = 100000; 
    long tempo_trabalho = intervalo * 0.5; // 50% trabalho
    long tempo_descanso = intervalo * 0.5; // 50% descanso

    struct timespec inicio, atual;

    printf("Iniciando processo único. Consumindo 50%% de um único núcleo...\n");
    printf("Pressione Ctrl+C para encerrar.\n");

    while (1) {
        clock_gettime(CLOCK_MONOTONIC, &inicio);
        
        // Loop de processamento pesado (Trabalho)
        while (1) {
            clock_gettime(CLOCK_MONOTONIC, &atual);
            long decorrido = (atual.tv_sec - inicio.tv_sec) * 1000000 + 
                             (atual.tv_nsec - inicio.tv_nsec) / 1000;
            if (decorrido >= tempo_trabalho) {
                break;
            }
        }

        // Período de ociosidade (Descanso)
        usleep(tempo_descanso);
    }

    return 0; // Nunca será atingido
}