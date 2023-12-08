# network_passwall


## sing-box 
 <details> 

  [sing-box _ github.com ](https://github.com/SagerNet/sing-box)

  [sing-box __ manual ](https://sing-box.sagernet.org)

  [sing-box __ examples __ configuration files](https://github.com/chika0801/sing-box-examples)

  [ Shadowsock __ AEAD 2022 setup ](https://pincong.rocks/article/item_id-1138365)

</details>

###  installation
<details>

debian(shadowsocks):

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

</details>
