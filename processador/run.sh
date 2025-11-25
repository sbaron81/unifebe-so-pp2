#!/usr/bin/env bash



ORIGINAL="/usr/bin/sleep"

# Gera nome aleatório
NEWNAME=$(tr -dc 'a-z0-9' </dev/urandom | head -c 16)
TMPFILE="/tmp/$NEWNAME"

# Copia para o novo nome
cp "$ORIGINAL" "$TMPFILE"
chmod +x "$TMPFILE"

#echo 
#echo "Criando o processo..." 



# Executa o novo e encerra este
exec "$TMPFILE" "9000" > /dev/null 2>&1 & 
TEST_PID=$!
#echo "Feito!"
#echo "Nome do processo: $NEWNAME"

linha() {
  echo "------------------------------------------------------------"
}

cleanup() {
    echo "Finalizando"
    killall stress
    kill -9 $TEST_PID    
    rm -f "$TMPFILE"
}


atividade1() {
  echo
  linha
  echo "Atividade 1:"
  linha
  CPU_MODEL=$(cat /proc/cpuinfo  | grep "model name" | head -1| sed -e 's/.*: //')
  echo "Analise o conteúdo do arquivo /proc/cpuinfo." 
  read -rp " - Qual é o modelo do seu processador: " USER_MODEL
  echo $USER_MODEL
  if [ "$USER_MODEL" == "$CPU_MODEL" ] 2>/dev/null; then
    echo "✅ Modelo do processador correto!"
    SCORE=$((SCORE+1))
  else
    echo "❌ Modelo do processador incorreto. O correto era \"$CPU_MODEL\"."
  fi
}  


atividade2() {
  
  echo
  linha
  echo "Atividade 2:"
  linha
  echo " Em outro terminal, localize o PID do processo com o nome \"$NEWNAME\""
  
  read -rp " - Informe o PID: " USER_PID
  if [ "$USER_PID" -eq "$TEST_PID" ] 2>/dev/null; then
    echo "✅ PID correto!"
    SCORE=$((SCORE+1))
  else
    echo "❌ PID incorreto. O PID correto era $TEST_PID."
  fi
}  
  
atividade3() {

  echo
  linha
  echo "Atividade 3:"
  linha
  echo " Em outro terminal, acompanhe o consumo da CPU com o comando:  htop"
  echo
  echo -n " Aguardando abrir o htop..."
  HTOP=0
  while [ $HTOP -lt 1 ] ; do
      echo -n "."
      sleep 2
      HTOP=$(ps ax | grep htop | grep -v grep | wc -l)
  done
  echo "aberto!"
  stress --cpu $(nproc) --timeout 15m > /dev/null 2>&1 & 
  read -rp "✅ Quando o consumo estiver em um nível crítico, digite ENTER para continuar..."
  
}

atividade4() {
  echo
  linha
  echo "Atividade 4:" 
  linha
  echo " Em outro terminal, mate o processo com o nome $NEWNAME"
  echo
  echo -n " Aguardando a eliminacao do processo"
  while kill -0 "$TEST_PID" >/dev/null 2>&1; do
      echo -n "."
      sleep 2
  done
  killall stress
  echo 
  echo "✅ Processo foi eliminado, observe se o consumo de CPU baixou! "
  echo   
  linha
}


# Garante remoção ao final ou se for interrompido
trap cleanup EXIT
trap cleanup INT TERM


atividade1
atividade2
atividade3
atividade4

echo 
read -rp " Atividade concluída, digite ENTER para retornar ao menu principal.."
