### Run as Root on zsh shell in Debian 12


echo "Install shadowsocks-rust, Run as root on zsh shell in Debian 12\n"
echo "Usage: zsh ss-install.sh PORT.  [PORT is TCP port]\n"

echo "Come on?[Y/N]:"
read comeon

if [[ $comeon != Y ]] { echo "Good day!"; exit } else { echo "Let's Go!" }

## tcp default PORT
prt=119

expr $1 + 1  &>/dev/null

if [[ $? == 0 ]] && (($1 > 99)) && (($1 < 65535)) \
   { prt=$1; echo "port: $prt" } else { echo "default port: $prt" }

## update
apt update && apt upgrade -y && apt autoremove -y

## install rust-lang
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source  "$HOME/.cargo/env"

## install shadowsocks-rust
cargo install shadowsocks-rust

## server's  passwd and port
psw=$(ssservice genkey -m "2022-blake3-chacha20-poly1305")


## shadowsocks.service and ss.json
> /etc/systemd/system/shadowsocks.service <<EOF
[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/root/.cargo/bin/ssserver -c /root/ss.json

Restart=on-abort

[Install]
WantedBy=multi-user.target

EOF

> /root/ss.json <<EOF
{
    "servers": [
	    {
    		"server": "0.0.0.0",
   		    "server_port": $prt,
    		"password": "$psw",
    		"method": "2022-blake3-chacha20-poly1305"
	    },
	    {
		    "disabled": false,
    		"server": "::",
   		    "server_port": $prt,
    		"password": "$psw",
    		"method": "2022-blake3-chacha20-poly1305"
	    }
    ]
}
EOF

echo "\n\nWrite shadowsocks.service and ss.json\n\n"

systemctl enable shadowsocks.service --now
systemctl status shadowsocks

echo "\n\nIP(v4 and v6):$(hostname -I) \nPassword and Port: \n\t$psw\n\t$prt\n\nDONE!"
