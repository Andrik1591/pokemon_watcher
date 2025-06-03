# Dockerfile
FROM python:3.11-slim

# Installiere Abhängigkeiten
RUN apt-get update && apt-get install -y \
    wget curl unzip gnupg2 \
    chromium-driver chromium

# Setze Arbeitsverzeichnis
WORKDIR /app

# Kopiere lokale Dateien ins Container-Verzeichnis
COPY . /app

# Installiere Python-Abhängigkeiten
RUN pip install flask selenium requests beautifulsoup4

# Setze Umgebungsvariablen (zur Sicherheit besser über .env oder docker run -e)
ENV TELEGRAM_BOT_TOKEN=dein_token
ENV TELEGRAM_CHAT_ID=deine_chat_id

# Starte das Skript
CMD ["python", "main.py"]
