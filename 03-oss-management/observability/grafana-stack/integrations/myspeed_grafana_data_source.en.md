<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/grafana-stack/integrations/myspeed_grafana_data_source.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🔌 SOP: Grafana & MySpeed Integration (Infinity Data Source)

### 📝 Description

This document is the Standard Operating Procedure (SOP) to integrate **Grafana** (Presentation Layer) and **MySpeed** (Performance and Capacity Test Engine).

The architecture uses the **Infinity** plugin to make direct calls via REST API. This *serverless* method removes the need for a middle Time Series Database (TSDB). It makes the infrastructure smaller and helps to check the ISP's SLA (Service Level Agreement) efficiently.

##

### 🛠️ Step 1: Plugin Installation

MySpeed does not have a native Data Source. So, we use the Infinity Data Source (made by the community) to read the JSON from the API.

```bash
# Downloads the REST/JSON plugin
sudo grafana cli plugins install yesoreyeram-infinity-datasource

# Restarts the presentation layer service
sudo systemctl restart grafana-server
```

##

### 🌐 Step 2: Data Source Configuration

With the plugin installed, register the API in Grafana:

   * On the left menu in Grafana, go to `Connections > Data sources`.

   * Click the `Add data source` button and search for Infinity.

   * In the main configuration (`Authentication/Network`), MySpeed allows anonymous connection to read data. You do not need to put passwords or Tokens.

   * Scroll to the bottom and click `Save & Test`.

##

### 🔗 Step 3: Query Configuration (Dashboard)

The integration happens when you create the panels. Grafana makes On-Demand requests to the internal database (SQLite) of MySpeed.

In a Dashboard, create a new Panel and select Infinity as the Data Source.

Configure the logic extraction parameters:

   * Type: `JSON` 

   * Parser: `Default`

   * Method: `GET`

   * URL: `http://<MYSPEED_IP>:<PORT>/api/speedtests`

***Architecture Note (L2/L3 Integration):*** *If both containers are in the same Docker bridge network, change the IP to the internal hostname. Example: http://myspeed:5216/api/speedtests.*

On the Parsing tab, map the JSON columns to format the Time Series:

   * `timestamp` column -> Type: DateTime

   * `download`, `upload`, `ping` columns -> Type: Number

***Performance Management Best Practice (FCAPS):*** *We recommend adjusting the MySpeed engine (Cron) to run tests only two times a day: Off-Peak (e.g., 04:00) and Peak Traffic (e.g., 16:00). In Grafana, use the "Bars" visual instead of "Lines". This contrasts the maximum normal speed with the speed during high traffic.*

##

### ✅ Success Criteria:

The integration is valid when the Grafana panel shows the graph blocks. This proves the JSON payload was received with HTTP 200 OK status and parsed correctly on the screen, with no Timeout or CORS errors.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
