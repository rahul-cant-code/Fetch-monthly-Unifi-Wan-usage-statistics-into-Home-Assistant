# Fetch monthly usage from Unifi controller

The current Unifi Network integration in Home Assistant appears to be missing tracking of monthly WAN usage statistics. This is a simple shell script that fetches the data from the v2 API for Wan 1 and Wan 2 interfaces.

Output
```
network_name: Primary (WAN1)
unit_of_measurement: GB
icon: mdi:wan
friendly_name: YOUR_ISP_NAME
state: 900.0
```
```
network_name: Secondary (WAN2)
unit_of_measurement: GB
icon: mdi:wan
friendly_name: Not Connected
state: 0.0
```


## Pre-requisite
A Unifi API key is required.

Generate a fresh API key from `Control Panel > Integrations` or re-use existing API key.


## Configuration

### 1. Shell script
Place `get_udm_monthly_usage.sh` file in `config/scripts/`

* Set your UDM IP and API key in your secrets.yaml file
* If you do not have or do not want to use secrets.yaml, directly configure the values in the sh file.

e.g (include quotes):
```
UDM_IP="192.168.1.1"
UDM_API_KEY="12345678"
```

### 2. Place command_line file or copy code to wherever you are maintaining command_line scripts

If copying file, place it alongside configuration.yaml or sensor.yaml location.

Ensure command_line.yaml is included in configuration.yaml


### 3. Place below sensors in your template.yaml file

```
- sensor:
      # WAN1 Usage
    - name: "{{ (states('sensor.udm_wan_monthly_usage') | from_json).wan1.isp_name }}"
      unique_id: "udm_wan1_monthly_usage"
      state: "{{ (states('sensor.udm_wan_monthly_usage') | from_json).wan1.usage_gb | float(0) }}"
      unit_of_measurement: "GB"
      icon: mdi:wan
      attributes:
        network_name: "{{ (states('sensor.udm_wan_monthly_usage') | from_json).wan1.network_name }}"
    # WAN2 Usage
    - name: "{{ (states('sensor.udm_wan_monthly_usage') | from_json).wan2.isp_name }}"
      unique_id: "udm_wan2_monthly_usage"
      state: "{{ (states('sensor.udm_wan_monthly_usage') | from_json).wan2.usage_gb | float(0) }}"
      unit_of_measurement: "GB"
      icon: mdi:wan
      attributes:
        network_name: "{{ (states('sensor.udm_wan_monthly_usage') | from_json).wan2.network_name }}"
```

### 4. Sample lovelace card

```
type: gauge
entity: sensor.udm_wan1_monthly_usage
max: 3300
min: 0
needle: true
severity:
  green: 0
  yellow: 2400
  red: 3000
grid_options:
  columns: 6
  rows: auto
```