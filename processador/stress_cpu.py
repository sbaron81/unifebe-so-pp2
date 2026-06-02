import time
import multiprocessing

def consumir_cpu():
    """Mantém a utilização do núcleo atual próxima a 50%"""
    # Intervalo curto para amostragem rápida (0.1 segundos)
    intervalo = 0.1
    tempo_trabalho = intervalo * 0.5  # 50% de trabalho
    tempo_descanso = intervalo * 0.5  # 50% de folga

    print(f"Iniciando consumo de 50% no processo {multiprocessing.current_process().name}")
    
    while True:
        inicio = time.time()
        # Loop de processamento pesado (trabalho)
        while time.time() - inicio < tempo_trabalho:
            pass  # Executa operações o mais rápido possível
        
        # Período de ociosidade (descanso)
        time.sleep(tempo_descanso)

if __name__ == "__main__":
    # Detecta todos os núcleos disponíveis da máquina
    num_nucleos = multiprocessing.cpu_count()
    print(f"Detectados {num_nucleos} núcleos de CPU. Iniciando threads de carga...")

    processos = []
    try:
        # Cria um processo para cada núcleo para balancear a carga em 50% global
        for i in range(num_nucleos):
            p = multiprocessing.Process(target=consumir_cpu)
            p.daemon = True
            p.start()
            processos.append(p)

        # Mantém o processo principal vivo
        while True:
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\nInterrompido pelo usuário. Finalizando processos...")