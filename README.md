# Bypass the Geat Firewall

---

## [shadowsocks-libev](https://github.com/shadowsocks/shadowsocks-libev)

[shadowsocks-android](https://github.com/shadowsocks/shadowsocks-android)

<details>

Linux

In general, you need the following build dependencies:

cmake (>= 3.2)
a C compiler (gcc or clang)
pkg-config
libmbedtls
libsodium (>= 1.0.4)
libpcre2
libev
libc-ares
asciidoc (for documentation only)
xmlto (for documentation only)
If your system is too old to provide libmbedtls and libsodium (>= 1.0.4), you will need to either install those libraries manually or upgrade your system.

Install build dependencies for your distribution:

```
# Debian / Ubuntu
sudo apt-get install --no-install-recommends build-essential cmake pkg-config \
    libpcre2-dev libev-dev libc-ares-dev libmbedtls-dev libsodium-dev \
    asciidoc xmlto
```
Then build and install:
```
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev

git submodule update --init --recursive
mkdir -p build && cd build
cmake ..
make
sudo make install
```
证是否安装成功：
```
/usr/local/bin/ss-server -h
```
如果能看到帮助信息，说明编译安装成功。
```
vim /etc/shadowsocks-libev/config.json

将以下内容粘贴进去
{
    "server": ["0.0.0.0", "::"],
    "mode": "tcp_and_udp",
    "server_port": 8388,
    "password": "YourStrongPasswordHere!",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "fast_open": false,
    "nameserver": "8.8.8.8"
}
```
配置 Systemd 守护进程
```
vim /etc/systemd/system/shadowsocks-server.service

写入以下配置：

[Unit]
Description=Shadowsocks-libev Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks-libev/config.json
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```
启动服务并设置开机自启
```
# 重新加载 Systemd 配置
systemctl daemon-reload

# 启动 Shadowsocks 服务
systemctl start shadowsocks-server

# 设置为开机自启动
systemctl enable shadowsocks-server

# 查看运行状态
systemctl status shadowsocks-server

```
你看到类似于 Active: active (running) 的绿色提示时，说明你的 Shadowsocks 服务端已经成功在后台运行了。接下来，你只需要像之前一样，确保你的防火墙（如 UFW 或云服务商的安全组）放行了你配置的端口即可。



</details>

---

## [Shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)

<details>
<details>
在 Debian Linux 上安装 `shadowsocks-rust` 是一个非常棒的选择。它是纯 Rust 编写的，极度轻量、完全没有内存垃圾回收（GC）开销，且对最新的 **SS-2022 标准** 支持最为完美。

以下是使用**官方预编译二进制文件**在 Debian VPS 上安装和配置的完整步骤（推荐配合刚才提到的 `2022-blake3-aes-256-gcm` 协议使用）：

### 第一步：下载并安装二进制文件

绝大多数 VPS 都是 x86_64 (AMD64) 架构。我们将直接从 GitHub 下载最新的 Release。

1. **进入 root 权限**（如果还没有）：
```bash
sudo su

```


2. **下载最新版 shadowsocks-rust**（您可以去 GitHub Releases 查看最新版本号，这里以通常的命名格式为例）：
```bash
# 安装解压工具
apt update && apt install -y wget xz-utils

# 下载 x86_64 架构的压缩包（如果您的 VPS 是 ARM 架构，请把链接中的 x86_64 换成 aarch64）
wget https://github.com/shadowsocks/shadowsocks-rust/releases/latest/download/shadowsocks-v1.21.2.x86_64-unknown-linux-gnu.tar.xz

# 解压文件
tar -xvf shadowsocks-*.tar.xz

```


*(注：如果上述链接因版本更新失效，请前往 `[https://github.com/shadowsocks/shadowsocks-rust/releases](https://github.com/shadowsocks/shadowsocks-rust/releases)` 复制最新的 `x86_64-unknown-linux-gnu.tar.xz` 下载链接)*
3. **将服务端核心文件移入系统路径**：
`shadowsocks-rust` 包含多个文件，我们作为服务端只需要用到 `ssserver`。
```bash
mv ssserver /usr/local/bin/
chmod +x /usr/local/bin/ssserver

```


*(此时输入 `ssserver -V` 应该能看到版本号输出，证明安装成功。)*

---

### 第二步：生成 SS-2022 专用密码

既然我们打算用最安全的 `2022-blake3-aes-256-gcm`，系统会强制要求一个 32 字节（256位）的 Base64 强密码。

在终端运行以下命令生成密码：

```bash
openssl rand -base64 32

```

终端会输出一串类似 `Y1...xyz=` 的字符。**请把这串字符复制保存下来，这就是您的密码。**

---

### 第三步：编写配置文件

1. **创建配置文件夹**：
```bash
mkdir -p /etc/shadowsocks-rust

```


2. **创建并编辑 `config.json` 文件**（可以使用 `nano` 或 `vim`）：
```bash
nano /etc/shadowsocks-rust/config.json

```


3. **粘贴以下配置**（请替换端口和密码）：
```json
{
    "server": "::",
    "server_port": 8388,
    "password": "填写您刚才生成的Base64密码",
    "method": "2022-blake3-aes-256-gcm",
    "mode": "tcp_and_udp",
    "fast_open": true
}

```


*说明：*
* `"server": "::"`：表示同时监听 IPv4 和 IPv6 流量。
* `"server_port": 8388`：监听端口，建议改成其他的随机高位端口（如 `49152` 到 `65535` 之间）。
* `"mode": "tcp_and_udp"`：显式开启 TCP 和 UDP 转发（完美支持游戏和语音）。


保存并退出（在 nano 中按 `Ctrl+O` 回车保存，`Ctrl+X` 退出）。

---

### 第四步：配置 Systemd 守护进程（开机自启）

为了让 shadowsocks-rust 稳定地在后台运行，并且开机自动启动，我们需要把它托管给 systemd。

1. **创建服务文件**：
```bash
nano /etc/systemd/system/shadowsocks-rust.service

```


2. **粘贴以下内容**：
```ini
[Unit]
Description=Shadowsocks-Rust Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks-rust/config.json
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

```


保存并退出。
3. **重载系统服务并启动**：
```bash
# 重载 systemd
systemctl daemon-reload

# 设置开机自启
systemctl enable shadowsocks-rust

# 立即启动
systemctl start shadowsocks-rust

# 查看运行状态
systemctl status shadowsocks-rust

```


如果看到绿色的 `active (running)`，恭喜，服务端已经完美运行！

---

### 第五步：防火墙放行（非常重要）

和之前在 sing-box 中一样，如果您的 Debian 开启了防火墙，必须放行对应的端口（TCP 和 UDP）：

如果您使用的是 UFW：

```bash
ufw allow 8388/tcp
ufw allow 8388/udp

```

如果您使用的是云服务商（AWS、Google Cloud、阿里云等），**请务必去网页控制台的安全组规则中，放行 8388 的 TCP 和 UDP**。

现在，您就可以打开 Shadowrocket 手机端，选择 `2022-blake3-aes-256-gcm` 算法，填入那串 Base64 密码进行连接了！

    
</details>

</details>

---

## [Sing-box](https://sing-box.sagernet.org) 
 <details> 

  [sing-box _ github.com ](https://github.com/SagerNet/sing-box)

  [sing-box 1.8.0+版本迁移指南，Rule Set配置使用](https://idev.dev/proxy/sing-box-rule-set.html)

  [sing-box __ manual ](https://sing-box.sagernet.org)

  [NekoBoxForAndroid](https://github.com/MatsuriDayo/NekoBoxForAndroid)

  [sing-box __ examples __ configuration files](https://github.com/chika0801/sing-box-examples)

  [ Shadowsock __ AEAD 2022 setup ](https://pincong.rocks/article/item_id-1138365)

  [网络代理平台的“瑞士军刀”](https://bulianglin.com/archives/sing-box.html)

  [使用 TUN 的模式](https://zu1k.com/posts/coding/tun-mode/)

</details>

###  installation
<details>

client: build from source.

```
git clone https://github.com/SagerNet/sing-box.git
cd sing-box
make
make install
```


server setup (linux):

`curl -fsSL https://sing-box.app/install.sh | sh`

`curl -fsSL https://sing-box.app/install.sh | sh -s -- --beta`


vim /etc/sing-box/config.json

    ##generate password. method is 2022-blake3-chacha20-poly1305
    
    sing-box generate rand --base64  32
    

running:

`systemctl enable sing-box --now | systemctl restart sing-box | systemctl status sing-box`



</details>

---

## [Juicity](https://github.com/juicity/juicity)

[juicity-server](https://github.com/juicity/juicity/tree/main/cmd/server)

[juicity-client](https://github.com/juicity/juicity/tree/main/cmd/client)

<details> Juicity Server

Build from sratch

```
git clone https://github.com/juicity/juicity
cd juicity
make CGO_ENABLED=0 juicity-server
```
Configuration

[UUID-generator](https://www.v2fly.org/en_US/awesome/tools.html)

自签名证书:  ( /etc/juicity/ )

    openssl req -x509 -newkey rsa:4096 -keyout private_key.pem -out certificate.pem -days 365 -nodes
        
生成一个私钥 (private_key.pem) 和一个证书 (certificate.pem)，有效期为 365 天


config.json ( /etc/juicity/config.json )

```
{
  "listen": ":443",
  "users": {
    "00000000-0000-0000-0000-000000000000": "my_password"
  },
  "certificate": "/etc/juicity/certificate.pem",
  "private_key": "/etc/juicity/private_key.pem",
  "congestion_control": "bbr",
  "disable_outbound_udp443": false,
  "log_level": "info"
}
```

systemd service ( /lib/systemd/system/juicity.service )
```
[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target network-online.target

[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=/root/juicity/juicity-server run -c /etc/juicity/config.json
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
```
systemctl
```
systemctl enable juicity.service --now
```
</details>

---

## base

[左耳朵](https://github.com/haoel/haoel.github.io)

[github - shadowsocks](https://github.com/shadowsocks)

[the-book-of-secret-knowledge](https://github.com/trimstray/the-book-of-secret-knowledge)



