# Dockerfile
FROM frozenkp/pwn

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

RUN apt-get update && \
    apt-get install -y language-pack-zh-hans wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root/CTF

RUN wget -O wsrx-cli.tar.gz https://github.com/XDSEC/WebSocketReflectorX/releases/download/0.5.9/wsrx-cli-0.5.9-linux-musl-x86_64.tar.gz && \
    tar -xzvf wsrx-cli.tar.gz && \
    rm wsrx-cli.tar.gz

CMD echo "Start your Pwn travel~" && /bin/bash
