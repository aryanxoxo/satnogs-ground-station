#!/usr/bin/env bash
set -euo pipefail

failures=0

check_cmd() {
  local cmd="$1"
  if command -v "${cmd}" >/dev/null 2>&1; then
    echo "[ok] ${cmd}"
  else
    echo "[missing] ${cmd}"
    failures=$((failures + 1))
  fi
}

echo "Checking ground-station host tools..."
check_cmd rtl_test
check_cmd SoapySDRUtil
check_cmd gnuradio-companion
check_cmd rotctld
check_cmd python3

echo
echo "Checking SDR detection..."
if command -v SoapySDRUtil >/dev/null 2>&1; then
  SoapySDRUtil --find || failures=$((failures + 1))
fi

echo
echo "Checking RTL-SDR quick probe..."
if command -v rtl_test >/dev/null 2>&1; then
  timeout 10 rtl_test -t || {
    echo "[warn] rtl_test did not complete cleanly. Check USB permissions, blacklist rules, or dongle connection."
    failures=$((failures + 1))
  }
fi

echo
if [[ "${failures}" -eq 0 ]]; then
  echo "Station host looks ready for SatNOGS client configuration."
else
  echo "Station host has ${failures} warning(s). Fix them before scheduling observations."
fi

exit "${failures}"

