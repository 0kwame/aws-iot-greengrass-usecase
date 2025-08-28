#!/bin/bash
set -euo pipefail

# Install prerequisites
sudo apt update -y
sudo apt install default-jdk awscli unzip -y

# Optional user/group
sudo useradd --system --create-home ggc_user || true
sudo groupadd --system ggc_group || true

# Prepare Greengrass certs directory
sudo mkdir -p /greengrass/certs
sudo chown -R ubuntu:ubuntu /greengrass

# Write IoT certificates and keys (injected by Terraform templatefile)
# cat > /greengrass/certs/device.pem.crt <<CERT
# ${certificate_pem}
# CERT

# cat > /greengrass/certs/private.pem.key <<KEY
# ${private_key}
# KEY

# cat > /greengrass/certs/public.pem.key <<PUB
# ${public_key}
# PUB

# # Download Amazon Root CA 1
# mkdir -p /greengrass/certs
# curl -o /greengrass/certs/AmazonRootCA1.pem \
#   https://www.amazontrust.com/repository/AmazonRootCA1.pem

# Download and extract Greengrass installer
curl -s https://d2s8p88vqu9w66.cloudfront.net/releases/greengrass-nucleus-latest.zip \
    -o greengrass-nucleus-latest.zip
unzip -o greengrass-nucleus-latest.zip -d GreengrassInstaller

# # Run Greengrass installer
# sudo -E java -Droot="/greengrass/v2" -Dlog.store=FILE \
#   -jar ./GreengrassInstaller/lib/Greengrass.jar \
#   --aws-region ${region} \
#   --thing-name ${thing_name} \
#   --thing-policy-name ${thing_policy_name} \
#   --tes-role-name ${tes_role_name} \
#   --tes-role-alias-name ${tes_role_alias} \
#   --component-default-user ggc_user:ggc_group \
#   --deploy-dev-tools true \
#   --provision false \
#   --setup-system-service true \
#   --thing-cert-path /greengrass/certs/device.pem.crt \
#   --thing-private-key-path /greengrass/certs/private.pem.key \
#   --root-ca-path /greengrass/certs/AmazonRootCA1.pem


sudo -E java -Droot="/greengrass/v2" -Dlog.store=FILE \
  -jar ./GreengrassInstaller/lib/Greengrass.jar \
  --aws-region eu-central-1 \
  --thing-name gg-core-demo-01  \
  --component-default-user ggc_user:ggc_group \
  --provision true \
  --setup-system-service true \
  --deploy-dev-tools true