#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo $0" >&2
  exit 1
fi

apt-get update
apt-get install -y \
  git \
  curl \
  ca-certificates \
  python3 \
  python3-venv \
  python3-pip \
  rtl-sdr \
  soapysdr-tools \
  soapysdr-module-rtlsdr \
  gnuradio \
  gqrx-sdr \
  hamlib-utils \
  predict \
  chrony \
  jq

systemctl enable --now chrony || true

echo
echo "Linux dependencies installed."
echo "Next: sudo ./scripts/02_configure_rtl_sdr.sh"

