#!/usr/bin/env bash

pause() {
  echo
  read -rp "Pressione ENTER para continuar..."
}

linha() {
  echo "------------------------------------------------------------"
}

titulo() {
  linha
  echo "$1"
  linha
}

processador() {
  clear
  echo "Gerência do Processador"
  . processador/run.sh
}

memoria() {
  clear
  echo "Gerência de Memoria"
  . memoria/run.sh
}

dispositivo() {
  clear
  echo "Gerência de Dispositivo"
  . dispositivo/run.sh
}

arquivo() {
  clear
  echo "Gerência de Arquivo"
  . arquivo/run.sh
}

questionario() {
  clear
  echo "Questionario"
  . questoes/run.sh
}

prerequisitos() {
  echo "Verificando pre-requisitos..."
  sudo -v
  PACOTES=("stress" "htop" "python3")
  REQUISITOS_OK=true
  for pacote in "${PACOTES[@]}"; do
    echo -n "  + pacote '$pacote'..."
    if ! dpkg -s "$pacote" &> /dev/null; then
      echo "não instalado. ❌"
      REQUISITOS_OK=false
    else
      echo "instalado. ✅"
    fi
  done  
  echo
  if [ "$REQUISITOS_OK" = false ]; then    
    echo "Por favor, instale os pacotes necessários e execute o script novamente."
    echo
    echo " Exemplo: sudo apt install ${PACOTES[*]}"
    echo
    read -rp " Pressione ENTER para sair..."
    return  1 
  else
    echo " Todos os pacotes necessários estão instalados."
    return 0
  fi
  
}

menu_principal() {
  while true; do
    clear
    titulo "PP2 - PROVA PRATICA DE SISTEMA OPERACIONAL"
    echo "Escolha a opcao:"
    echo "  1) Gerência do Processador"
    echo "  2) Gerência de Memória"
    echo "  3) Gerência de Dispositivos"   
    echo "  4) Gerência de Arquivos"
    echo "  5) Questionário"
    echo "  0) Sair"
    echo
    read -rp "Opção: " opcao

    case "$opcao" in
      1) processador ;;
      2) memoria ;;
      3) dispositivo ;;
      4) arquivo ;;
      5) questionario ;;
      0) break ;;
      *) echo "Opção inválida."; pause ;;
    esac
  done

  clear
  titulo "FIM"
  linha
}

if prerequisitos; then
  menu_principal
fi
