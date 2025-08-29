# Ultimate CTF Pwn Environment based on Arch Linux
# 基于Arch Linux的终极CTF Pwn环境
# Version: 3.0 - Production Ready
# 版本：3.0 - 生产就绪
FROM archlinux:latest
# 使用最新的Arch Linux作为基础镜像

# Metadata
# 元数据
LABEL maintainer="CTF Elite Team" \
      description="Ultimate Arch-based CTF Pwn environment with all tools pre-configured" \
      version="3.0" \
      category="security/ctf/pwn" \
      github="https://github.com/ctf-tools"

# Build arguments for customization
# 用于自定义的构建参数
ARG DEBIAN_FRONTEND=noninteractive
# 设置为非交互式模式，避免安装过程中的交互提示
ARG USER_NAME=pwner
# 默认用户名
ARG USER_UID=1000
# 用户UID
ARG USER_GID=1000
# 用户GID

# 定义构建时变量
ARG VERSION=3.0

# Use bash as the default shell
# 使用bash作为默认shell
SHELL [ "bash", "-c" ]

# Environment variables
# 环境变量设置
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash \
    TZ=Asia/Shanghai \
    VENV_PATH=/opt/venv \
    TOOLS_DIR=/opt/tools \
    WORDLISTS_DIR=/opt/wordlists \
    GLIBC_DIR=/opt/glibc \
    PATH="/opt/venv/bin:/opt/tools/bin:${PATH}" \
    PYTHONPATH="/opt/tools/lib/python" \
    LD_LIBRARY_PATH="/opt/glibc/2.23:/opt/glibc/2.27:/opt/glibc/2.31"
# 设置语言环境、时区、工具路径、虚拟环境路径、词表路径、glibc路径等环境变量
# 特别是将工具目录和虚拟环境目录添加到PATH中，方便使用工具

# System update and base packages installation
# 系统更新和基础包安装
RUN set -eux; \
    # Update system
    # 更新系统
    pacman -Syu --noconfirm && \
    # 安装开发工具
    pacman -S --noconfirm \
        base-devel \
        gcc-multilib \
        clang \
        cmake \
        make \
        automake \
        autoconf \
        libtool \
        pkg-config \
        # 版本控制工具
        git \
        subversion \
        mercurial \
        # Python生态系统
        python \
        python-pip \
        python-virtualenv \
        python-pyopenssl \
        python-numpy \
        python-scipy \
        python-matplotlib \
        ipython \
        jupyter-notebook \
        # 网络工具
        wget \
        curl \
        openbsd-netcat \
        socat \
        nmap \
        masscan \
        tcpdump \
        wireshark-cli \
        openvpn \
        proxychains-ng \
        tor \
        # 调试工具
        gdb \
        lldb \
        strace \
        ltrace \
        valgrind \
        # 二进制分析工具
        binutils \
        radare2 \
        rizin \
        elfutils \
        patchelf \
        hexedit \
        # 文件工具
        file \
        vim \
        # hexdump \
        dos2unix \
        p7zip \
        unrar \
        # 系统工具
        util-linux \
        procps-ng \
        psmisc \
        lsof \
        htop \
        iotop \
        sysstat \
        # 编辑器和终端
        neovim \
        nano \
        tmux \
        screen \
        zsh \
        fish \
        # 构建依赖
        openssl \
        libffi \
        zlib \
        xz \
        bzip2 \
        readline \
        ncurses \
        # Ruby生态系统
        ruby \
        ruby-rdoc \
        # 其他工具
        jq \
        yq \
        fzf \
        ripgrep \
        bat \
        exa \
        fd \
        parallel \
        moreutils \
        expect \
        asciinema \
        figlet \
        cowsay \
        lolcat && \
    # 清理包缓存
    yes | pacman -Scc
# 安装了大量用于CTF Pwn的常用工具，包括开发工具、调试工具、二进制分析工具等

# Install AUR helper (yay) for additional packages
# 安装AUR助手(yay)以获取额外的包
RUN set -eux; \
    useradd -m -G wheel builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    su - builduser -c "git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && \
        cd /tmp/yay-bin && \
        makepkg -si --noconfirm" && \
    userdel -r builduser && \
    sed -i '/builduser/d' /etc/sudoers
