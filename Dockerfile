# 基于 Arch Linux 的 CTF Pwn 环境
FROM archlinux:latest

# 环境变量
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash \
    TZ=Asia/Shanghai \
    VENV_PATH=/opt/venv

# 避免交互，更新系统并安装所需软件
RUN set -eux; \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        base-devel \
        gcc-multilib \
        git \
        python \
        python-pip \
        python-virtualenv \
        python-pyopenssl \
        wget \
        curl \
        netcat \
        socat \
        gdb \
        gdb-multiarch \
        strace \
        ltrace \
        binutils \
        patchelf \
        file \
        xxd \
        util-linux \
        tmux \
        neovim \
        nano \
        sudo \
        tree \
        htop \
        unzip \
        zip \
        openssl \
        libffi \
        zlib \
        ruby \
        ruby-devel || true; \
    # 清理 pacman 缓存以减小镜像
    rm -rf /var/cache/pacman/pkg/*

# 安装 Ruby 工具
RUN set -eux; \
    gem install seccomp-tools one_gadget && \
    gem cleanup || true

# 在镜像内创建 venv 并用 venv 的 pip 安装 Python 包以避免系统改动
RUN set -eux; \
    python -m venv "${VENV_PATH}" && \
    "${VENV_PATH}/bin/python" -m pip install --upgrade pip setuptools wheel && \
    "${VENV_PATH}/bin/pip" install --no-cache-dir \
        pwntools \
        ropper \
        LibcSearcher \
        requests \
        z3-solver \
        capstone \
        keystone-engine \
        unicorn && \
    "${VENV_PATH}/bin/pip" cache purge && \
    ln -sf "${VENV_PATH}/bin/python" /usr/local/bin/python3-venv && \
    ln -sf "${VENV_PATH}/bin/pip" /usr/local/bin/pip3-venv

# 安装 checksec（脚本）
RUN set -eux; \
    curl -s -o /usr/local/bin/checksec https://raw.githubusercontent.com/slimm609/checksec.sh/master/checksec && \
    chmod +x /usr/local/bin/checksec

# 安装 GEF（GDB 增强框架）
RUN set -eux; \
    wget -O /tmp/gef.py https://github.com/hugsy/gef/raw/main/gef.py && \
    echo 'source /tmp/gef.py' > /root/.gdbinit && \
    echo 'set disassembly-flavor intel' >> /root/.gdbinit && \
    echo 'set confirm off' >> /root/.gdbinit

# 创建非特权用户 pwner 并为其配置 GEF
RUN set -eux; \
    useradd -m -s /bin/bash -G wheel pwner && \
    echo "pwner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo 'source /tmp/gef.py' > /home/pwner/.gdbinit && \
    echo 'set disassembly-flavor intel' >> /home/pwner/.gdbinit && \
    echo 'set confirm off' >> /home/pwner/.gdbinit && \
    chown pwner:pwner /home/pwner/.gdbinit

# 复制 Neovim 配置（如果存在）
COPY --chown=root:root ./config/nvim/ /root/.config/nvim/
COPY --chown=pwner:pwner ./config/nvim/ /home/pwner/.config/nvim/

# 设置工作目录
WORKDIR /home/CTF

# 安装 WebSocketReflectorX 工具（下载二进制并放到 path）
RUN set -eux; \
    LATEST_TAG=$(curl -s "https://api.github.com/repos/XDSEC/WebSocketReflectorX/releases/latest" | grep '"tag_name"' | cut -d '"' -f 4) && \
    echo "Installing WebSocketReflectorX ${LATEST_TAG}" && \
    DOWNLOAD_URL="https://github.com/XDSEC/WebSocketReflectorX/releases/download/${LATEST_TAG}/wsrx-cli-${LATEST_TAG}-linux-musl-x86_64.tar.gz" && \
    curl -L "${DOWNLOAD_URL}" -o /tmp/wsrx-cli.tar.gz && \
    tar -xzf /tmp/wsrx-cli.tar.gz -C && \
    rm -f /tmp/wsrx-cli.tar.gz && \
    chmod +x /tmp/wsrx && \
    mv -sf /tmp/wsrx /usr/local/bin/wsrx || true

# radare2: 尝试使用 pacman 安装，如果不存在才从 release 下载预编译二进制
RUN set -eux; \
    if pacman -Ss --noconfirm radare2 | grep -q "extra/radare2"; then \
        pacman -S --noconfirm radare2 || true; \
    else \
        # fallback: 从 release 下载可执行（若上游提供 tar.gz）
        R2_URL="https://github.com/radareorg/radare2/releases/download/5.9.0/radare2-5.9.0-x86_64-linux.tar.gz"; \
        curl -L "${R2_URL}" -o /tmp/radare2.tar.gz || true; \
        if [ -f /tmp/radare2.tar.gz ]; then \
            tar -xzf /tmp/radare2.tar.gz -C /usr/local/bin --strip-components=1 || true; \
            rm -f /tmp/radare2.tar.gz || true; \
        fi; \
    fi

# 复制模板文件
COPY --chown=root:root ./templates/ /home/CTF/
COPY --chown=pwner:pwner ./templates/ /home/pwner/CTF/

# 创建别名和环境设置（root 和 pwner）
RUN set -eux; \
    for user_home in /root /home/pwner; do \
      rc="$user_home/.bashrc"; \
      echo 'alias ll="ls -la"' >> "$rc"; \
      echo 'alias la="ls -A"' >> "$rc"; \
      echo 'alias l="ls -CF"' >> "$rc"; \
      echo 'alias ..="cd .."' >> "$rc"; \
      echo 'alias ...="cd ../.."' >> "$rc"; \
      echo 'alias grep="grep --color=auto"' >> "$rc"; \
      echo 'alias fgrep="fgrep --color=auto"' >> "$rc"; \
      echo 'alias egrep="egrep --color=auto"' >> "$rc"; \
      echo 'export EDITOR=nvim' >> "$rc"; \
      echo 'export PAGER=less' >> "$rc"; \
    done && \
    chown pwner:pwner /home/pwner/.bashrc || true

# 创建 CTF 工作目录结构
SHELL [ "/bin/bash", "-c" ]
RUN set -eux; \
    mkdir -p /home/CTF/{exploits,tools,challenges,scripts} && \
    mkdir -p /home/pwner/CTF/{exploits,tools,challenges,scripts} && \
    chown -R pwner:pwner /home/pwner/CTF

# 自动进入目录
RUN echo 'cd /home/CTF 2>/dev/null || true' >> /root/.bashrc
RUN echo 'cd /home/pwner/CTF 2>/dev/null || true' >> /home/pwner/.bashrc

# 暴露端口（可选）
EXPOSE 1337 4444 8080 9999

# 启动命令
CMD ["bash", "-c", "echo '🎉 CTF Pwn环境已就绪！' && echo '🔧 已安装工具：pwntools, gdb+gef, radare2, checksec等' && echo '👤 用户：root 和 pwner（sudo权限）' && echo '📁 工作目录：/home/CTF' && echo '🚀 开始你的CTF之旅吧！' && exec /bin/bash"]

# 健康检查使用 venv 中的 python
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /opt/venv/bin/python -c "import pwn; print('pwntools works!')" || exit 1

# 元数据标签
LABEL maintainer="CTF Team" \
      description="Arch-based CTF Pwn environment" \
      version="2.0" \
      category="security/ctf"
