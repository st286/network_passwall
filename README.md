# network_passwall

---

## [Shadowsocks](https://shadowsocks.org)

Install shadowsocks-rust, Run as root on zsh shell in Debian 12 :

        zsh ss-install.sh PORT

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
    "server": "0.0.0.0",
    "server_port": 11,
    "password": "xxxx",
    "method": "2022-blake3-chacha20-poly1305"
}

```

</details>

---

## base

[左耳朵](https://github.com/haoel/haoel.github.io)

[github - shadowsocks](https://github.com/shadowsocks)

[the-book-of-secret-knowledge](https://github.com/trimstray/the-book-of-secret-knowledge)


## sing-box 
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


server__debian(shadowsocks):

`bash <(curl -fsSL https://sing-box.app/deb-install.sh)`

vim /etc/sing-box/config.json

    sing-box generate rand --base64  32

```
{
  "log": {
    "level": "error"
  },
  "dns": {
    "servers": [
      {
        "address": "tls://8.8.8.8"
      }
    ]
  },
  "inbounds": [
    {
      "type": "shadowsocks",
      "listen": "::",
      "listen_port": XXXX,
      "sniff": true,
      "network": "tcp",
      "method": "2022-blake3-chacha20-poly1305",
      "password": "XXXX-256-bit-XXXX",
      "multiplex": {
        "enabled": true
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    }
  ],
  "route": {
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      }
    ]
  }
}
```

running:

`systemctl enable sing-box --now | systemctl restart sing-box | systemctl status sing-box`


sing-box.service in /lib/systemd/system

client:

......

</details>