# 创建临时用户并安装yay(AUR助手)，然后清理临时用户
# yay是Arch Linux的AUR(Arch User Repository)助手，用于安装AUR中的软件包


# Create directory structure
# 创建目录结构
RUN set -eux; \
    mkdir -p ${TOOLS_DIR}/{bin,lib,share,exploits,wordlists,scripts} && \
    mkdir -p ${GLIBC_DIR}/{2.23,2.27,2.31,2.32,2.33,2.34,2.35} && \
    mkdir -p ${WORDLISTS_DIR} && \
    mkdir -p /home/CTF/{pwn,reverse,crypto,web,misc,forensics,mobile} && \
    mkdir -p /home/CTF/.templates/{pwn,shellcode,rop}
# 创建工具目录、不同版本的glibc目录、词表目录、CTF题目分类目录和模板目录

# Install multiple glibc versions for different challenges
# 安装多个glibc版本以适应不同的挑战
RUN set -eux; \
    cd /tmp && \
    # 下载常见的glibc版本
    for version in 2.23 2.27 2.31 2.32 2.33 2.34 2.35; do \
        wget -q "https://github.com/bminor/glibc/archive/refs/tags/glibc-${version}.tar.gz" || true; \
        if [ -f "glibc-${version}.tar.gz" ]; then \
            tar -xzf "glibc-${version}.tar.gz" && \
            rm "glibc-${version}.tar.gz"; \
        fi; \
    done
# 下载并解压多个版本的glibc源码，这些不同版本的glibc对于解决不同环境下的Pwn题目非常重要

# Ruby tools installation
# Ruby工具安装
RUN set -eux; \
    gem install --no-document \
        seccomp-tools \
        one_gadget \
        heapinfo \
        pry \
        zsteg && \
    gem cleanup
# 安装Ruby工具：seccomp-tools(seccomp工具)、one_gadget(获取one gadget RCE)、heapinfo(堆信息查看)、pry(Ruby调试器)、zsteg(隐写工具)

# Python virtual environment setup with comprehensive tools
# 设置Python虚拟环境并安装全面的工具
RUN set -eux; \
    python -m venv "${VENV_PATH}" && \
    "${VENV_PATH}/bin/python" -m pip install --upgrade pip setuptools wheel && \
    "${VENV_PATH}/bin/pip" install --no-cache-dir \
        # 核心PWN工具
        pwntools \
        ropper \
        ROPgadget \
        # 库搜索
        LibcSearcher \
        # 加密工具
        pycryptodome \
        gmpy2 \
        sympy \
        sage \
        # 二进制分析
        capstone \
        keystone-engine \
        unicorn \
        angr \
        manticore \
        miasm \
        # 模糊测试
        afl-utils \
        python-afl \
        boofuzz \
        # Web工具
        requests \
        beautifulsoup4 \
        lxml \
        selenium \
        # 取证工具
        volatility3 \
        python-magic \
        pyelftools \
        # 求解器和定理证明器
        z3-solver \
        claripy \
        # 网络工具
        scapy \
        impacket \
        paramiko \
        # 实用工具
        ipython \
        jupyter \
        colorama \
        termcolor \
        tabulate \
        tqdm \
        click \
        pyyaml \
        toml \
        # 调试助手
        gdb-pt-dump \
        exploitable \
        # 其他有用的包
        numpy \
        scipy \
        matplotlib \
        pandas \
        pillow \
        pypng \
        qrcode && \
    "${VENV_PATH}/bin/pip" cache purge
# 创建Python虚拟环境并安装大量CTF Pwn相关的Python包，包括pwntools、二进制分析工具、模糊测试工具等

# Create convenient symlinks
# 创建便捷的符号链接
RUN set -eux; \
    for tool in python python3 pip pip3 ipython jupyter ropper ropgadget; do \
        ln -sf "${VENV_PATH}/bin/${tool}" "/usr/local/bin/${tool}-venv" 2>/dev/null || true; \
    done
# 为虚拟环境中的常用工具创建符号链接，方便在全局路径中使用这些工具

