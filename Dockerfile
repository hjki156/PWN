# Ultimate CTF Pwn Environment based on Arch Linux
# Version: 3.0 - Production Ready
FROM archlinux:latest

# Metadata
LABEL maintainer="CTF Elite Team" \
      description="Ultimate Arch-based CTF Pwn environment with all tools pre-configured" \
      version="3.0" \
      category="security/ctf/pwn" \
      github="https://github.com/ctf-tools"

# Use bash as the default shell
SHELL [ "bash", "-c" ]

# Build arguments for customization
ARG DEBIAN_FRONTEND=noninteractive
ARG USER_NAME=pwner
ARG USER_UID=1000
ARG USER_GID=1000

# Environment variables
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash \
    TZ=Asia/Shanghai \
    VENV_PATH=/opt/venv \
    TOOLS_DIR=/opt/tools \
    WORDLISTS_DIR=/opt/wordlists \
    GLIBC_DIR=/opt/glibc \
    PATH="/opt/venv/bin:/opt/tools/bin:${PATH}" \
    PYTHONPATH="/opt/tools/lib/python:${PYTHONPATH}" \
    LD_LIBRARY_PATH="/opt/glibc/2.23:/opt/glibc/2.27:/opt/glibc/2.31:${LD_LIBRARY_PATH}"

# System update and base packages installation
RUN set -eux; \
    # Configure pacman for better performance
    echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist && \
    echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist && \
    # Update system
    pacman -Syu --noconfirm && \
    # Install development tools
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
        # Version control
        git \
        subversion \
        mercurial \
        # Python ecosystem
        python \
        python-pip \
        python-virtualenv \
        python-pyopenssl \
        python-numpy \
        python-scipy \
        python-matplotlib \
        ipython \
        jupyter-notebook \
        # Network tools
        wget \
        curl \
        netcat \
        socat \
        nmap \
        masscan \
        tcpdump \
        wireshark-cli \
        openvpn \
        proxychains-ng \
        tor \
        # Debugging tools
        gdb \
        lldb \
        strace \
        ltrace \
        valgrind \
        rr \
        # Binary analysis
        binutils \
        radare2 \
        rizin \
        elfutils \
        patchelf \
        hexedit \
        # File utilities
        file \
        xxd \
        hexdump \
        dos2unix \
        p7zip \
        unrar \
        # System utilities
        util-linux \
        procps-ng \
        psmisc \
        lsof \
        htop \
        iotop \
        sysstat \
        # Editors and terminals
        neovim \
        nano \
        tmux \
        screen \
        zsh \
        fish \
        # Build dependencies
        openssl \
        libffi \
        zlib \
        xz \
        bzip2 \
        readline \
        ncurses \
        # Ruby ecosystem
        ruby \
        ruby-rdoc \
        # Misc tools
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
    # Clean package cache
    yes | pacman -Scc

# Install AUR helper (yay) for additional packages
RUN set -eux; \
    useradd -m -G wheel builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    su - builduser -c "git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && \
        cd /tmp/yay-bin && \
        makepkg -si --noconfirm" && \
    userdel -r builduser && \
    sed -i '/builduser/d' /etc/sudoers

# Create directory structure
RUN set -eux; \
    mkdir -p ${TOOLS_DIR}/{bin,lib,share,exploits,wordlists,scripts} && \
    mkdir -p ${GLIBC_DIR}/{2.23,2.27,2.31,2.32,2.33,2.34,2.35} && \
    mkdir -p ${WORDLISTS_DIR} && \
    mkdir -p /home/CTF/{pwn,reverse,crypto,web,misc,forensics,mobile} && \
    mkdir -p /home/CTF/.templates/{pwn,shellcode,rop}

# Install multiple glibc versions for different challenges
RUN set -eux; \
    cd /tmp && \
    # Download common glibc versions
    for version in 2.23 2.27 2.31 2.32 2.33 2.34 2.35; do \
        wget -q "https://github.com/bminor/glibc/archive/refs/tags/glibc-${version}.tar.gz" || true; \
        if [ -f "glibc-${version}.tar.gz" ]; then \
            tar -xzf "glibc-${version}.tar.gz" && \
            rm "glibc-${version}.tar.gz"; \
        fi; \
    done

# Ruby tools installation
RUN set -eux; \
    gem install --no-document \
        seccomp-tools \
        one_gadget \
        heapinfo \
        pry \
        zsteg && \
    gem cleanup

