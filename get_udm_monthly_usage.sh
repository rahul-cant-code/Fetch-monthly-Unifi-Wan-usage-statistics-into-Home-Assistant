#!/bin/bash
UDM_IP=$(grep udm_ip /config/secrets.yaml | awk '{ print $2 }')
UDM_API_KEY=$(grep udm_api_key /config/secrets.yaml | awk '{ print $2 }')

RESPONSE=$(curl -sk \
  -H "X-API-KEY: $UDM_API_KEY" \
  -H "Accept: application/json" \
  "https://$UDM_IP/proxy/network/v2/api/site/default/aggregated-dashboard?historySeconds=864000")

# Extract WAN1 data
WAN1_GB=$(echo "$RESPONSE" | jq '.wan.wan_details[0].stats.monthly_bytes // 0' | awk '{ print int($1 / (1000**3) + 0.5) }')
WAN1_NAME=$(echo "$RESPONSE" | jq -r '.wan.wan_details[0].isp.name // "Not Connected"')
WAN1_NETWORK=$(echo "$RESPONSE" | jq -r '.wan.wan_details[0].network_name // "WAN1"')

# Extract WAN2 data if exists
WAN2_EXISTS=$(echo "$RESPONSE" | jq '.wan.wan_details[1] // empty')
if [ -n "$WAN2_EXISTS" ]; then
    WAN2_GB=$(echo "$RESPONSE" | jq '.wan.wan_details[1].stats.monthly_bytes // 0' | awk '{ print int($1 / (1000**3) + 0.5) }')
    WAN2_NAME=$(echo "$RESPONSE" | jq -r '.wan.wan_details[1].isp.name // "Not Connected"')
    WAN2_NETWORK=$(echo "$RESPONSE" | jq -r '.wan.wan_details[1].network_name // "WAN2"')
else
    WAN2_GB=0
    WAN2_NAME="Not Connected"
    WAN2_NETWORK="WAN2"
fi

# Output comprehensive JSON
cat << EOF
{
  "wan1": {
    "usage_gb": $WAN1_GB,
    "isp_name": "$WAN1_NAME",
    "network_name": "$WAN1_NETWORK"
  },
  "wan2": {
    "usage_gb": $WAN2_GB,
    "isp_name": "$WAN2_NAME",
    "network_name": "$WAN2_NETWORK"
  }
}
EOF