# Install additional security tools
# 安装额外的安全工具
RUN set -eux; \
    cd ${TOOLS_DIR} && \
    # Checksec - 用于检查二进制文件的安全特性
    wget -O bin/checksec https://raw.githubusercontent.com/slimm609/checksec.sh/master/checksec && \
    chmod +x bin/checksec && \
    # Pwndbg - 高级GDB插件
    git clone https://github.com/pwndbg/pwndbg && \
    cd pwndbg && \
    ./setup.sh && \
    cd .. && \
    # GEF - GDB增强功能
    wget -O share/gef.py https://github.com/hugsy/gef/raw/main/gef.py && \
    # Peda - Python漏洞利用开发辅助
    git clone https://github.com/longld/peda.git share/peda && \
    # Pwngdb - 用于pwn的GDB插件
    git clone https://github.com/scwuaptx/Pwngdb.git share/Pwngdb && \
    # Libc database - libc数据库
    git clone https://github.com/niklasb/libc-database && \
    cd libc-database && \
    ./get ubuntu debian centos || true && \
    cd ..
# 安装额外的安全工具，包括checksec、GDB插件(pwndbg、GEF、Peda、Pwngdb)和libc数据库

# Install exploitation frameworks and tools
# 安装利用框架和工具
RUN set -eux; \
    cd ${TOOLS_DIR} && \
    # AFL++ - 高级模糊测试工具
    git clone https://github.com/AFLplusplus/AFLplusplus && \
    cd AFLplusplus && \
    make distrib && \
    make install && \
    cd .. && \
    # Honggfuzz - 另一个强大的模糊测试工具
    git clone https://github.com/google/honggfuzz && \
    cd honggfuzz && \
    make && \
    make install && \
    cd .. && \
    # House of force/mind/spirit等堆利用技术模板
    git clone https://github.com/shellphish/how2heap exploits/how2heap && \
    # 内核利用
    git clone https://github.com/xairy/kernel-exploits exploits/kernel && \
    # Windows利用
    git clone https://github.com/SecWiki/windows-kernel-exploits exploits/windows
# 安装利用框架和工具，包括模糊测试工具(AFL++、Honggfuzz)和利用技术收集(how2heap、kernel-exploits、windows-kernel-exploits)

# Install WebSocketReflectorX
# 安装WebSocketReflectorX
RUN set -eux; \
    LATEST_TAG=$(curl -s "https://api.github.com/repos/XDSEC/WebSocketReflectorX/releases/latest" | grep '"tag_name"' | cut -d '"' -f 4) && \
    if [ -n "${LATEST_TAG}" ]; then \
        DOWNLOAD_URL="https://github.com/XDSEC/WebSocketReflectorX/releases/download/${LATEST_TAG}/wsrx-cli-${LATEST_TAG}-linux-musl-x86_64.tar.gz" && \
        curl -L "${DOWNLOAD_URL}" -o /tmp/wsrx-cli.tar.gz && \
        tar -xzf /tmp/wsrx-cli.tar.gz -C /tmp && \
        rm -f /tmp/wsrx-cli.tar.gz && \
        chmod +x /tmp/wsrx && \
        mv /tmp/wsrx ${TOOLS_DIR}/bin/wsrx \
    fi
# 下载并安装WebSocketReflectorX，这是一个用于网络流量转发的工具

# Install rr - Lightweight recording and deterministic debugging tool
# 安装rr - 轻量级录制和确定性调试工具
RUN set -eux; \
    LATEST_TAG=$(curl -s "https://api.github.com/repos/rr-debugger/rr/releases/latest" | grep '"tag_name"' | cut -d '"' -f 4) && \
    if [ -n "${LATEST_TAG}" ]; then \
        DOWNLOAD_URL="https://github.com/rr-debugger/rr/releases/download/${LATEST_TAG}/rr-${LATEST_TAG}-Linux-x86_64.tar.gz" && \
        curl -L "${DOWNLOAD_URL}" -o /tmp/rr.tar.gz && \
        tar -xzf /tmp/rr.tar.gz -C /opt && \
        ln -s /opt/rr-${LATEST_TAG}-Linux-x86_64/bin/rr /usr/local/bin/rr; \
    fi


# Download common wordlists
# 下载常用词表
RUN set -eux; \
    cd ${WORDLISTS_DIR} && \
    # SecLists - 安全测试常用词表集合
    git clone --depth 1 https://github.com/danielmiessler/SecLists && \
    # 常见密码
    wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt && \
    # 模糊测试载荷
    git clone --depth 1 https://github.com/fuzzdb-project/fuzzdb
