# 使用Ubuntu最新LTS版本作为基础镜像，提供更好的稳定性和安全更新
FROM ubuntu:24.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash \
    TZ=Asia/Shanghai

# 合并所有apt操作以减少镜像层数，提高构建效率
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # 编译工具链
        build-essential \
        gcc-multilib \
        g++-multilib \
        libc6-dev-i386 \
        # 版本控制
        git \
        # Python环境
        python3 \
        python3-pip \
        python3-dev \
        python3-venv \
        # 网络工具
        wget \
        curl \
        netcat-openbsd \
        socat \
        # 调试工具
        gdb \
        gdb-multiarch \
        strace \
        ltrace \
        # 二进制分析工具
        binutils \
        patchelf \
        file \
        xxd \
        bsdextrautils \
        # 终端和编辑器
        tmux \
        neovim \
        nano \
        # 系统工具
        sudo \
        tree \
        htop \
        unzip \
        zip \
        # 依赖库
        lsb-release \
        ca-certificates \
        libssl-dev \
        libffi-dev \
        zlib1g-dev \
        # 中文支持
        language-pack-zh-hans \
        # Ruby环境（用于seccomp-tools）
        ruby \
        ruby-dev && \
    # 清理apt缓存
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# 手动安装radare2（因为Ubuntu 22.04仓库中没有）
RUN wget -q https://github.com/radareorg/radare2/releases/download/5.9.0/radare2_5.9.0_amd64.deb && \
    dpkg -i radare2_5.9.0_amd64.deb || true && \
    apt-get update && \
    apt-get -f install -y && \
    rm radare2_5.9.0_amd64.deb

# 安装Ruby工具
RUN gem install seccomp-tools one_gadget && \
    gem cleanup

# 升级pip并安装Python工具
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir \
        # 主要pwn工具
        pwntools \
        # ROP链生成器
        ropper \
        # 格式化字符串漏洞利用
        LibcSearcher \
        # 其他有用的工具
        requests \
        z3-solver \
        capstone \
        keystone-engine \
        unicorn && \
    # 清理pip缓存
    pip3 cache purge

# 安装checksec安全检查工具
RUN curl -s -o /usr/local/bin/checksec https://raw.githubusercontent.com/slimm609/checksec.sh/master/checksec && \
    chmod +x /usr/local/bin/checksec

# 安装GEF（GDB增强框架）
RUN wget -O /tmp/gef.py https://github.com/hugsy/gef/raw/main/gef.py && \
    # 为root用户配置GEF
    echo 'source /tmp/gef.py' > /root/.gdbinit && \
    echo 'set disassembly-flavor intel' >> /root/.gdbinit && \
    echo 'set confirm off' >> /root/.gdbinit

# 创建非特权用户pwner
RUN useradd -m -s /bin/bash -G sudo pwner && \
    echo "pwner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    # 为pwner用户配置GEF
    echo 'source /tmp/gef.py' > /home/pwner/.gdbinit && \
    echo 'set disassembly-flavor intel' >> /home/pwner/.gdbinit && \
    echo 'set confirm off' >> /home/pwner/.gdbinit && \
    chown pwner:pwner /home/pwner/.gdbinit

# 安装和配置Neovim
# RUN git clone --depth=1 https://github.com/folke/lazy.nvim.git \
#         ~/.local/share/nvim/site/pack/packer/start/lazy.nvim && \
#     git clone --depth=1 https://github.com/folke/lazy.nvim.git \
#         /home/pwner/.local/share/nvim/site/pack/packer/start/lazy.nvim && \
#     chown -R pwner:pwner /home/pwner/.local/

# 复制Neovim配置（如果存在）
# COPY --chown=root:root ./config/nvim/ /root/.config/nvim/
# COPY --chown=pwner:pwner ./config/nvim/ /home/pwner/.config/nvim/

# 设置工作目录
WORKDIR /home/CTF

