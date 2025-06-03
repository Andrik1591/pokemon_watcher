#!/bin/bash

set -e

echo "[INFO] Setup ChromeDriver"

# Feste Version für Kompatibilität mit Google Chrome v137.x
CHROMEDRIVER_ZIP_URL="https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/137.0.7151.68/linux64/chromedriver-linux64.zip"
echo "[INFO] Lade ChromeDriver von $CHROMEDRIVER_ZIP_URL"

mkdir -p /opt/chromedriver-linux64
cd /opt/chromedriver-linux64

curl -sS -o chromedriver.zip $CHROMEDRIVER_ZIP_URL
unzip chromedriver.zip
rm chromedriver.zip

chmod +x chromedriver-linux64/chromedriver
ln -s /opt/chromedriver-linux64/chromedriver-linux64/chromedriver /usr/bin/chromedriver

echo "[INFO] ChromeDriver installiert unter /usr/bin/chromedriver"