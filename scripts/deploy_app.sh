
set -euo pipefail
IFS=$'\n\t'

# =========================
# Configuración
# =========================
REPO_URL="https://github.com/rayner-villalba-coderoad-com/clash-of-clan"
DEPLOY_DIR="/var/www/clash-of-clan"
LOG_FILE="/var/log/deploy.log"
SERVICE_NAME="nginx"   

TIMESTAMP() { date "+%Y-%m-%d %H:%M:%S"; }

echo "------ $(TIMESTAMP) | Inicio del despliegue ------" >> "$LOG_FILE"

# =========================
# Clonar o actualizar el repositorio
# =========================
if [ ! -d "$DEPLOY_DIR/.git" ]; then
    echo "$(TIMESTAMP) Clonando repositorio..." | tee -a "$LOG_FILE"
    git clone "$REPO_URL" "$DEPLOY_DIR" >> "$LOG_FILE" 2>&1 || { echo "ERROR: Falló git clone"; exit 1; }
else
    echo "$(TIMESTAMP) Actualizando repositorio..." | tee -a "$LOG_FILE"
    cd "$DEPLOY_DIR"
    git fetch origin >> "$LOG_FILE" 2>&1 || { echo "ERROR: Falló git fetch"; exit 1; }
    git reset --hard origin/main >> "$LOG_FILE" 2>&1 || { echo "ERROR: Falló git reset"; exit 1; }
fi

echo "$(TIMESTAMP) Reiniciando servicio $SERVICE_NAME..." | tee -a "$LOG_FILE"
sudo systemctl restart "$SERVICE_NAME" >> "$LOG_FILE" 2>&1 || { echo "ERROR: Falló reinicio de servicio"; exit 1; }