# 安装WebSocketReflectorX工具
RUN set -eux; \
    # 获取最新版本标签
    LATEST_TAG=$(curl -s "https://api.github.com/repos/XDSEC/WebSocketReflectorX/releases/latest" | \
                 grep '"tag_name"' | \
                 cut -d '"' -f 4); \
    echo "正在安装 WebSocketReflectorX 版本: ${LATEST_TAG}"; \
    # 构建下载URL
    DOWNLOAD_URL="https://github.com/XDSEC/WebSocketReflectorX/releases/download/${LATEST_TAG}/wsrx-cli-${LATEST_TAG}-linux-musl-x86_64.tar.gz"; \
    # 下载并解压
    curl -L "${DOWNLOAD_URL}" -o wsrx-cli.tar.gz && \
    tar -xzf wsrx-cli.tar.gz && \
    rm wsrx-cli.tar.gz && \
    chmod +x wsrx && \
    # 将工具链接到PATH
    ln -s /root/CTF/wsrx /usr/local/bin/wsrx

# 复制模板文件
COPY --chown=root:root ./templates/ /home/CTF/
COPY --chown=pwner:pwner ./templates/ /home/pwner/CTF/

# 创建一些有用的别名和环境设置
RUN echo 'alias ll="ls -la"' >> /root/.bashrc && \
    echo 'alias la="ls -A"' >> /root/.bashrc && \
    echo 'alias l="ls -CF"' >> /root/.bashrc && \
    echo 'alias ..="cd .."' >> /root/.bashrc && \
    echo 'alias ...="cd ../.."' >> /root/.bashrc && \
    echo 'alias grep="grep --color=auto"' >> /root/.bashrc && \
    echo 'alias fgrep="fgrep --color=auto"' >> /root/.bashrc && \
    echo 'alias egrep="egrep --color=auto"' >> /root/.bashrc && \
    echo 'export EDITOR=nvim' >> /root/.bashrc && \
    echo 'export PAGER=less' >> /root/.bashrc && \
    # 同样为pwner用户设置
    echo 'alias ll="ls -la"' >> /home/pwner/.bashrc && \
    echo 'alias la="ls -A"' >> /home/pwner/.bashrc && \
    echo 'alias l="ls -CF"' >> /home/pwner/.bashrc && \
    echo 'alias ..="cd .."' >> /home/pwner/.bashrc && \
    echo 'alias ...="cd ../.."' >> /home/pwner/.bashrc && \
    echo 'alias grep="grep --color=auto"' >> /home/pwner/.bashrc && \
    echo 'alias fgrep="fgrep --color=auto"' >> /home/pwner/.bashrc && \
    echo 'alias egrep="egrep --color=auto"' >> /home/pwner/.bashrc && \
    echo 'export EDITOR=nvim' >> /home/pwner/.bashrc && \
    echo 'export PAGER=less' >> /home/pwner/.bashrc && \
    chown pwner:pwner /home/pwner/.bashrc

# 创建CTF工作目录结构
SHELL [ "/bin/bash", "-c" ]
RUN mkdir -p ./{exploits,tools,challenges,scripts} && \
    mkdir -p /home/pwner/CTF/{exploits,tools,challenges,scripts} && \
    chown -R pwner:pwner /home/pwner/CTF

# 为 root 用户配置自动进入 /root/CTF
RUN echo 'cd /home/CTF 2>/dev/null || true' >> /root/.bashrc

# 为 pwner 用户配置自动进入 /home/pwner/CTF
RUN echo 'cd /home/pwner/CTF 2>/dev/null || true' >> /home/pwner/.bashrc

# 暴露常用端口（可选）
EXPOSE 1337 4444 8080 9999

# 设置启动消息和命令
CMD ["bash", "-c", "echo '🎉 CTF Pwn环境已就绪！' && echo '🔧 已安装工具：pwntools, gdb+gef, radare2, checksec等' && echo '👤 用户：root 和 pwner（sudo权限）' && echo '📁 工作目录：/home/CTF' && echo '🚀 开始你的CTF之旅吧！' && exec /bin/bash"]

# 添加健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python3 -c "import pwn; print('pwntools works!')" || exit 1

# 元数据标签
LABEL maintainer="CTF Team" \
      description="完整的CTF Pwn环境，包含调试和漏洞利用工具" \
      version="2.0" \
      category="security/ctf"