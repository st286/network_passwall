# network_passwall

## [the-book-of-secret-knowledge](https://github.com/trimstray/the-book-of-secret-knowledge)


## sing-box 
 <details> 

  [sing-box _ github.com ](https://github.com/SagerNet/sing-box)

  [sing-box __ manual ](https://sing-box.sagernet.org)

  [sing-box __ examples __ configuration files](https://github.com/chika0801/sing-box-examples)

  [ Shadowsock __ AEAD 2022 setup ](https://pincong.rocks/article/item_id-1138365)

  [网络代理平台的“瑞士军刀”](https://bulianglin.com/archives/sing-box.html)

</details>

###  installation
<details>

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


client:

......

</details>
