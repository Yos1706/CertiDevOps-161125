
LOG_DIR="/var/log"
BACKUP_DIR="/backup/logs"
LOG_FILE="/backup/logs/cleanup_logs.log"

echo "------ $(date '+%Y-%m-%d %H:%M:%S') | Inicio del proceso ------" >> "$LOG_FILE"

OLD_LOGS=$(find "$LOG_DIR" -type f -mtime +7)

if [[ -z "$OLD_LOGS" ]]; then
    echo "No se encontraron logs mayores a 7 días." >> "$LOG_FILE"
    exit 0
fi

for FILE in $OLD_LOGS; do
    BASENAME=$(basename "$FILE")
    TAR_NAME="$BASENAME.tar.gz"

    echo "Procesando archivo: $FILE" >> "$LOG_FILE"

    # Comprimir
    tar -czf "$BACKUP_DIR/$TAR_NAME" "$FILE"

    if [[ $? -eq 0 ]]; then
        echo "✔ Comprimido: $TAR_NAME" >> "$LOG_FILE"

        # Eliminar original
        rm "$FILE"
        echo "🗑 Eliminado original: $FILE" >> "$LOG_FILE"
    else
        echo "❌ Error al comprimir: $FILE" >> "$LOG_FILE"
    fi
done

echo "------ Fin del proceso ------" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

