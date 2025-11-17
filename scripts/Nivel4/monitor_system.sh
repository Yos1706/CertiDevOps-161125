
set -euo pipefail

# =========================
# Configuración
# =========================
CPU_LIMIT=80
RAM_LIMIT=80
DISK_LIMIT=80
ALERT_FILE="$HOME/alerts.log"
DATE=$(date '+%Y%m%d')
METRICS_FILE="$HOME/metrics_$DATE.log"

# Colores
RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

# =========================
# Medir CPU, RAM y disco
# =========================
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100-$8}' | awk -F. '{print $1}')
RAM_USAGE=$(free -m | awk 'NR==2{printf "%.0f", $3/$2 * 100}')
DISK_USAGE=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

# Guardar métricas diarias
echo "$(date '+%Y-%m-%d %H:%M:%S') | CPU: $CPU_USAGE% | RAM: $RAM_USAGE% | DISCO: $DISK_USAGE%" >> "$METRICS_FILE"

# =========================
# Comprobar límites y alertar
# =========================
ALERTS=0

if [ "$CPU_USAGE" -ge "$CPU_LIMIT" ]; then
    echo -e "${RED}ALERTA CPU: $CPU_USAGE%${NC}" | tee -a "$ALERT_FILE"
    ALERTS=$((ALERTS+1))
else
    echo -e "${GREEN}CPU OK: $CPU_USAGE%${NC}"
fi

if [ "$RAM_USAGE" -ge "$RAM_LIMIT" ]; then
    echo -e "${RED}ALERTA RAM: $RAM_USAGE%${NC}" | tee -a "$ALERT_FILE"
    ALERTS=$((ALERTS+1))
else
    echo -e "${GREEN}RAM OK: $RAM_USAGE%${NC}"
fi

if [ "$DISK_USAGE" -ge "$DISK_LIMIT" ]; then
    echo -e "${RED}ALERTA DISCO: $DISK_USAGE%${NC}" | tee -a "$ALERT_FILE"
    ALERTS=$((ALERTS+1))
else
    echo -e "${GREEN}DISCO OK: $DISK_USAGE%${NC}"
fi

# =========================
# Enviar notificación si hay alertas
# =========================
if [ "$ALERTS" -gt 0 ]; then
    if [ -n "$WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"content\": \"ALERTA: Sistema sobrecargado. CPU: $CPU_USAGE%, RAM: $RAM_USAGE%, Disco: $DISK_USAGE%\"}" \
            "$WEBHOOK_URL"
    fi

    if [ -n "$EMAIL" ]; then
        echo "ALERTA: Sistema sobrecargado. CPU: $CPU_USAGE%, RAM: $RAM_USAGE%, Disco: $DISK_USAGE%" | mail -s "Alerta sistema $(hostname)" "$EMAIL"
    fi
fi

