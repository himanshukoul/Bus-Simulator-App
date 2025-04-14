# Bus Tracking App

two R scripts:

- `bus_api.R`: Simulates a bus tracking API using Plumber.
- `bus_app.R`: A Shiny app for real-time bus tracking with Leaflet.

## Setup

1. Install R and required packages: `shiny`, `leaflet`, `plumber`, `httr`, `jsonlite`.
2. Run `bus_api.R` to start the API.
3. Copy the random endpoint generated there.
4. Paste it in url present in bus_app.
5. Run `bus_app.R` to launch the Shiny app.

## Usage

- Start the API: `bus_api.R`
- Open the Shiny app: `bus_app.R`
