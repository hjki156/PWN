# 🐳 Pwn 环境一键启动容器

一个为 CTF Pwn 爱好者打造的开箱即用 Docker 环境，集成常用工具链与 [WebSocketReflectorX](https://github.com/XDSEC/WebSocketReflectorX) 的 `wsrx-cli` 客户端，助你轻松连接远程靶机，专注漏洞挖掘开发。

## 🛠️ 自定义构建

克隆本仓库并构建专属镜像，便于长期使用和扩展。

### 1. 克隆项目

```bash
git clone https://github.com/hjki156/PWN.git
cd PWN
```

### 2. 构建镜像

```bash
docker build -t pwn-env .
```

### 3. 启动容器

```bash
docker run -it pwn-env
```

## Features

- 内含 wsrx-cli 方便直接链接 xdu 的 ctf 终端😋
- 写了一个简单的 template 方便直接开发
