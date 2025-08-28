#!/bin/bash
set -euo pipefail

# Install prerequisites
sudo dnf update -y
sudo dnf install java-11-amazon-corretto unzip -y

# Optional user/group
sudo useradd --system --create-home ggc_user || true
sudo groupadd --system ggc_group || true

# Download and extract Greengrass installer
curl -s https://d2s8p88vqu9w66.cloudfront.net/releases/greengrass-nucleus-latest.zip \
    -o greengrass-nucleus-latest.zip
unzip -o greengrass-nucleus-latest.zip -d GreengrassInstaller

# Run installer with full provisioning
sudo -E java -Droot="/greengrass/v2" -Dlog.store=FILE \
    -jar ./GreengrassInstaller/lib/Greengrass.jar \
    --aws-region eu-central-1 \
    --thing-name gg-core \
    --component-default-user ggc_user:ggc_group \
    --provision true \
    --setup-system-service true \
    --deploy-dev-tools true
EOF


# sudo -E java -Droot="/greengrass/v2" -Dlog.store=FILE \
#     -jar ./GreengrassInstaller/lib/Greengrass.jar \
#     --aws-region eu-central-1 \
#     --thing-name gg-core \
#     --thing-group-name gg-core-group \
#     --thing-policy-name GreengrassV2IoTThingPolicy \
#     --tes-role-name GreengrassV2TokenExchangeRole \
#     --tes-role-alias-name GreengrassCoreTokenExchangeRoleAlias \
#     --component-default-user ggc_user:ggc_group \
#     --provision true \
#     --setup-system-service true \
#     --deploy-dev-tools true