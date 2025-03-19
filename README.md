# Bypass the Firewall

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


server setup (debian):

`bash <(curl -fsSL https://sing-box.app/deb-install.sh)`

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
        
        * 生成一个私钥 (private_key.pem) 和一个证书 (certificate.pem)，有效期为 365 天


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

## [Shadowsocks](https://shadowsocks.org)

**Note: VPS's memory > 1 G**

Install shadowsocks-rust Server, Run as root on zsh shell in Debian 12 :

        zsh ss-install.sh PORT

Rust update and ss update:

        rustup update && cargo install shadowsocks-rust

<details>

[SS  Crates](https://crates.io/crates/shadowsocks-rust)

[shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)

### Install from [crates.io](https://crates.io/crates/shadowsocks-rust):

Install from crates.io

    cargo install shadowsocks-rust

then you can find sslocal and ssserver in $CARGO_HOME/bin.

Generate a safe and secured password for a specific encryption method ( 2022-blake3-chacha20-poly1305 in the example) with:

    ssservice genkey -m "2022-blake3-chacha20-poly1305"

### 使用 systemd 守护进程

    vim /etc/systemd/system/shadowsocks.service

写入内容如下：
```
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/root/.cargo/bin/ssserver -c /root/ss.json

Restart=on-abort

[Install]
WantedBy=multi-user.target
```

 ss.json

```
{
    "server": "::",
    "server_port": 1,
    "password": "x",
    "method": "2022-blake3-aes-128-gcm"
}

```

AEAD 2022 Ciphers

        2022-blake3-aes-128-gcm, 2022-blake3-aes-256-gcm
        2022-blake3-chacha20-poly1305, 2022-blake3-chacha8-poly1305

        ssservice genkey -m "METHOD_NAME"  // generate a secured and safe key

</details>

---

## base

[左耳朵](https://github.com/haoel/haoel.github.io)

[github - shadowsocks](https://github.com/shadowsocks)

[the-book-of-secret-knowledge](https://github.com/trimstray/the-book-of-secret-knowledge)



