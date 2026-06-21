#!/usr/bin/env python3
"""Predict visible satellite passes from a TLE file for a ground station."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from datetime import timedelta
from pathlib import Path

from skyfield.api import EarthSatellite, load, wgs84


@dataclass
class PassEvent:
    name: str
    start_utc: str
    peak_utc: str
    end_utc: str
    max_elevation_deg: float


def parse_tle(path: Path) -> list[EarthSatellite]:
    lines = [line.strip() for line in path.read_text().splitlines() if line.strip()]
    satellites: list[EarthSatellite] = []
    i = 0
    ts = load.timescale()
    while i < len(lines):
      if i + 2 >= len(lines):
          break
      name, line1, line2 = lines[i], lines[i + 1], lines[i + 2]
      if line1.startswith("1 ") and line2.startswith("2 "):
          satellites.append(EarthSatellite(line1, line2, name, ts))
          i += 3
      else:
          i += 1
    return satellites


def predict_passes(
    satellites: list[EarthSatellite],
    lat: float,
    lon: float,
    elevation_m: float,
    hours: float,
    min_elevation: float,
) -> list[PassEvent]:
    ts = load.timescale()
    start = ts.now()
    end = ts.utc(start.utc_datetime() + timedelta(hours=hours))
    station = wgs84.latlon(lat, lon, elevation_m=elevation_m)
    events: list[PassEvent] = []

    for sat in satellites:
        times, event_codes = sat.find_events(station, start, end, altitude_degrees=min_elevation)
        for idx in range(0, len(times) - 2):
            if list(event_codes[idx : idx + 3]) != [0, 1, 2]:
                continue
            rise, peak, set_ = times[idx], times[idx + 1], times[idx + 2]
            difference = sat - station
            _, elevation, _ = difference.at(peak).altaz()
            events.append(
                PassEvent(
                    name=sat.name,
                    start_utc=rise.utc_strftime("%Y-%m-%d %H:%M:%S"),
                    peak_utc=peak.utc_strftime("%Y-%m-%d %H:%M:%S"),
                    end_utc=set_.utc_strftime("%Y-%m-%d %H:%M:%S"),
                    max_elevation_deg=float(elevation.degrees),
                )
            )

    return sorted(events, key=lambda event: event.start_utc)


def main() -> None:
    parser = argparse.ArgumentParser(description="Predict upcoming visible satellite passes from a TLE file.")
    parser.add_argument("--lat", type=float, required=True, help="Ground station latitude in degrees")
    parser.add_argument("--lon", type=float, required=True, help="Ground station longitude in degrees")
    parser.add_argument("--elevation-m", type=float, default=0.0, help="Ground station elevation in meters")
    parser.add_argument("--tle", type=Path, required=True, help="Path to a TLE file with name/line1/line2 triplets")
    parser.add_argument("--hours", type=float, default=24.0, help="Prediction window in hours")
    parser.add_argument("--min-elevation", type=float, default=10.0, help="Minimum pass elevation in degrees")
    args = parser.parse_args()

    satellites = parse_tle(args.tle)
    if not satellites:
        raise SystemExit(f"No satellites found in {args.tle}")

    events = predict_passes(satellites, args.lat, args.lon, args.elevation_m, args.hours, args.min_elevation)
    if not events:
        print("No visible passes found in the requested window.")
        return

    print(f"{'Satellite':28} {'Rise UTC':20} {'Peak UTC':20} {'Set UTC':20} Max El")
    print("-" * 96)
    for event in events:
        print(
            f"{event.name[:28]:28} {event.start_utc:20} {event.peak_utc:20} "
            f"{event.end_utc:20} {event.max_elevation_deg:5.1f}"
        )


if __name__ == "__main__":
    main()
