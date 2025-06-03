# 🧪 Produkt Checker (Pokemon / Smyths / MediaMarkt)

Ein einfacher Verfügbarkeits-Checker für Online-Shops, mit Telegram-Benachrichtigungen und Docker.

## 🚀 Start (lokal)

```bash
docker build -t produkt-checker .
docker run -d --env-file .env -p 8080:8080 produkt-checker
```

## 🔧 .env Datei

```env
TELEGRAM_BOT_TOKEN=dein_token
TELEGRAM_CHAT_ID=deine_chat_id
PORT=8080
```

## 📬 Ergebnis

- Du bekommst eine Telegram-Nachricht, wenn ein Produkt verfügbar ist.
- Ein einfacher HTTP-Server zeigt unter `/health` "OK".

## 🛑 Stoppen

```bash
docker ps
docker stop <container_id>
```
