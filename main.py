
import os
import time
import random
import requests
from bs4 import BeautifulSoup
from flask import Flask
import threading

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Telegram Setup
TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")
TELEGRAM_API_URL = f"https://api.telegram.org/bot{TOKEN}/sendMessage"

# Produkt-URLs
PRODUCT_URLS = [
    "https://www.mueller.de/p/pokemon-sammelkartenspiel-super-premium-kollektion-karmesin-purpur-prismatische-entwicklungen-PPN3101975/?itemId=3101975",
    ...
    "https://www.pokemoncenter.com/product/10-10027-101/pokemon-tcg-scarlet-and-violet-prismatic-evolutions-super-premium-collection"
]

CHECK_INTERVAL = 60 * 5  # 5 Minuten

def send_telegram_message(text):
    try:
        res = requests.get(TELEGRAM_API_URL, params={"chat_id": CHAT_ID, "text": text})
        if res.status_code != 200:
            print("[TELEGRAM] Fehler:", res.text)
    except Exception as e:
        print("[TELEGRAM] Ausnahme:", e)

def get_chrome_driver():
    chrome_options = Options()
    chrome_options.binary_location = "/opt/render/project/.render/chrome/opt/google/chrome/chrome"
    chrome_options.add_argument("--headless=new")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--window-size=1920,1080")
    return webdriver.Chrome(options=chrome_options)

def is_product_available(url):
    try:
        if "smythstoys.com" in url or "pokemoncenter.com" in url:
            print(f"[INFO] Selenium-Prüfung: {url}")
            driver = get_chrome_driver()
            driver.get(url)

            WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "body")))

            if "smythstoys.com" in url:
                print("[DEBUG] Suche Smyths-Button...")
                button = driver.find_elements(By.XPATH, "//button[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ', 'abcdefghijklmnopqrstuvwxyzäöü'), 'in den warenkorb')]")
                for btn in button:
                    if btn.is_enabled() and "cursor-not-allowed" not in btn.get_attribute("class"):
                        print("[DEBUG] Smyths verfügbar.")
                        driver.quit()
                        return True

            if "pokemoncenter.com" in url:
                print("[DEBUG] Suche PokémonCenter-Button...")
                button = driver.find_elements(By.CLASS_NAME, "add-to-cart-button--PZmQF")
                for btn in button:
                    text = btn.text.strip().upper()
                    print(f"[DEBUG] Button-Text: {text}")
                    if "ADD TO CART" in text:
                        print("[DEBUG] PokémonCenter verfügbar.")
                        driver.quit()
                        return True

            driver.quit()
            print("[DEBUG] Kein aktiver Button gefunden.")
            return False
        else:
            print(f"[INFO] BeautifulSoup-Prüfung: {url}")
            headers = {"User-Agent": "Mozilla/5.0"}
            res = requests.get(url, headers=headers)
            res.raise_for_status()
            soup = BeautifulSoup(res.text, "html.parser")

            button = soup.find(lambda tag:
                (tag.name == "button" or tag.name == "a") and
                "in den warenkorb" in tag.get_text(strip=True).lower())
            if button:
                return True

            not_available = soup.find(text=lambda t: t and "nicht verfügbar" in t.lower())
            return not not_available

    except Exception as e:
        print(f"[ERROR] Fehler bei {url}: {e}")
        return False

def check_availability():
    send_telegram_message("🔎 Produktüberwachung gestartet!")
    while True:
        for url in PRODUCT_URLS:
            print(f"[CHECK] {url}")
            if is_product_available(url):
                send_telegram_message(f"✅ Verfügbar: {url}")
            else:
                print("[INFO] Nicht verfügbar.")
            time.sleep(random.uniform(1, 5))
        print(f"[WARTEN] Nächster Check in {CHECK_INTERVAL // 60} Minuten.")
        time.sleep(CHECK_INTERVAL)

def send_heartbeat():
    while True:
        send_telegram_message("⏰ Service läuft weiter.")
        time.sleep(3600)

app = Flask(__name__)

@app.route("/")
def index():
    return "Produktüberwachung läuft."

@app.route("/health")
def health():
    return "OK"

if __name__ == "__main__":
    threading.Thread(target=check_availability, daemon=True).start()
    threading.Thread(target=send_heartbeat, daemon=True).start()
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
