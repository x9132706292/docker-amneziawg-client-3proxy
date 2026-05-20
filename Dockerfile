FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    WG_CONF_PATH=/etc/amnezia/wg0.conf

# Установка зависимостей
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential pkg-config libmnl-dev iproute2 wget ca-certificates \
    bash coreutils procps openresolv 3proxy \
    && rm -rf /var/lib/apt/lists/*

# Сборка и установка amneziawg-tools из исходников
RUN git clone https://github.com/amnezia-vpn/amneziawg-tools.git /tmp/amneziawg-tools && \
    cd /tmp/amneziawg-tools && \
    make && \
    make install && \
    rm -rf /tmp/amneziawg-tools

# Настройка 3proxy (SOCKS5 на порту 1080, работа в foreground для Docker)
RUN mkdir -p /etc/3proxy /var/log/3proxy && \
    printf '%s\n' \
        'nserver 8.8.8.8' \
        'nserver 1.1.1.1' \
        'nscache 65536' \
        'timeouts 1 5 30 60 180 1800 15 60' \
        'log /var/log/3proxy/3proxy.log D' \
        'logformat "- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T"' \
        'socks -p1080' \
    > /etc/3proxy/3proxy.cfg

# Скрипт запуска
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 1080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]