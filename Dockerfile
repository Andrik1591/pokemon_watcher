FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget unzip curl gnupg ca-certificates fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 \
    libcups2 libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 libxcomposite1 libxdamage1 \
    libxrandr2 xdg-utils libu2f-udev libvulkan1 libxss1 libnss3-dev chromium-driver chromium \
    && apt-get clean

# Set environment variables for Chrome
ENV CHROME_BIN="/usr/bin/chromium"
ENV CHROMEDRIVER_PATH="/usr/lib/chromium/chromedriver"

# Set working directory
WORKDIR /app

# Copy your project files
COPY . /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Start the app
CMD ["python", "main.py"]
