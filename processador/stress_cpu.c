#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/sysinfo.h>

void consumir_cpu() {
    // Intervalo de amostragem em microssegundos (0.1 segundos)
    long intervalo = 100000; 
    long tempo_trabalho = intervalo * 0.5; // 50% trabalho
    long tempo_descanso = intervalo * 0.5; // 50% descanso

    struct timespec inicio, atual;

    while (1) {
        clock_gettime(CLOCK_MONOTONIC, &inicio);
        
        // Loop de processamento pesado
        while (1) {
            clock_gettime(CLOCK_MONOTONIC, &atual);
            long decorrido = (atual.tv_sec - inicio.tv_sec) * 1000000 + 
                             (atual.tv_nsec - inicio.tv_nsec) / 1000;
            if (decorrido >= tempo_trabalho) {
                break;
            }
        }

        // Período de descanso
        usleep(tempo_descanso);
    }
}

int main() {
    // Obtém o número de cores (núcleos) da CPU instalados
    int num_cores = sysconf(_SC_NPROCESSORS_ONLN);
    printf("Gerando carga de 50%% usando %d núcleos...\n", num_cores);

    // Cria um processo filho para cada núcleo
    for (int i = 0; i < num_cores; i++) {
        pid_t pid = fork();
        
        if (pid < 0) {
            perror("Erro ao clonar processo (fork)");
            exit(1);
        } else if (pid == 0) {
            // Processo filho entra no loop de consumo
            consumir_cpu();
            exit(0); // Garante que o filho nunca saia daqui
        }
    }

    // Processo pai apenas fica aguardando para manter a árvore viva
    while (1) {
        sleep(10);
    }

    return 0;
}