#!/usr/bin/env bash

cleanup() {
    echo "Finalizando"
    killall stress
    echo "sudo swapoff /home/ubuntu/swapfile"
    echo "sudo rm -f /home/ubuntu/swapfile"
    echo "sudo swapon -a"
}

atividade1() {
  echo
  linha
  echo "Atividade 1:"
  linha

  SYS_MEM_TOTAL=$(grep MemTotal /proc/meminfo | sed 's/MemTotal: *//' | cut -d" " -f1)

  echo "Analise o conteúdo do arquivo /proc/meminfo"
  read -rp " - Qual tamanho total da memória (em kB): " MEM_TOTAL
  if [ "$MEM_TOTAL" == $SYS_MEM_TOTAL ]; then
      echo "✅ Resposta correta!"
  else
    echo "❌ Resposta incorreto. Tamanho da memória é de $SYS_MEM_TOTAL KB"
  fi


}

atividade2() {
  echo
  linha
  echo "Atividade 2:"
  linha

  echo "Analise o retorno do comando \"free\""
  read -rp " - Qual é o tamanho da memória swap: " USER_SWAP
  SWAP_TOTAL=$(( $(grep SwapTotal /proc/meminfo | sed 's/SwapTotal: *//' | cut -d" " -f1) - SYS_SWAP_USED ))
  if [ "$UER_SWAP" == $SWAP_TOTAL ]; then
      echo "✅ Resposta correta! "
  else
      echo "❌ Resposta incorreta. O valor correto é $SWAP_TOTAL kB."
  fi  
}


atividade3() {
  echo
  linha
  echo "Atividade 3:"
  linha

  echo "Desative o swap do sistema, usando o comando seguinte comando:" 
  echo 
  echo "sudo swapoff -a"
  echo
  echo -n " Aguardando a desativação da memória swap."
  while [[ $(wc -l < /proc/swaps) -gt 1 ]] ; do
      echo -n "."
      sleep 2
  done
  echo "feito!"
  echo "✅ Memoria swap desativada!"

}

atividade4() {
  echo
  linha
  echo "Atividade 4:"
  linha

  echo "Um processo iniciará a consumir memória, porem não temos memória swap"
  echo "Monitore o consumo da memória, executando o seguinte comando em outro terminal:" 
  echo
  echo "htop"
  echo 
  read -rp "Digite ENTER para iniciar.."
  FINALIZA=0
  MAXIMO=0
  TAM=0
  echo
  while [ $FINALIZA -eq 0 ]; do
    TAM=$((TAM+500))
    echo -n "+ Tentando alocar $TAM MB da memória..."     
    stress --vm 1 --vm-bytes ${TAM}M -t 5s  >/dev/null 2>&1 #&
    if [ $? -gt 0 ] ; then
      echo "[Falha] ++ Sem memória suficiente alocar o processo. ++"
      FINALIZA=1
      sleep 2
    else
      echo "[Sucesso]"
      sleep 2
      MAXIMO=$TAM
    fi
  done
  echo 
  read -rp " - Qual foi o tamanho máximo que foi possível alocar: " TAM_USER
  if [ "$TAM_USER" -eq $MAXIMO ]; then
    echo "✅ Resposta correta"
  else
    echo "❌ Resposta incorreta. A quantidade máxima foi de $MAXIMO MB)"
  fi

}

atividade5() {
  echo
  linha
  echo "Atividade 5:"
  linha

  echo "Crie um arquivo de swap no sistema, utilize os seguintes comandos:" 
  echo 
  echo "sudo fallocate -l 1G /home/ubuntu/swapfile"
  echo "sudo chmod 600 /home/ubuntu/swapfile"
  echo "sudo mkswap /home/ubuntu/swapfile"
  echo "sudo swapon /home/ubuntu/swapfile"
  echo
  echo -n " Aguardando a criação da memória swap."
  while ! grep -q /home/ubuntu/swapfile /proc/swaps ; do
      echo -n "."
      sleep 2
  done
  echo "feito!"
  echo "✅ Memoria swap ativada!"

}


atividade6() {
  echo
  linha
  echo "Atividade 6:"
  linha

  echo "Em outro terminal, execute o seguinte comando:"
  echo
  echo "htop"
  echo 
  echo "Assim como na atividade 4, um processo iniciará a consumir memória."
  echo "Porém agora temos a memória swap configurada." 
  echo "Monitore o consumo da memória, executando o seguinte comando em outro terminal:" 
  echo 
  echo "htop"
  echo 
  read -rp "Digite ENTER para iniciar.."
  FINALIZA=0
  TAM=0
  MAXIMO=0
  echo
  while [ $FINALIZA -eq 0 ]; do
    TAM=$((TAM+500))
    
    echo -n "+ Tentando alocar $TAM MB da memória..."     
    stress --vm 1 --vm-bytes ${TAM}M -t 5s  >/dev/null 2>&1 #&
    if [ $? -gt 0 ] ; then
      echo "[Falha] ++ Sem memória suficiente alocar o processo. ++"
      sleep 2
      FINALIZA=1
    else
      echo "[Sucesso]"
      MAXIMO=$TAM
      sleep 2
    fi
      
  done
  echo 
  read -rp " - Qual foi o tamanho máximo que foi possível alocar: " TAM_USER
  if [ "$TAM_USER" -eq $MAXIMO ]; then
    echo "✅ Resposta correta"
  else
    echo "❌ Resposta incorreta. A quantidade máxima foi de $MAXIMO MB)"
  fi
}

# Garante remoção ao final ou se for interrompido
trap cleanup EXIT
trap cleanup INT TERM


atividade1
atividade2
atividade3
atividade4
atividade5
atividade6

echo
read -rp " Atividade concluída, digite ENTER para retornar ao menu principal.."
