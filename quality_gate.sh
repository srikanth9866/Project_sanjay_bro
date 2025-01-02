#!/bin/bash

# Variables (Update these for your setup)
SONARQUBE_URL="http://3.108.221.93:9000"    # Replace with your SonarQube server URL
API_TOKEN="squ_daccff1af8d69c33717915118173c2b1da0e539c"   # Replace with your API token
QUALITY_GATE_NAME="MyQualityGate_39"        # Replace with your desired Quality Gate name

# Step 1: Create the Quality Gate
echo "Creating Quality Gate: $QUALITY_GATE_NAME..."
CREATE_RESPONSE=$(curl -s -u "$API_TOKEN:" -X POST "$SONARQUBE_URL/api/qualitygates/create" -d "name=$QUALITY_GATE_NAME")

# Debugging the response to ensure correct output
echo "Raw response: $CREATE_RESPONSE"

# Step 2: Fetch the created Quality Gate ID by searching for its name
echo "Fetching Quality Gate ID for name: $QUALITY_GATE_NAME..."
GATE_ID_RESPONSE=$(curl -s -u "$API_TOKEN:" "$SONARQUBE_URL/api/qualitygates/list")

# Extract the ID using grep and awk
QUALITY_GATE_ID=$(echo "$GATE_ID_RESPONSE" | grep -oP "\"name\":\"$QUALITY_GATE_NAME\".*?\"id\":\"\K[^\"]+")

# If the ID is missing or null, handle the error
if [[ -z "$QUALITY_GATE_ID" ]]; then
  echo "Error: Unable to find the ID for Quality Gate '$QUALITY_GATE_NAME'. Response: $GATE_ID_RESPONSE"
  exit 1
fi

echo "Quality Gate created with ID: $QUALITY_GATE_ID"

# Step 3: Add Conditions to the Quality Gate
echo "Adding conditions to the Quality Gate..."

# Condition 1: Code Coverage < 80%
curl -s -u "$API_TOKEN:" -X POST "$SONARQUBE_URL/api/qualitygates/create_condition" \
  -d "gateId=$QUALITY_GATE_ID" \
  -d "metric=coverage" \
  -d "op=LT" \
  -d "error=80"

# Condition 2: Bugs > 0
curl -s -u "$API_TOKEN:" -X POST "$SONARQUBE_URL/api/qualitygates/create_condition" \
  -d "gateId=$QUALITY_GATE_ID" \
  -d "metric=bugs" \
  -d "op=GT" \
  -d "error=0"

# Condition 3: Technical Debt Ratio > 5%
curl -s -u "$API_TOKEN:" -X POST "$SONARQUBE_URL/api/qualitygates/create_condition" \
  -d "gateId=$QUALITY_GATE_ID" \
  -d "metric=sqale_debt_ratio" \
  -d "op=GT" \
  -d "error=5"

echo "Conditions added successfully."

# Step 4: Display Quality Gate Details
echo "Fetching Quality Gate Details..."
curl -s -u "$API_TOKEN:" "$SONARQUBE_URL/api/qualitygates/show?id=$QUALITY_GATE_ID" | grep -oP "\"name\":\"$QUALITY_GATE_NAME\".*"

echo "Quality Gate setup completed successfully."
