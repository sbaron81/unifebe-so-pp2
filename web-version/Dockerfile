FROM python:3.12-slim

# Instalar dependências de sistema necessárias para monitoramento e comandos de validação
RUN apt-get update && apt-get install -y \
    procps \
    pciutils \
    iproute2 \
    stress \
    kmod \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar requirements primeiro para aproveitar o cache do Docker
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o restante da aplicação
COPY . .

# Garantir que o diretório static e templates existam (caso não tenham sido copiados corretamente)
RUN mkdir -p app/static/js app/static/css app/templates

# Expor a porta 8000
EXPOSE 8000

# Comando para rodar a aplicação
CMD ["python3", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
