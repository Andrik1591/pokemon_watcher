#!/bin/bash
set -e

echo "[SETUP] Installiere Chrome & ChromeDriver..."

# Install Chrome
apt-get update
apt-get install -y wget unzip curl gnupg

curl -sSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-linux.gpg
echo "deb [signed-by=/usr/share/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

apt-get update
apt-get install -y google-chrome-stable

# Install matching ChromeDriver
CHROME_VERSION=$(google-chrome-stable --version | grep -oP '\d+\.\d+\.\d+' | head -1)
CHROMEDRIVER_URL=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" | \
  grep -B2 "$CHROME_VERSION" | grep "linux64" | grep "url" | head -1 | cut -d'"' -f4)

echo "[INFO] Lade ChromeDriver von $CHROMEDRIVER_URL ..."
curl -Lo /tmp/chromedriver.zip "$CHROMEDRIVER_URL"
unzip /tmp/chromedriver.zip -d /usr/local/bin/
mv /usr/local/bin/chromedriver-linux64/chromedriver /usr/bin/chromedriver
chmod +x /usr/bin/chromedriver

echo "[SETUP] Chrome & ChromeDriver installiert."
