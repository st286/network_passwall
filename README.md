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

**Note: VPS's memory > 1 G**

### Install from [crates.io](https://crates.io/crates/shadowsocks-rust):

Install from crates.io

    cargo install shadowsocks-rust

then you can find sslocal and ssserver in $CARGO_HOME/bin.

Generate a safe and secured password for a specific encryption method ( 2022-blake3-chacha20-poly1305 in the example) with:

    ssservice genkey -m "2022-blake3-aes-256-gcm"

### 使用 systemd 守护进程

    vim etc/systemd/system/shadowsocks-rust.service 

写入内容如下：
```
[Unit]
Description=shadowsocks rust server
After=network.target nss-lookup.target network-online.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=/root/.cargo/bin/ssserver -c /etc/shadowsocks-rust/config.json 
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target

```

vim  /etc/shadowsocks-rust/config.json 

测试配置：运行 ssserver -c /etc/shadowsocks-rust/config.json 测试是否正常启动。

```
{
  "server": "::",
  "server_port": 115,
  "password": "YOURPASSWORD",
  "method": "2022-blake3-aes-256-gcm",
  "timeout": 7200,
  "mode": "tcp_and_udp",
  "nofile": 10240,
  "keep_alive": 15,
  "runtime": {
    "mode": "multi_thread",
    "worker_count": 4 
   }
 }
```

设置多端口的server: 使用 servers 数组

```
{
  "servers": [
    {
      "address": "0.0.0.0",
       ......
    },
    {
      "address": "::",
      "mode": "tcp_only"
      ......
    },
    {
      "disabled": true,
      "address": "0.0.0.0",
    }
  ],
}
```

AEAD 2022 Ciphers

        2022-blake3-aes-128-gcm, 2022-blake3-aes-256-gcm
        2022-blake3-chacha20-poly1305, 2022-blake3-chacha8-poly1305

        ssservice genkey -m "METHOD_NAME"  // generate a secured and safe key

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



