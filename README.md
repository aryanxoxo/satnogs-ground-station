# SatNOGS Ground Station Setup

> Public archive note: this repository is a portfolio/demo-safe version prepared from private working repositories/materials; sensitive details, credentials, raw logs, and proprietary context are intentionally omitted.

Linux setup notes, helper scripts, and configuration templates for a SatNOGS-style LEO satellite ground station using an SDR receiver, antenna system, optional az/el rotator, and SatNOGS Client.

This repository is a practical runbook for rebuilding the workflow: install the Linux radio stack, verify the SDR, configure SatNOGS Client, test pass prediction, and prepare the station for scheduled observations.

## What This Project Does

- Receives low Earth orbit satellite signals with an SDR.
- Uses TLE data and a ground-station location to predict visible passes.
- Supports a fixed antenna or Hamlib-compatible az/el rotator workflow.
- Provides Linux setup scripts for RTL-SDR, SoapySDR, Hamlib, GNU Radio, and Python tooling.
- Includes a small Python pass planner for station-level sanity checks before running full SatNOGS observations.

## Recommended Hardware

Minimum fixed-station setup:

- Raspberry Pi 4, mini PC, or Ubuntu/Debian laptop
- RTL-SDR Blog V3/V4 or equivalent SDR
- VHF/UHF antenna, such as a turnstile, QFH, V-dipole, or directional Yagi
- Coax with adapters, preferably short and low-loss
- Internet connection for TLE updates and SatNOGS Network scheduling

Stronger station setup:

- Low-noise amplifier near the antenna
- SAW/bandpass filtering for the target band
- Az/el rotator with an EasyComm or Yaesu GS-232 compatible controller
- Weatherproof antenna mount and strain relief
- GPS or NTP-backed time synchronization

## Repository Layout

```text
configs/
  satnogs-client.env.example      Example SatNOGS-style station variables
docs/
  hardware.md                     Hardware stack and wiring notes
  runbook.md                      Step-by-step bring-up and test sequence
scripts/
  01_install_linux_dependencies.sh
  02_configure_rtl_sdr.sh
  check_station.sh
  start_rotctld_example.sh
tools/
  pass_planner.py                 TLE pass predictor for station sanity checks
requirements.txt
```

## Quick Start

Use Debian, Ubuntu, or Raspberry Pi OS.

```bash
git clone https://github.com/aryanxoxo/satnogs-ground-station.git
cd satnogs-ground-station

chmod +x scripts/*.sh
sudo ./scripts/01_install_linux_dependencies.sh
sudo ./scripts/02_configure_rtl_sdr.sh
./scripts/check_station.sh
```

Create a Python environment for the pass-planning helper:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python tools/pass_planner.py --lat 49.2827 --lon -123.1207 --elevation-m 70 --tle examples/weather.tle
```

Replace the latitude/longitude with your station location.

## SatNOGS Client Setup

The standard SatNOGS path is to use SatNOGS Config / SatNOGS Ansible on a Debian-style host. This repository does not vendor the SatNOGS Client. It prepares the host and documents the station variables you need.

Typical flow:

1. Install Linux dependencies with `scripts/01_install_linux_dependencies.sh`.
2. Verify SDR access with `scripts/check_station.sh`.
3. Register or configure your station on SatNOGS Network.
4. Use SatNOGS Config / Ansible to install and apply the client configuration.
5. Copy values from `configs/satnogs-client.env.example` into the SatNOGS configuration menu or host variables.
6. Run a short test observation and compare waterfall/SNR against expected pass geometry.

## Important Configuration Values

At minimum, you need:

- Station latitude, longitude, and elevation
- SatNOGS station ID
- SatNOGS API token, if using the network client
- SDR device string, usually a SoapySDR string such as `driver=rtlsdr`
- Antenna type and gain estimate
- Rotator settings, if the station uses a rotator

See `configs/satnogs-client.env.example`.

## Useful Commands

Check SDR visibility:

```bash
rtl_test -t
SoapySDRUtil --find
```

Check rotator daemon example:

```bash
./scripts/start_rotctld_example.sh /dev/ttyUSB0
```

Check station readiness:

```bash
./scripts/check_station.sh
```

Predict upcoming visible passes from a local TLE file:

```bash
python tools/pass_planner.py --lat 37.7749 --lon -122.4194 --elevation-m 20 --tle examples/weather.tle --hours 24
```

## Project Description for Portfolio

Built a Linux-based satellite ground-station workflow for receiving LEO satellite telemetry. The station setup combines SDR hardware, antenna planning, TLE-based pass prediction, Doppler-aware reception workflow, and optional Hamlib rotator control. The supporting code verifies SDR/host readiness and predicts satellite pass windows before scheduling full SatNOGS observations.

## References

- SatNOGS Client documentation: https://docs.satnogs.org/projects/satnogs-client/en/latest/
- SatNOGS Config documentation: https://docs.satnogs.org/projects/satnogs-config/en/stable/
- SatNOGS setup wiki: https://wiki.satnogs.org/SatNOGS_Setup
- SatNOGS rotators wiki: https://wiki.satnogs.org/Rotators
- Hamlib rigctld documentation: https://hamlib.sourceforge.net/html/rigctld.1.html
