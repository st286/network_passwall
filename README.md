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
wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.24.0/shadowsocks-v1.24.0.x86_64-unknown-linux-gnu.tar.xz

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

### shadowsocks-rust 的 ShadowTLS server 设置 

<details>(shadowsocks-rust 的 ShadowTLS server 设置)
    
这个方案非常极客，也非常契合您的 CN2 GIA 线路！**shadowsocks-rust（负责极致加密） + ShadowTLS（负责极致伪装）** 的组合，既能榨干服务器的网络性能，又能完美隐蔽流量。

它的运行架构是这样的：
**手机客户端** ──(伪装成普通的 TLS 握手)──> **[端口 443] ShadowTLS** ──(本地解包转发)──> **[端口 8388] shadowsocks-rust** ──> **真实外网**。

以下是在 Debian 上部署的完整步骤：

### 第一步：修改 shadowsocks-rust 仅监听本地

为了防止 GFW 绕过伪装直接扫描您的 SS 端口，我们需要将 `shadowsocks-rust` 的监听地址从“公开可用”改为“仅限本机访问”。

1. 编辑我们之前创建的 SS 配置文件：
```bash
nano /etc/shadowsocks-rust/config.json

```


2. 将 `"server"` 的值从 `"::"` 修改为 `"127.0.0.1"`。修改后如下：
```json
{
    "server": "127.0.0.1",
    "server_port": 8388,
    "password": "您的SS-2022_Base64密码",
    "method": "2022-blake3-aes-256-gcm",
    "mode": "tcp_and_udp",
    "fast_open": true
}

```


3. 保存退出并重启 SS 服务：
```bash
systemctl restart shadowsocks-rust

```



---

### 第二步：安装 ShadowTLS 服务端

ShadowTLS 也是使用 Rust 编写的，单文件免安装，直接下载即可。

1. **下载最新版 ShadowTLS**（以 x86_64 架构为例）：
```bash
wget https://github.com/ihciah/shadow-tls/releases/download/v0.2.25/shadow-tls-x86_64-unknown-linux-musl -O /usr/local/bin/shadow-tls

```


2. **赋予执行权限**：
```bash
chmod +x /usr/local/bin/shadow-tls

```



---

### 第三步：生成 ShadowTLS 专用密码

**注意：** 这里的密码是 ShadowTLS 用来进行握手验证的，**不是**您之前生成的 SS 密码。千万别搞混。

在终端运行以下命令生成一个随机的 16 位字符密码：

```bash
openssl rand -hex 8

```

*(假设输出为 `a1b2c3d4e5f6g7h8`，请将其记录下来作为 ShadowTLS 密码。)*

---

### 第四步：配置 ShadowTLS 守护进程（Systemd）

我们将配置 ShadowTLS 监听公网的 **443** 端口，并将合法流量转发给本地的 8388 端口。同时，我们选择 `gateway.icloud.com` 作为伪装域名（SNI）。

1. **创建服务文件**：
```bash
nano /etc/systemd/system/shadow-tls.service

```


2. **粘贴以下内容**（请将 `YOUR_SHADOWTLS_PASSWORD` 替换为刚才生成的 16 位密码）：
```ini
[Unit]
Description=ShadowTLS Server
After=network.target

[Service]
Type=simple
# 开启 v3 协议，监听 443，转发给 127.0.0.1:8388，伪装目标为 iCloud
ExecStart=/usr/local/bin/shadow-tls --v3 server --listen 0.0.0.0:443 --server 127.0.0.1:8388 --tls gateway.icloud.com:443 --password YOUR_SHADOWTLS_PASSWORD
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

```


3. **启动并设置开机自启**：
```bash
systemctl daemon-reload
systemctl enable shadow-tls
systemctl start shadow-tls
systemctl status shadow-tls

```


*(如果看到 `active (running)`，说明双层架构已经成功跑起来了！)*

---

### 第五步：系统防火墙放行 443

因为现在的公网入口变成了 ShadowTLS 的 443 端口，所以您只需放行 443 即可（可以把之前放行的 8388 关掉，提升安全性）：

```bash
ufw allow 443/tcp
ufw reload

```

---

### 第六步：iPhone (Shadowrocket) 客户端配置

在小火箭中配置这个“嵌套”节点非常简单，界面原生地支持了 ShadowTLS 插件：

