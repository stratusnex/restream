#!/bin/bash

# Define las URLs de los canales
declare -A CHANNELS=(
  ["CanalMPD"]="https://cdn.cvattv.com.ar/live/c4eds/Canal_5_Rosario/SA_Live_dash_cenc/Canal_5_Rosario.mpd"
)

# Define las claves ClearKey para los canales MPD (KEYID:KEY)
declare -A KEYS=(
  ["CanalMPD"]="17b3ea5b07979f719c9c1f29c566a04d:b7eee6522ad1abbcee2c096d55d1c175"
)

CHANNEL_ID="$1"
RTMP_SERVER="$2"
STREAM_KEY="$3"

STREAM_URL="${CHANNELS[$CHANNEL_ID]}"
CLEARKEY="${KEYS[$CHANNEL_ID]}"

if [ -z "$STREAM_URL" ]; then
  echo "Error: Canal '$CHANNEL_ID' no encontrado."
  exit 1
fi

# Construye el argumento DRM si el canal tiene clave configurada
DRM_OPT=""
if [ -n "$CLEARKEY" ]; then
  DRM_OPT="-c2p_key $CLEARKEY"
fi

echo "Iniciando $CHANNEL_ID..."
while true; do
  ffmpeg -rw_timeout 15000000 \
    -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 5 \
    $DRM_OPT \
    -i "$STREAM_URL" \
    -c:v copy -c:a copy \
    -bsf:a aac_adtstoasc \
    -f flv "$RTMP_SERVER/$STREAM_KEY"

  echo "Conexión perdida en $CHANNEL_ID. Reintentando en 5s..."
  sleep 5
done
