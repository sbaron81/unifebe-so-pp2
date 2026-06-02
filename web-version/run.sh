#!/usr/bin/env bash

# Check for python environment
if ! command -v python3 &> /dev/null; then
    echo "Python3 não encontrado. Por favor, instale o Python3."
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Criando ambiente virtual..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Instalando dependências..."
pip install -r requirements.txt --quiet

# Start the application
echo "Iniciando OS Monitor Dashboard em http://localhost:8000"
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
