# network_passwall

## base

[shadowsocks](https://shadowsocks.org)

[github - shadowsocks](https://github.com/shadowsocks)

[the-book-of-secret-knowledge](https://github.com/trimstray/the-book-of-secret-knowledge)

## shadowsocks
<details>

[SS  Crates](https://crates.io/crates/shadowsocks-rust)

[shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)

### Build from source

Use cargo to build. NOTE: RAM >= 2GiB

    cargo build --release

Then sslocal and ssserver will appear in ./target/(debug|release)/, it works similarly as the two binaries in the official ShadowSocks' implementation.

    make install TARGET=release

Then sslocal, ssserver, ssmanager and ssurl will be installed to /usr/local/bin (variable PREFIX).

For Windows users, if you have encountered any problem in building, check and discuss in #102.

target-cpu optimization

If you are building for your current CPU platform (for example, build and run on your personal computer), it is recommended to set target-cpu=native feature to let rustc generate and optimize code for the CPU running the compiler.

    export RUSTFLAGS="-C target-cpu=native"

### 使用 systemd 守护进程

    vim /etc/systemd/system/shadowsocks.service

写入内容如下：
```
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks/config.json

Restart=on-abort

[Install]
WantedBy=multi-user.target
```

### Config.json

```
{
    "server": "x.x.x.x",
    "server_port": x,
    "password": "xxxx",
    "method": "2022-blake3-chacha20-poly1305",

    "local_port": 1080,
    "local_address": "127.0.0.1"
}

```

</details>


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