# Python virtual environment setup with comprehensive tools
RUN set -eux; \
    python -m venv "${VENV_PATH}" && \
    "${VENV_PATH}/bin/python" -m pip install --upgrade pip setuptools wheel && \
    "${VENV_PATH}/bin/pip" install --no-cache-dir \
        # Core PWN tools
        pwntools \
        ropper \
        ROPgadget \
        # Library search
        LibcSearcher \
        libc-database \
        # Crypto tools
        pycryptodome \
        gmpy2 \
        sympy \
        sage \
        # Binary analysis
        capstone \
        keystone-engine \
        unicorn \
        angr \
        manticore \
        miasm \
        # Fuzzing
        afl-utils \
        python-afl \
        boofuzz \
        # Web tools
        requests \
        beautifulsoup4 \
        lxml \
        selenium \
        # Forensics
        volatility3 \
        python-magic \
        pyelftools \
        # Solver and theorem
        z3-solver \
        claripy \
        # Networking
        scapy \
        impacket \
        paramiko \
        # Utilities
        ipython \
        jupyter \
        colorama \
        termcolor \
        tabulate \
        tqdm \
        click \
        pyyaml \
        toml \
        # Debugging helpers
        gdb-pt-dump \
        exploitable \
        # Additional useful packages
        numpy \
        scipy \
        matplotlib \
        pandas \
        pillow \
        pypng \
        qrcode && \
    "${VENV_PATH}/bin/pip" cache purge

# Create convenient symlinks
RUN set -eux; \
    for tool in python python3 pip pip3 ipython jupyter ropper ropgadget; do \
        ln -sf "${VENV_PATH}/bin/${tool}" "/usr/local/bin/${tool}-venv" 2>/dev/null || true; \
    done

# Install additional security tools
RUN set -eux; \
    cd ${TOOLS_DIR} && \
    # Checksec
    wget -O bin/checksec https://raw.githubusercontent.com/slimm609/checksec.sh/master/checksec && \
    chmod +x bin/checksec && \
    # Pwndbg - Advanced GDB plugin
    git clone https://github.com/pwndbg/pwndbg && \
    cd pwndbg && \
    ./setup.sh && \
    cd .. && \
    # GEF - GDB Enhanced Features
    wget -O share/gef.py https://github.com/hugsy/gef/raw/main/gef.py && \
    # Peda - Python Exploit Development Assistance
    git clone https://github.com/longld/peda.git share/peda && \
    # Pwngdb - GDB plugin for pwn
    git clone https://github.com/scwuaptx/Pwngdb.git share/Pwngdb && \
    # Libc database
    git clone https://github.com/niklasb/libc-database && \
    cd libc-database && \
    ./get ubuntu debian centos || true && \
    cd ..

# Install exploitation frameworks and tools
RUN set -eux; \
    cd ${TOOLS_DIR} && \
    # AFL++ - Advanced fuzzer
    git clone https://github.com/AFLplusplus/AFLplusplus && \
    cd AFLplusplus && \
    make distrib && \
    make install && \
    cd .. && \
    # Honggfuzz - Another powerful fuzzer
    git clone https://github.com/google/honggfuzz && \
    cd honggfuzz && \
    make && \
    make install && \
    cd .. && \
    # House of force/mind/spirit etc templates
    git clone https://github.com/shellphish/how2heap exploits/how2heap && \
    # Kernel exploitation
    git clone https://github.com/xairy/kernel-exploits exploits/kernel && \
    # Windows exploitation
    git clone https://github.com/SecWiki/windows-kernel-exploits exploits/windows

# Install WebSocketReflectorX
RUN set -eux; \
    LATEST_TAG=$(curl -s "https://api.github.com/repos/XDSEC/WebSocketReflectorX/releases/latest" | grep '"tag_name"' | cut -d '"' -f 4) && \
    if [ -n "${LATEST_TAG}" ]; then \
        DOWNLOAD_URL="https://github.com/XDSEC/WebSocketReflectorX/releases/download/${LATEST_TAG}/wsrx-cli-${LATEST_TAG}-linux-musl-x86_64.tar.gz" && \
        curl -L "${DOWNLOAD_URL}" -o /tmp/wsrx-cli.tar.gz && \
        tar -xzf /tmp/wsrx-cli.tar.gz -C /tmp && \
        rm -f /tmp/wsrx-cli.tar.gz && \
        chmod +x /tmp/wsrx && \
        mv /tmp/wsrx ${TOOLS_DIR}/bin/wsrx; \
    fi

# Download common wordlists
RUN set -eux; \
    cd ${WORDLISTS_DIR} && \
    # SecLists
    git clone --depth 1 https://github.com/danielmiessler/SecLists && \
    # Common passwords
    wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt && \
    # Fuzzing payloads
    git clone --depth 1 https://github.com/fuzzdb-project/fuzzdb

# Configure GDB with multiple plugins support
COPY ./config/gdbinit /root/.gdbinit

# Create non-root user with sudo privileges
RUN set -eux; \
    groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -G wheel -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    # Copy GDB config to user
    cp /root/.gdbinit /home/${USER_NAME}/.gdbinit && \
    chown ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.gdbinit

# Setup shell configurations (bash, zsh, fish)
COPY ./config/shell/* /etc/skel/

# Install Oh My Zsh for better shell experience
RUN set -eux; \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker kubectl)/' ~/.zshrc

# Create useful scripts

COPY ./bin ${TOOLS_DIR}/bin/autopwn