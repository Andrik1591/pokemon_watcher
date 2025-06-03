FROM python:3.10-slim

# Systempakete installieren
RUN apt-get update && apt-get install -y wget unzip curl gnupg2 chromium chromium-driver

# Google Chrome installieren
RUN mkdir -p /opt/chrome &&     curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - &&     echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list &&     apt-get update && apt-get install -y google-chrome-stable

# Chrome + ChromeDriver Pfade setzen
ENV PATH="/opt/chromedriver-linux64:${PATH}"
ENV CHROME_BIN="/opt/google/chrome/chrome"

# Setup-Chromedriver-Skript hinzufügen
COPY setup_chromedriver.sh /setup_chromedriver.sh
RUN chmod +x /setup_chromedriver.sh && /setup_chromedriver.sh

# Python-Abhängigkeiten
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

# App-Code hinzufügen
COPY . /app

CMD ["python", "main.py"]