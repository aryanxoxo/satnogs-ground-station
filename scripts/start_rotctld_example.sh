#!/usr/bin/env bash
set -euo pipefail

DEVICE="${1:-/dev/ttyUSB0}"
MODEL="${ROTATOR_MODEL:-202}"
PORT="${ROTATOR_PORT:-4533}"
BAUD="${ROTATOR_BAUD:-9600}"

echo "Starting rotctld example"
echo "  model: ${MODEL}"
echo "  device: ${DEVICE}"
echo "  baud: ${BAUD}"
echo "  tcp port: ${PORT}"
echo
echo "Set ROTATOR_MODEL to the Hamlib model number for your controller."
echo "Press Ctrl+C to stop."

exec rotctld -m "${MODEL}" -r "${DEVICE}" -s "${BAUD}" -T 127.0.0.1 -t "${PORT}" -vvvv

