#!/bin/bash
curl -o weather_events.csv.gz https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/StormEvents_details-ftp_v1.0_d2020_c20240620.csv.gz
gunzip -f weather_events.csv.gz