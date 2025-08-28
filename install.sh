# 拉取 docker

docker pull frozenkp/pwn

# 启动容器并执行初始化命令
docker run -it frozenkp/pwn /bin/bash -c "
    apt-get update &&
    apt install -y language-pack-zh-hans wget &&
    mkdir CTF &&
    cd CTF &&
    wget https://github.com/XDSEC/WebSocketReflectorX/releases/download/0.5.9/wsrx-cli-0.5.9-linux-musl-x86_64.tar.gz &&
    tar -xzvf wsrx-cli-0.5.9-linux-musl-x86_64.tar.gz &&
    rm wsrx-cli-0.5.9-linux-musl-x86_64.tar.gz &&
    echo 'Start your Pwn travel~' && 
    /bin/bash
"
