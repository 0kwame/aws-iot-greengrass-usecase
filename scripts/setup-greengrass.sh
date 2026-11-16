#!/bin/bash
set -euo pipefail

# Install prerequisites
sudo apt update -y
sudo apt install -y default-jdk awscli unzip python3 python3-pip python3-venv

# Optional user/group
sudo useradd --system --create-home ggc_user || true
sudo groupadd --system ggc_group || true

# Create Greengrass directory first, then set ownership
sudo mkdir -p /greengrass
sudo chown -R ubuntu:ubuntu /greengrass

# Download and extract Greengrass installer
curl -s https://d2s8p88vqu9w66.cloudfront.net/releases/greengrass-nucleus-latest.zip \
    -o greengrass-nucleus-latest.zip
unzip -o greengrass-nucleus-latest.zip -d GreengrassInstaller

# Get the Token Exchange Role details from instance metadata or environment
# These should be passed as template variables from Terraform
TES_ROLE_NAME="${tes_role_name}"
TES_ROLE_ALIAS="${tes_role_alias}"

# Run Greengrass installer with all required parameters
sudo -E java -Droot="/greengrass/v2" -Dlog.store=FILE \
  -jar ./GreengrassInstaller/lib/Greengrass.jar \
  --aws-region eu-central-1 \
  --thing-name gg-core-demo-01 \
  --tes-role-name "$TES_ROLE_NAME" \
  --tes-role-alias-name "$TES_ROLE_ALIAS" \
  --component-default-user ggc_user:ggc_group \
  --provision true \
  --setup-system-service true \
  --deploy-dev-tools true

echo "Greengrass installation completed successfully!"