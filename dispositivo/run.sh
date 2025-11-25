#!/usr/bin/env bash

cleanup() {
    echo "Finalizando"
}

atividade1() {
  echo
  linha
  echo "Atividade 1:"
  linha

  SYS_VIDEO=$(lspci | grep VGA | sed 's/.*: //' )

  echo "Utilize o comando "lspci" para verificar os dispositivos conectados na PCI"
  read -rp " - Qual é o modelo da placa de vídeo: " USER_VIDEO
  if [ "$SYS_VIDEO" == "$USER_VIDEO" ]; then
      echo "✅ Resposta correta!"
  else
    echo "❌ Resposta incorreto. A placa de video é \"$SYS_VIDEO\""
  fi

}

atividade2() {
  echo
  linha
  echo "Atividade 2:"
  linha


  SYS_DISK=$(lsblk | grep disk | cut -d" " -f1 )

  echo "Utilize o comando "sudo fdisk -l" para listar os discos do sistema"
  read -rp " - Qual é o nome do disco (ex: /dev/xxx): " USER_DISK
  USER_DISK=$(echo $USER_DISK | sed -e 's/\/dev\///')
  if [ "$SYS_DISK" == $USER_DISK ]; then
      echo "✅ Resposta correta!"
  else
    echo "❌ Resposta incorreto. O disco é o \"$SYS_DISK\""
  fi


}


atividade3() {
  echo
  linha
  echo "Atividade 3:"
  linha

  SYS_DISK=$(lsblk | grep disk | cut -d" " -f1 )
  SYS_DISK_SIZE=$(lsblk -dn -o SIZE /dev/$SYS_DISK | sed -e 's/ //g' )

  echo "Utilize o comando "lsblk" para listar os discos do sistema"
  read -rp " - Qual é o tamanho do disco /dev/$SYS_DISK: " USER_DISK_SIZE
  if [ "$SYS_DISK_SIZE" == "$USER_DISK_SIZE" ]; then
      echo "✅ Resposta correta!"
  else
    echo "❌ Resposta incorreto. O tamanho do disco /dev/$SYS_DISK é de $SYS_DISK_SIZE"
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
