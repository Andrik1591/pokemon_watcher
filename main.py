import os
import time
import threading
import requests
from bs4 import BeautifulSoup
from flask import Flask
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")
TELEGRAM_API_URL = f"https://api.telegram.org/bot{TOKEN}/sendMessage"

PRODUCT_URLS = [
    "https://www.pokemoncenter.com/product/70-10312-101/ralts-kirlia-gardevoir-and-mega-gardevoir-pokemon-pixel-pins-4-pack",
    "https://www.smythstoys.com/de/de-de/spielzeug/action-spielzeug/pokemon/pokemon-karten-karmesin-und-purpur-prismatische-entwicklungen-super-premium-kollektion/p/250525"
]

CHECK_INTERVAL = 300  # alle 5 Minuten

def send_telegram_message(text):
    try:
        response = requests.get(TELEGRAM_API_URL, params={"chat_id": CHAT_ID, "text": text})
        if response.status_code != 200:
            print("Telegram Fehler:", response.text)
    except Exception as e:
        print("Telegram Exception:", e)

def is_product_available(url):
    try:
        if "smythstoys" in url or "pokemoncenter" in url:
            print(f"[INFO] Prüfe mit Selenium: {url}")
            chrome_options = Options()
            chrome_options.add_argument("--headless")
            chrome_options.add_argument("--no-sandbox")
            chrome_options.add_argument("--disable-dev-shm-usage")
            chrome_options.binary_location = "/usr/bin/chromium"

            driver = webdriver.Chrome(options=chrome_options)
            driver.get(url)

            time.sleep(2)

            if "smythstoys" in url:
                try:
                    buttons = driver.find_elements(By.TAG_NAME, "button")
                    for b in buttons:
                        if "in den warenkorb" in b.text.lower():
                            driver.quit()
                            return True
                except Exception:
                    pass

            if "pokemoncenter" in url:
                try:
                    buttons = driver.find_elements(By.CLASS_NAME, "add-to-cart-button--PZmQF")
                    for b in buttons:
                        if "add to cart" in b.text.lower():
                            driver.quit()
                            return True
                except Exception:
                    pass

            driver.quit()
            return False
        else:
            return False
    except Exception as e:
        print(f"[ERROR] Fehler bei {url}: {e}")
        return False

def check_loop():
    send_telegram_message("🔎 Produktüberwachung gestartet!")
    while True:
        for url in PRODUCT_URLS:
            print(f"[CHECK] {url}")
            if is_product_available(url):
                send_telegram_message(f"✅ VERFÜGBAR: {url}")
            else:
                print("Nicht verfügbar.")
            time.sleep(2)
        time.sleep(CHECK_INTERVAL)

def heartbeat():
    while True:
        send_telegram_message("⏰ Der Checker läuft noch.")
        time.sleep(3600)

app = Flask(__name__)

@app.route("/")
def index():
    return "Produkt-Checker läuft!"

@app.route("/health")
def health():
    return "OK"

if __name__ == "__main__":
    threading.Thread(target=check_loop, daemon=True).start()
    threading.Thread(target=heartbeat, daemon=True).start()

    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
