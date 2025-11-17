

LOG_FILE="./service_status.log"

if [ "$#" -lt 0 ]; then
  echo "Uso: $0 <nombre_servicio>"
  exit 1
fi

SERVICE="$1"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

STATUS=$(systemctl is-active "$SERVICE")

echo "[$TIMESTAMP] Servicio '$SERVICE' está $STATUS." | tee -a "$LOG_FILE"

if [ "$STATUS" != "active" ]; then
  echo "ALERTA: El servicio '$SERVICE' NO está activo."
fi

