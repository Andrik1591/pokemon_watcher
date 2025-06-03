#!/bin/bash
set -e

echo "[SETUP] Installiere Google Chrome..."
apt-get update
apt-get install -y curl unzip gnupg wget

# Google Chrome installieren
curl -sSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
  > /etc/apt/sources.list.d/google-chrome.list

apt-get update
apt-get install -y google-chrome-stable

echo "[INFO] Chrome installiert, Version:"
google-chrome-stable --version

# Chrome-Version extrahieren
CHROME_VERSION=$(google-chrome-stable --version | grep -oP '\d+\.\d+\.\d+' | head -1)

if [ -z "$CHROME_VERSION" ]; then
  echo "[ERROR] Chrome-Version konnte nicht erkannt werden."
  exit 1
fi

echo "[INFO] Chrome-Version: $CHROME_VERSION"

# Hole die passende ChromeDriver-Version
echo "[SETUP] Lade passende ChromeDriver-Version..."
CHROMEDRIVER_ZIP_URL=$(curl -s https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json | \
  grep -B2 "\"version\": \"$CHROME_VERSION\"" | \
  grep "url" | grep "linux64" | grep -v "arm" | cut -d'"' -f4)

if [ -z "$CHROMEDRIVER_ZIP_URL" ]; then
  echo "[ERROR] Keine passende ChromeDriver-Version gefunden für $CHROME_VERSION"
  exit 2
fi

echo "[INFO] Lade ChromeDriver von $CHROMEDRIVER_ZIP_URL"
curl -Lo /tmp/chromedriver.zip "$CHROMEDRIVER_ZIP_URL"
unzip /tmp/chromedriver.zip -d /tmp/chromedriver

# Installiere ChromeDriver
mv /tmp/chromedriver/*/chromedriver /usr/bin/chromedriver
chmod +x /usr/bin/chromedriver

echo "[SETUP] ChromeDriver installiert."
