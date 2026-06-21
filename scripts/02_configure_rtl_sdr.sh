#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo $0" >&2
  exit 1
fi

RULE_FILE="/etc/udev/rules.d/20-rtlsdr.rules"
cat > "${RULE_FILE}" <<'EOF'
# RTL-SDR USB access for non-root users
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", GROUP="plugdev", MODE="0666", SYMLINK+="rtl_sdr"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="plugdev", MODE="0666", SYMLINK+="rtl_sdr"
EOF

BLACKLIST_FILE="/etc/modprobe.d/blacklist-rtl-sdr.conf"
cat > "${BLACKLIST_FILE}" <<'EOF'
# Prevent DVB driver from claiming RTL-SDR dongles
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830
EOF

udevadm control --reload-rules
udevadm trigger

USER_TO_ADD="${SUDO_USER:-$USER}"
if getent group plugdev >/dev/null; then
  usermod -aG plugdev "${USER_TO_ADD}" || true
fi

echo
echo "RTL-SDR udev rules installed."
echo "Unplug/replug the SDR. If access still fails, reboot once."

