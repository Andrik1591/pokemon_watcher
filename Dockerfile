FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget curl gnupg unzip \
    fonts-liberation libatk-bridge2.0-0 libatk1.0-0 libcups2 \
    libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 \
    libxcomposite1 libxdamage1 libxrandr2 xdg-utils \
    libu2f-udev libvulkan1 libasound2 libxss1 libgbm1 && \
    rm -rf /var/lib/apt/lists/*

# Install Chrome + ChromeDriver
COPY setup_chromedriver.sh /setup_chromedriver.sh
RUN chmod +x /setup_chromedriver.sh && /setup_chromedriver.sh

# Set environment for Chrome
ENV CHROME_BIN=/usr/bin/google-chrome
ENV PATH=$PATH:/usr/bin

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . /app
WORKDIR /app

# Start your app
CMD ["python", "main.py"]
