FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    chromium chromium-driver \
    curl gnupg2 unzip && \
    apt-get clean

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir flask selenium requests beautifulsoup4

ENV TELEGRAM_BOT_TOKEN=changeme
ENV TELEGRAM_CHAT_ID=changeme

CMD ["python", "main.py"]
