#!/bin/bash
set -e

APP_NAME="toggle_master"
APP_USER="ec2-user"
APP_DIR="/opt/apl/toggle_master"
TMP_DIR="$(pwd)"
SERVICE_FILE="toggle_master.service"

echo "=== PRE: limpando pasta de destino ==="

sudo rm -rf "$APP_DIR"
sudo mkdir -p "$APP_DIR"

echo "=== STEPS: instalando e configurando aplicação ==="

echo "Verificando Python..."
if ! command -v python3 &> /dev/null; then
  sudo dnf install -y python3
else
  echo "python3 já instalado"
fi

echo "Verificando pip..."
if ! command -v pip3 &> /dev/null; then
  sudo dnf install -y python3-pip
else
  echo "pip já instalado"
fi

echo "Verificando dos2unix..."
if ! command -v dos2unix &> /dev/null; then
  sudo dnf install -y dos2unix
else
  echo "dos2unix já instalado"
fi

echo "Copiando arquivos para $APP_DIR..."
sudo cp -ru "$TMP_DIR"/. "$APP_DIR"/

echo "Convertendo arquivos para formato Unix..."
sudo find "$APP_DIR" -type f -exec dos2unix {} \;

echo "Ajustando permissões..."
sudo chown -R "$APP_USER:$APP_USER" "$APP_DIR"

cd "$APP_DIR"

echo "Criando virtual environment..."
python3 -m venv venv

echo "Instalando dependências..."
source venv/bin/activate
pip install --upgrade pip

if [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
else
  echo "ERRO: requirements.txt não encontrado"
  exit 1
fi

echo "Carregando variáveis de ambiente..."
if [ -f "$APP_DIR/.env" ]; then
  set -a
  source "$APP_DIR/.env"
  set +a
else
  echo "ERRO: arquivo .env não encontrado"
  exit 1
fi

echo "Executando inicialização do banco de dados..."
export FLASK_APP=app.py
python -m flask init-db

deactivate

echo "Configurando systemd..."
sudo cp "$APP_DIR/$SERVICE_FILE" "/etc/systemd/system/$SERVICE_FILE"

sudo systemctl daemon-reload
sudo systemctl enable "$APP_NAME"
sudo systemctl restart "$APP_NAME"

echo "=== POS: finalizado com sucesso ==="
echo "Verifique os logs com:"
echo "sudo journalctl -u $APP_NAME -f"