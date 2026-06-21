# Ground Station Runbook

## 1. Prepare Linux Host

```bash
sudo ./scripts/01_install_linux_dependencies.sh
sudo ./scripts/02_configure_rtl_sdr.sh
```

Unplug and replug the SDR after installing udev rules. Reboot if Linux still claims the dongle with the DVB driver.

## 2. Verify SDR

```bash
./scripts/check_station.sh
rtl_test -t
SoapySDRUtil --find
```

Expected result: SDR visible without root privileges.

## 3. Verify Antenna Chain

Start with an easy signal:

- FM broadcast band for receiver sanity
- NOAA weather satellites for pass-based testing
- Local amateur repeater or beacon if available

Record the antenna, coax, LNA/filter state, gain, and PPM values.

## 4. Predict Passes

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python tools/pass_planner.py --lat 49.2827 --lon -123.1207 --elevation-m 70 --tle examples/weather.tle --hours 24
```

Use this to choose a high-elevation test pass before scheduling observations.

## 5. Configure SatNOGS Client

Use the official SatNOGS Config / Ansible workflow for the client install. Copy values from `configs/satnogs-client.env.example` into the configuration menu or host variables.

Core values:

- Station ID
- Station coordinates
- SDR device string
- RF gain and PPM correction
- Rotator enabled/disabled
- Rotator port/model, if applicable

## 6. Rotator Test, If Used

```bash
ROTATOR_MODEL=202 ROTATOR_BAUD=9600 ./scripts/start_rotctld_example.sh /dev/ttyUSB0
```

In another terminal:

```bash
rotctl -m 2 -r localhost:4533 p
```

Do not run unattended until end stops, home position, and coordinate directions are confirmed.

## 7. First Observation

Pick a high-elevation pass. Watch for:

- waterfall signal appearing near expected time
- stable SDR sample rate
- correct frequency correction behavior
- usable SNR near peak elevation
- no USB dropouts
- rotator position tracking, if used

## 8. Post-Run Notes

Log:

- satellite and pass time
- maximum elevation
- RF gain
- antenna and LNA/filter state
- observed SNR
- decode success/failure
- hardware issues

