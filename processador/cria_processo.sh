#!/usr/bin/env bash

ORIGINAL="/opt/unifebe-so-pp2/processador/stress_cpu"

# Gera nome aleatório
NEWNAME=$(tr -dc 'a-z0-9' </dev/urandom | head -c 8)
NEWNAME="unifebe-$NEWNAME"
TMPFILE="/tmp/$NEWNAME"
rm -f /tmp/unifebe-*

# Copia para o novo nome
cp "$ORIGINAL" "$TMPFILE"
chmod +x "$TMPFILE"

echo 
echo "Criando o processo..." 



# Executa o novo e encerra este
exec "$TMPFILE" > /dev/null 2>&1 & 
TEST_PID=$!

echo "Feito!"
echo "Nome do processo: $NEWNAME"
