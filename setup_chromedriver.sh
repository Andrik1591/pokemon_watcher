#!/bin/bash

# Alte Chromedriver entfernen (wenn vorhanden)
rm -f /usr/bin/chromedriver

# Chromedriver Version 137.0.7151.68 herunterladen
wget https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/137.0.7151.68/linux64/chromedriver-linux64.zip -O /tmp/chromedriver.zip

# Entpacken
unzip /tmp/chromedriver.zip -d /tmp/

# Verschieben nach /usr/bin und ausführbar machen
mv /tmp/chromedriver-linux64/chromedriver /usr/bin/chromedriver
chmod +x /usr/bin/chromedriver

# Fertig
echo "Chromedriver 137.0.7151.68 installiert."