# 下载常用词表，包括SecLists、常见密码列表和模糊测试载荷，用于密码破解和模糊测试

# Configure GDB with multiple plugins support
# 配置GDB以支持多个插件
COPY ./config/.gdbinit /root/.gdbinit
# 复制GDB配置文件到root用户的.gdbinit，用于配置GDB的默认行为和插件加载

# Create non-root user with sudo privileges
# 创建具有sudo权限的非root用户
RUN set -eux; \
    groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -G wheel -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    # 将GDB配置复制到用户目录
    cp /root/.gdbinit /home/${USER_NAME}/.gdbinit && \
    chown ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.gdbinit
# 创建非root用户(pwner)并赋予sudo权限，将GDB配置复制到用户目录，确保用户可以使用GDB插件

# Setup shell configurations (bash, zsh, fish)
# 设置shell配置(bash, zsh, fish)
COPY ./config/shell/* /etc/skel/
# 复制shell配置文件到/etc/skel目录，这些配置将应用于新创建的用户

# Install Oh My Zsh for better shell experience
# 安装Oh My Zsh以获得更好的shell体验
RUN set -eux; \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
        # 安装Oh My Zsh插件：自动建议和语法高亮
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    # 修改zsh配置文件，启用新安装的插件
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker kubectl)/' ~/.zshrc

# Create useful scripts
# 创建实用脚本
COPY ./bin ${TOOLS_DIR}/bin/autopwn
# 将本地bin目录下的脚本复制到容器中的工具目录，命名为autopwn

# Create useful templates
# 创建实用模板
COPY ./templates ${TOOLS_DIR}/templates
# 将本地templates目录下的模板复制到容器中的工具目录

# 设置工作目录
WORKDIR /home/CTF
# 将容器启动后的默认工作目录设置为/home/CTF，方便直接进入CTF工作环境

# 切换到非root用户
USER ${USER_NAME}
# 切换到之前创建的非root用户(pwner)，提高安全性
# 注意：之前的操作都是以root用户执行的，现在切换到普通用户进行日常操作

# 设置容器启动命令
CMD [ "zsh" ]
# 容器启动后默认执行zsh shell，提供更好的交互体验
# 由于之前安装了Oh My Zsh及其插件，用户将获得功能强大的shell环境

# 暴露常用端口（可选）
EXPOSE 22 4444 5555 8000 8080
# 暴露CTF中常用的端口：
# 22 - SSH
# 4444/5555 - 常用Pwn监听端口
# 8000/8080 - Web服务端口
# 注意：实际使用时可能需要通过-p参数映射这些端口

# 健康检查（可选）
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD zsh -c "echo 'Container is healthy'" || exit 1
# 设置健康检查，每30秒检查一次容器状态
# 如果zsh能正常执行简单命令，则认为容器健康

# 优化镜像大小（可选）
# 注意：这些指令应该放在最后，因为它们会创建新的镜像层
RUN set -eux; \
    # 清理系统日志
    find /var/log -type f -exec truncate -s 0 {} \; && \
    # 清理临时文件
    rm -rf /tmp/* /var/tmp/* && \
    # 清理pacman缓存
    yes | pacman -Scc && \
    # 清理APT缓存（如果使用过）
    if [ -x "$(command -v apt-get)" ]; then \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*; \
    fi && \
    # 清理pip缓存
    if [ -d "${VENV_PATH}" ]; then \
        "${VENV_PATH}/bin/pip" cache purge; \
    fi && \
    # 清理gem缓存
    gem cleanup > /dev/null 2>&1 || true
# 清理不必要的文件和缓存，减小镜像大小
# 包括日志文件、临时文件、包管理器缓存和Python/Ruby缓存

# 添加构建信息
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.authors="Tobeko" \
      org.opencontainers.image.url="https://github.com/hjki156/PWN" \
      org.opencontainers.image.documentation="https://github.com/hjki156/PWN/blob/main/README.md" \
      org.opencontainers.image.source="https://github.com/hjki156/PWN.git" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.title="CTF Pwn Environment" \
      org.opencontainers.image.description="Ultimate Arch-based CTF Pwn environment with all tools pre-configured"
# 添加符合OCI规范的镜像标签，包含构建信息
# 这些标签有助于镜像的识别和管理