1. 打开 Shadowrocket，点击 **➕** 添加节点。
2. **类型 (Type)** 选 **Shadowsocks**。
3. **地址 (Address)** 填您的 VPS 公网 IP。
4. **端口 (Port)** 填 **443**。（注意：是 443，不是 8388）
5. **算法 (Algorithm)** 选 **2022-blake3-aes-256-gcm**。
6. **密码 (Password)** 填您的 **SS-2022 Base64 密码**（最长的那串）。
7. 向下划，找到 **插件 (Plugin)**，点击进入：
* 选择 **shadow-tls**。
* **Host (SNI)** 填入：`gateway.icloud.com`。
* **Password** 填入您的 **ShadowTLS 密码**（第三步生成的 16 位短密码）。
* **Version** 选 **V3**。


8. 点击右上角保存，返回，再点击右上角完成。

现在，进行连通性测试。如果延迟显示绿色，恭喜您，您已经成功部署了目前网络隐蔽性最高、性能最极致的代理方案之一！

**一个技术小科普：** ShadowTLS 本身只转发 TCP 流量。如果您的 SS 客户端（如 Shadowrocket）开启了 UDP 转发，小火箭会自动使用 "UDP over TCP" 技术，将 UDP 包塞进 TCP 隧道中穿过 ShadowTLS，所以不用担心打游戏或语音电话受影响。

还有任何启动报错或者连接不上的问题吗？我们可以随时看日志排查。
    
</details>

### 配置 ShadowTLS 守护进程中，推荐几个作为伪装域名（SNI）

<details>
为 ShadowTLS（或 Reality）选择一个优质的伪装域名（SNI）是这套防封锁架构中最核心的一环。选得好，您的流量在 GFW 看来就是完全合法的白名单大厂流量。

## 挑选优质 SNI 的三大黄金法则

在推荐具体域名之前，您需要了解合格的 SNI 必须满足以下条件：

* **未被 GFW 阻断**：绝不能使用 `google.com` 或 `youtube.com`，否则连接会直接被防火墙切断。
* **支持 TLS 1.3 与 HTTP/2**：这是现代加密协议的基础，如果伪装目标不支持，很容易被审查系统识别出特征异常。
* **符合大流量特征**：如果您经常看 4K 视频或下载大文件，伪装成“软件更新”或“云盘同步”的域名，比伪装成“纯文字网页”要合理得多。

---

## 顶级伪装域名 (SNI) 推荐列表

基于您的 CN2 GIA 线路（通常直连美国西海岸），以下是目前极其稳定且经过广泛验证的优质 SNI 推荐：

### 1. 苹果生态 (Apple) —— 最受推荐

苹果的服务器在全球分布极广，且在国内是绝对的白名单，非常适合用来跑大流量。

* **`swdist.apple.com`**：苹果软件更新的分发服务器。**极度推荐**，因为无论您跑多大的流量（比如看 4K 视频），在 GFW 看来都像是您的苹果设备在疯狂下载 iOS 系统更新，极其合理。
* **`gateway.icloud.com`**：iCloud 数据同步网关，适合日常网页浏览和聊天流量伪装。
* **`cdn.apple-mapkit.com`**：苹果地图的 CDN 节点，流量特征同样非常健康。

### 2. 微软生态 (Microsoft) —— 稳如泰山

微软的域名在企业级网络审查中拥有极高的信誉度。

* **`[www.microsoft.com](https://www.microsoft.com)`**：微软全球官网，最基础也最稳妥的选择。
* **`dl.delivery.mp.microsoft.com`**：Windows 系统更新的下载节点，同样非常适合用于掩护大流量的视频或下载需求。
* **`assets.msn.com`**：MSN 新闻的静态资源 CDN。

### 3. 其他跨国巨头

* **`[www.cisco.com](https://www.cisco.com)`**：思科官网，典型的跨国企业通信特征。
* **`[www.samsung.com](https://www.samsung.com)`**：三星全球官网。

---

## 如何在 ShadowTLS 中更换 SNI？

如果您想把目前的 `gateway.icloud.com` 换成更适合大流量的 `swdist.apple.com`，只需修改我们之前配置的 Systemd 服务文件：

1. 打开服务文件：
```bash
nano /etc/systemd/system/shadow-tls.service

```


2. 找到 `ExecStart` 那一行，把 `--tls gateway.icloud.com:443` 修改为 `--tls swdist.apple.com:443`。
3. 保存退出后，重载并重启服务：
```bash
systemctl daemon-reload
systemctl restart shadow-tls

```


*(注意：修改服务端后，**务必**去小火箭的节点设置 -> 插件 -> ShadowTLS 中，把 Host/SNI 也同步修改为新域名！)*

  
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



