
FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    fonts-liberation libappindicator3-1 libasound2 libnspr4 libnss3 libxss1 libxtst6 \
    wget gnupg unzip curl \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_BIN=/usr/bin/chromium
ENV PATH="$CHROME_BIN:$PATH"

WORKDIR /app
COPY . .

RUN pip install --no-cache-dir -r requirements.txt

# Kopiere das Setup-Skript ins Image
COPY setup_chromedriver.sh /setup_chromedriver.sh
RUN chmod +x /setup_chromedriver.sh && /setup_chromedriver.sh

# Führe das Setup-Skript aus
RUN /bin/bash /setup_chromedriver.sh

CMD ["python", "main.py"]
