# 🐳 Pwn 环境一键启动容器

一个为 CTF Pwn 爱好者打造的开箱即用 Docker 环境，集成常用工具链与 [WebSocketReflectorX](https://github.com/XDSEC/WebSocketReflectorX) 的 `wsrx-cli` 客户端，助你轻松连接远程靶机，专注漏洞挖掘开发。

## 🛠️ 自定义构建

克隆本仓库并构建专属镜像，便于长期使用和扩展。

```bash
# 构建镜像
docker build -t ctf-pwn:latest .

# 运行容器
docker run -it --rm \
  -v $(pwd)/challenges:/root/CTF/challenges \
  -p 1337:1337 \
  ctf-pwn:latest

# 以pwner用户身份运行
docker run -it --rm --user pwner \
  -v $(pwd)/challenges:/home/pwner/CTF/challenges \
  ctf-pwn:latest
```

## Features

- 内含 wsrx-cli 方便直接链接 xdu 的 ctf 终端😋
- 写了一个简单的 template 方便直接开发
