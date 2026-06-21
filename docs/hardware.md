# Hardware Notes

## Receiver

An RTL-SDR is enough for a first working station. A better receiver chain adds an LNA and a bandpass filter near the antenna to improve weak-signal performance and reduce overload.

Recommended checks:

- Run `rtl_test -t` after USB setup.
- Run `SoapySDRUtil --find` and confirm the SDR appears.
- Use a known local FM broadcast or NOAA weather pass as an RF sanity check.
- Record gain and PPM correction after calibration.

## Antenna

Fixed antennas are simpler and are useful for wide sky coverage:

- V-dipole for quick NOAA/APT style tests
- Turnstile or QFH for circular polarization and better overhead coverage
- UHF/VHF dual-band vertical for basic amateur satellite reception

Directional antennas improve gain but require tracking:

- VHF/UHF Yagi
- Crossed Yagi
- Helical antenna for specific circular-polarized downlinks

## Rotator

SatNOGS can use Hamlib-compatible rotators. The client talks to a local Hamlib daemon such as `rotctld`. Homebuilt controllers usually expose EasyComm or Yaesu GS-232 style protocols over serial/USB.

Typical rotator test path:

```bash
./scripts/start_rotctld_example.sh /dev/ttyUSB0
rotctl -m 2 -r localhost:4533 p
```

Replace the model and serial device with your controller values.

## Timing

Satellite passes are short. Keep the host synchronized:

```bash
timedatectl
chronyc tracking
```

## Station Metadata

Document these values before running observations:

- Latitude / longitude / elevation
- Antenna type and estimated gain
- Cable type and approximate loss
- SDR model and serial number
- Gain and PPM settings
- Rotator model and serial path, if used

