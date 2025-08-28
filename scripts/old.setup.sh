#!/bin/bash
set -euo pipefail

# Install required packages
sudo dnf install -y unzip

sudo useradd --system --create-home ggc_user
sudo groupadd --system ggc_group

# Define variables
GREENGRASS_URL="https://d2s8p88vqu9w66.cloudfront.net/releases/greengrass-nucleus-latest.zip"
ZIP_FILE="greengrass-nucleus-latest.zip"
INSTALL_DIR="GreengrassInstaller"

# Download Greengrass Nucleus
echo "Downloading Greengrass Nucleus..."
curl -s "$GREENGRASS_URL" -o "$ZIP_FILE"

# Must setup AWS credentials and export `AWS_ACCESS_KEY_ID` and `AWS_SECRET_KEY`

sudo -E java -Droot="/greengrass/v2" -Dlog.store=FILE -jar ./GreengrassInstaller/lib/Greengrass.jar  \
    --aws-region eu-central-1 \
    --thing-name gg-demo-core  \
    --component-default-user ggc_user:ggc_group \
    --provision true \
    --setup-system-service true \
    --deploy-dev-tools true

# Create install directory and unzip
echo "Extracting Greengrass Nucleus to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
unzip -o "$ZIP_FILE" -d "$INSTALL_DIR"

echo "✅ Setup completed successfully."
