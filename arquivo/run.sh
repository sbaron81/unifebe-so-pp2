#!/usr/bin/env bash

cleanup() {
    echo "Finalizando"
}

atividade1() {
  echo
  linha
  echo "Atividade 1:"
  linha

  SYS_BOOT=$(df -h | grep "/boot" | sed 's/ .*//')

  echo "Utilize o comando "df -h" para verificar o sistemas de arquivos"
  read -rp " - Qual é a partição que está montada no $SYS_BOOT: " USER_BOOT
  if [ "/boot" == "$USER_BOOT" ]; then
      echo "✅ Resposta correta!"
  else
    echo "❌ Resposta incorreto. A partição montada no $SYS_BOOT é o /boot"
  fi

}

atividade2() {
  echo
  linha
  echo "Atividade 2:"
  linha

  SYS_INODE=$(df --output=ipcent,target | grep "/$" | sed -e 's/ *//' | sed -e 's/%.*//' )

  echo "Utilize o comando "df -i" para verificar consumo de inodes no sistemas de arquivos"
  read -rp " - Qual é o percentual de utilizacao de inodes na partição \"/\": " USER_INODE
  USER_INODE=$(echo "$USER_INODE" | sed -e 's/%//g' )
  if [ "$SYS_INODE" == "$USER_INODE" ]; then
      echo "✅ Resposta correta!"
  else
    echo "❌ Resposta incorreto. O consumo de inode no / é de $SYS_INODE%"
  fi


}


atividade3() {
  echo
  linha
  echo "Atividade 3:"
  linha

  SYS_DU=$(sudo du -sh /var | sed -e 's/[ |\t].*//')

  echo "Pesquise sobre o comando \"du\" e descubra o tamanho do diretório /var"
  read -rp " - Qual é o tamanho do diretório /var: " USER_DU
  if [ "$SYS_DU" == "$USER_DU" ]; then
      echo "✅ Resposta correta!"
  else
    echo "❌ Resposta incorreto. O tamanho do diretório /var é de $SYS_DU"
  fi

}

atividade4() {
  echo
  linha
  echo "Atividade 4:"
  linha


}

atividade5() {
  echo
  linha
  echo "Atividade 5:"
  linha

}


atividade6() {
  echo
  linha
  echo "Atividade 6:"
  linha

}

# Garante remoção ao final ou se for interrompido
trap cleanup EXIT
trap cleanup INT TERM


atividade1
atividade2
atividade3
#atividade4
#atividade5
#atividade6

echo
read -rp " Atividade concluída, digite ENTER para retornar ao menu principal.."
