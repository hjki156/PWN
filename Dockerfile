# Dockerfile
FROM frozenkp/pwn

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

RUN apt-get update && \
    apt-get install -y language-pack-zh-hans wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "set encoding=utf-8" > ~/.vimrc

WORKDIR /root/CTF

RUN set -eux; \
    LATEST_TAG=$$( \
        curl -s "https://api.github.com/repos/XDSEC/WebSocketReflectorX/releases/latest" | \
        grep '"tag_name"' | \
        cut -d '"' -f 4 \
    ) \
    echo "latest: $${LATEST_TAG}" \
    DOWNLOAD_URL="https://github.com/XDSEC/WebSocketReflectorX/releases/download/$${LATEST_TAG}/wsrx-cli-$${LATEST_TAG}-linux-musl-x86_64.tar.gz" \
    curl -L "$${DOWNLOAD_URL}" -o wsrx-cli.tar.gz \
    tar -xzf wsrx-cli.tar.gz \
    rm wsrx-cli.tar.gz \
    chmod +x wsrx

COPY ./templates/ ./

CMD ["bash", "-c", "echo '🎉 Pwn 环境已就绪！' && exec /bin/bash"]
