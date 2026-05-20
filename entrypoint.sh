#!/bin/bash
set -e

# Добавляем пути, куда устанавливаются утилиты amnezia-wg
export PATH="/usr/local/sbin:/usr/local/bin:$PATH"

# Поднимаем туннель, если конфиг примонтирован
if [ -f "$WG_CONF_PATH" ]; then
    echo "[INFO] Запуск AmneziaWG интерфейса wg0..."
    amnezia-wg-quick up "$WG_CONF_PATH"
else
    echo "[WARN] Файл $WG_CONF_PATH не найден. Запускаем только 3proxy без VPN."
fi

echo "[INFO] Запуск 3proxy SOCKS5 на порту 1080..."
# 3proxy запустится в foreground (режим демона отключён в конфиге)
exec 3proxy /etc/3proxy/3proxy.cfg