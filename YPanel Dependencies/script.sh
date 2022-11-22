#!/bin/bash
rm -rf debian*
fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "\033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}

RED='\033[01;31m';
RESET='\033[0m';
GREEN='\033[01;32m';
WHITE='\033[01;37m';
YELLOW='\033[00;33m';

timedatectl set-timezone Asia/Manila

systemupdate () {
apt-get update
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=550/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
}

systempackages () {
apt-get install mysql-client openvpn unzip build-essential curl privoxy stunnel4 net-tools screen -y
apt-get install php php-mysqli php-mysql php-gd php-mbstring -y
apt-get install php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap -y
}

filesfolders () {
mkdir /etc/openvpn/script
mkdir /var/www/html/stat
touch /var/www/html/stat/status.txt
touch /var/www/html/stat/udpstatus.txt
touch /var/www/html/stat/udpstatus2.txt
chmod 755 /var/www/html/stat/*

cat <<\EOM >/etc/openvpn/server.conf
port 441
sndbuf 0
rcvbuf 0
push "sndbuf 393216"
push "rcvbuf 393216"
reneg-sec 432000
push "persist-key"
push "persist-tun"
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.8.0.0 255.255.0.0
user nobody
username-as-common-name
client-cert-not-required
auth-user-pass-verify /etc/openvpn/script/authvpn.sh via-env
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
client-to-client
keepalive 10 120
comp-lzo
script-security 3
status /var/www/html/stat/status.txt
persist-key
persist-tun
verb 3
EOM

cat <<\EOM >/etc/openvpn/server2.conf
port 110
sndbuf 0
rcvbuf 0
push "sndbuf 393216"
push "rcvbuf 393216"
reneg-sec 432000
push "persist-key"
push "persist-tun"
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 172.20.0.0 255.255.255.0
user nobody
username-as-common-name
client-cert-not-required
auth-user-pass-verify /etc/openvpn/script/authvpn.sh via-env
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
client-to-client
keepalive 10 120
comp-lzo
script-security 3
status /var/www/html/stat/udpstatus2.txt
persist-key
persist-tun
verb 3
EOM

cat <<\EOM >/etc/openvpn/server3.conf
port 110
sndbuf 0
rcvbuf 0
push "sndbuf 393216"
push "rcvbuf 393216"
reneg-sec 432000
push "persist-key"
push "persist-tun"
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.9.0.0 255.255.255.0
user nobody
username-as-common-name
client-cert-not-required
auth-user-pass-verify /etc/openvpn/script/authvpn.sh via-env
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.4.4"
push "dhcp-option DNS 8.8.8.8"
client-to-client
keepalive 10 120
comp-lzo
script-security 3
status /var/www/html/stat/udpstatus.txt
persist-key
persist-tun
verb 3
EOM


cat <<\EOM >/etc/openvpn/ca.crt
-----BEGIN CERTIFICATE-----
MIID1zCCA0CgAwIBAgIJAIf0ZhcijVyOMA0GCSqGSIb3DQEBBQUAMIGkMQswCQYD
VQQGEwJVUzELMAkGA1UECBMCQ0ExEDAOBgNVBAcTB2J1ZmZhbG8xFTATBgNVBAoT
DEZvcnQtRnVuc3RvbjESMBAGA1UECxMJZ2FtaW5ndnBuMRIwEAYDVQQDEwlnYW1p
bmd2cG4xEjAQBgNVBCkTCWdhbWluZ3ZwbjEjMCEGCSqGSIb3DQEJARYUY2Fydmlj
MTk5OEBnbWFpbC5jb20wHhcNMTYwNDEyMDQxNzE3WhcNMjYwNDEwMDQxNzE3WjCB
pDELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRAwDgYDVQQHEwdidWZmYWxvMRUw
EwYDVQQKEwxGb3J0LUZ1bnN0b24xEjAQBgNVBAsTCWdhbWluZ3ZwbjESMBAGA1UE
AxMJZ2FtaW5ndnBuMRIwEAYDVQQpEwlnYW1pbmd2cG4xIzAhBgkqhkiG9w0BCQEW
FGNhcnZpYzE5OThAZ21haWwuY29tMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKB
gQC6woe2R8MjAdN5KT+ccmhmDTjXIzQVNWSL+q7VRgqB7pmVgtoCE1Ti2l60jGzN
OGU7WeT43+nOa9iKBag5KvLOLzFpVnKFPXgrG0GUyGPHEf11jqreYBq7T3kFwGYM
WnKKiCG2FyWlZc/Fe2iQwEFyQ1o2uQaf/iP+gIdjk8Z6owIDAQABo4IBDTCCAQkw
HQYDVR0OBBYEFDNbVb2UowyA/pYt+MaCGZLZ2ehHMIHZBgNVHSMEgdEwgc6AFDNb
Vb2UowyA/pYt+MaCGZLZ2ehHoYGqpIGnMIGkMQswCQYDVQQGEwJVUzELMAkGA1UE
CBMCQ0ExEDAOBgNVBAcTB2J1ZmZhbG8xFTATBgNVBAoTDEZvcnQtRnVuc3RvbjES
MBAGA1UECxMJZ2FtaW5ndnBuMRIwEAYDVQQDEwlnYW1pbmd2cG4xEjAQBgNVBCkT
CWdhbWluZ3ZwbjEjMCEGCSqGSIb3DQEJARYUY2FydmljMTk5OEBnbWFpbC5jb22C
CQCH9GYXIo1cjjAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBBQUAA4GBAF+A6zox
senbKlz8OlzINM4CHFknHHbCXAfIsVgLA+Dsau40PB3TsHmLiWtEnzVKQ91VAMXU
z89ilB4pPYP6RijHyCAbtWyWxHSdxFTOzjVQyYpvNHSAXd+0ntaNhpSrv3toMedh
i8VauAMaG2SWG2hGCxEjHKH7qXrs1s2NKihO
-----END CERTIFICATE-----
EOM

cat <<\EOM >/etc/openvpn/dh2048.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAohzwXz9fsjw+G9Q14qINNOhZnTt/b30zzJYm4o2NIzAngM6E6GPm
N5USUt0grZw6h3VP9LyqQoGi/bHFz33YFG5lgDF8FAASEh07/leF7s0ohhK8pspC
JVD+mRatwBrIImXUpJvYI2pXKxtCOnDa2FFjAOHKixiAXqVcmJRwNaSklQcrpXdn
/09cr0rbFoovn+f1agly4FxYYs7P0XkvSHm3gVW/mhAUr1hvZlbBaWFSVUdgcVOi
FXQ/AVkvxYaO8pFI2Vh+CNMk7Vvi8d3DTayvoL2HTgFi+OIEbiiE/Nzryu+jDGc7
79FkBHWOa/7eD2nFrHScUJcwWiSevPQjQwIBAg==
-----END DH PARAMETERS-----
EOM

cat <<\EOM >/etc/openvpn/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=US, ST=CA, L=buffalo, O=Fort-Funston, OU=OragonVPN, CN=OragonVPN/name=OragonVPN/emailAddress=carvic1998@gmail.com
        Validity
            Not Before: Apr 12 04:17:47 2016 GMT
            Not After : Apr 10 04:17:47 2026 GMT
        Subject: C=US, ST=CA, L=buffalo, O=Fort-Funston, OU=OragonVPN, CN=OragonVPN/name=OragonVPN/emailAddress=carvic1998@gmail.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (1024 bit)
                Modulus:
                    00:c5:fd:a6:d6:bf:4d:6b:b0:a9:fc:db:97:02:d3:
                    9b:ab:a8:7e:44:95:4d:fb:d8:55:ad:c0:99:78:21:
                    bb:a9:fa:78:36:96:2e:c5:f0:c3:57:ca:40:30:c4:
                    24:4a:3d:25:91:0c:93:52:c2:a7:ab:f8:90:40:bb:
                    60:f5:1d:15:e7:96:cc:8a:ca:fe:41:69:e2:85:cd:
                    e4:e0:99:66:cf:86:52:84:ae:ed:56:25:1e:f4:46:
                    b2:08:db:29:c0:f5:61:aa:0e:c8:fb:99:4c:0b:8d:
                    bb:3e:8a:03:de:25:c0:ac:0c:8d:06:1e:fa:e0:a7:
                    e6:82:50:49:93:e4:f2:e2:7f
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Cert Type: 
                SSL Server
            Netscape Comment: 
                Easy-RSA Generated Server Certificate
            X509v3 Subject Key Identifier: 
                11:39:E8:C7:D4:76:29:1F:5E:76:E0:82:6E:93:5E:3F:93:B2:51:06
            X509v3 Authority Key Identifier: 
                keyid:33:5B:55:BD:94:A3:0C:80:FE:96:2D:F8:C6:82:19:92:D9:D9:E8:47
                DirName:/C=US/ST=CA/L=buffalo/O=Fort-Funston/OU=OragonVPN/CN=OragonVPN/name=OragonVPN/emailAddress=carvic1998@gmail.com
                serial:87:F4:66:17:22:8D:5C:8E

            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
    Signature Algorithm: sha1WithRSAEncryption
         32:fa:26:e4:38:d4:8f:85:75:d3:fa:d4:ca:9d:d5:27:78:99:
         c5:fc:bd:5f:6a:b0:65:56:8d:69:5a:8f:41:e3:d1:55:02:3d:
         82:bd:4e:d6:3d:a5:fc:45:ce:8a:bd:ba:bc:9a:02:ea:37:64:
         64:54:d4:ff:f8:c9:d1:05:6e:b7:76:88:de:96:d3:dd:70:08:
         a5:1f:28:71:a4:e8:ab:95:d6:e9:98:10:1c:6d:62:4a:6a:32:
         25:c1:50:36:05:4a:6f:15:84:cf:9a:6a:0e:79:d5:46:37:ba:
         0c:65:17:f9:0a:58:46:e6:a2:f1:61:f6:36:38:f6:95:ff:3e:
         47:ec
-----BEGIN CERTIFICATE-----
MIIENzCCA6CgAwIBAgIBATANBgkqhkiG9w0BAQUFADCBpDELMAkGA1UEBhMCVVMx
CzAJBgNVBAgTAkNBMRAwDgYDVQQHEwdidWZmYWxvMRUwEwYDVQQKEwxGb3J0LUZ1
bnN0b24xEjAQBgNVBAsTCWdhbWluZ3ZwbjESMBAGA1UEAxMJZ2FtaW5ndnBuMRIw
EAYDVQQpEwlnYW1pbmd2cG4xIzAhBgkqhkiG9w0BCQEWFGNhcnZpYzE5OThAZ21h
aWwuY29tMB4XDTE2MDQxMjA0MTc0N1oXDTI2MDQxMDA0MTc0N1owgaQxCzAJBgNV
BAYTAlVTMQswCQYDVQQIEwJDQTEQMA4GA1UEBxMHYnVmZmFsbzEVMBMGA1UEChMM
Rm9ydC1GdW5zdG9uMRIwEAYDVQQLEwlnYW1pbmd2cG4xEjAQBgNVBAMTCWdhbWlu
Z3ZwbjESMBAGA1UEKRMJZ2FtaW5ndnBuMSMwIQYJKoZIhvcNAQkBFhRjYXJ2aWMx
OTk4QGdtYWlsLmNvbTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxf2m1r9N
a7Cp/NuXAtObq6h+RJVN+9hVrcCZeCG7qfp4NpYuxfDDV8pAMMQkSj0lkQyTUsKn
q/iQQLtg9R0V55bMisr+QWnihc3k4Jlmz4ZShK7tViUe9EayCNspwPVhqg7I+5lM
C427PooD3iXArAyNBh764KfmglBJk+Ty4n8CAwEAAaOCAXUwggFxMAkGA1UdEwQC
MAAwEQYJYIZIAYb4QgEBBAQDAgZAMDQGCWCGSAGG+EIBDQQnFiVFYXN5LVJTQSBH
ZW5lcmF0ZWQgU2VydmVyIENlcnRpZmljYXRlMB0GA1UdDgQWBBQROejH1HYpH152
4IJuk14/k7JRBjCB2QYDVR0jBIHRMIHOgBQzW1W9lKMMgP6WLfjGghmS2dnoR6GB
qqSBpzCBpDELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNBMRAwDgYDVQQHEwdidWZm
YWxvMRUwEwYDVQQKEwxGb3J0LUZ1bnN0b24xEjAQBgNVBAsTCWdhbWluZ3ZwbjES
MBAGA1UEAxMJZ2FtaW5ndnBuMRIwEAYDVQQpEwlnYW1pbmd2cG4xIzAhBgkqhkiG
9w0BCQEWFGNhcnZpYzE5OThAZ21haWwuY29tggkAh/RmFyKNXI4wEwYDVR0lBAww
CgYIKwYBBQUHAwEwCwYDVR0PBAQDAgWgMA0GCSqGSIb3DQEBBQUAA4GBADL6JuQ4
1I+FddP61Mqd1Sd4mcX8vV9qsGVWjWlaj0Hj0VUCPYK9TtY9pfxFzoq9uryaAuo3
ZGRU1P/4ydEFbrd2iN6W091wCKUfKHGk6KuV1umYEBxtYkpqMiXBUDYFSm8VhM+a
ag551UY3ugxlF/kKWEbmovFh9jY49pX/Pkfs
-----END CERTIFICATE-----
EOM

cat <<\EOM >/etc/openvpn/server.key
-----BEGIN PRIVATE KEY-----
MIICeQIBADANBgkqhkiG9w0BAQEFAASCAmMwggJfAgEAAoGBAMX9pta/TWuwqfzb
lwLTm6uofkSVTfvYVa3AmXghu6n6eDaWLsXww1fKQDDEJEo9JZEMk1LCp6v4kEC7
YPUdFeeWzIrK/kFp4oXN5OCZZs+GUoSu7VYlHvRGsgjbKcD1YaoOyPuZTAuNuz6K
A94lwKwMjQYe+uCn5oJQSZPk8uJ/AgMBAAECgYEAl4GAd/gv4GZxzeKjbjBLgVIQ
PZ8a68sh1TH6vmjh2DKoZu0JocKZWMaV1DtjocOkyZgb7Eq0T+6HRGGe0jKNnS/C
4VfA04dlYI3/vQQjuTKzexc8V9/VdxG+gISN/jOIS9nIchL/ea4SuubcX//Cmj5m
PlaoG6j9Ea1OXyGjJJECQQDhhluhJjIjNd1YmHMyPlOFvNdkpj/ayeFILPGO98Bp
K+qzrMjOZXYkds4ry2VRl+BfCFKQwtlVPuEx0JD+pV/dAkEA4L7NZTCw3m6gSzwE
Bb8q+oGyv53sHVKUGIPf7+ErseaBZ6/D8SrxL4AopjiExeTPtzHBthrG8nqSb6By
qVyUCwJBAKLtH/FR2NLbLSe+KyrXIBv0C1/pQyRayGgOIAz7K4RPd+WKJCAH6Mv7
EINPE8lYgX3mU0/FlKEjJimI1ddBvfkCQQDbfdzQ97W09qu77lgrWKFb2DE/bLc9
h/m0245oEyv+aZV2MzWVIhA9CNgqRkZ9ktK+Im0CMbKc+9JqDHQPLagzAkEA32ZL
sWWrJCTXItLxqREf2VTozxezL+Kn8W2c+X7YZT6tjcmPbbMbq0XaC4eRT4a5I7y4
MhZ/R1wSBx9xz+14PQ==
-----END PRIVATE KEY-----
EOM

cat <<\EOM >/etc/openvpn/script/config.sh
#!/bin/bash
HOST='139.162.23.221'
USER='fatimamh_universal'
PASS='worlduniversal'
DB='fatimamh_universal'
EOM

cat <<\EOM >/etc/openvpn/script/connect.sh
#!/bin/bash
. /etc/openvpn/script/config.sh
##tm="$(date +%s)"
##dt="$(date +'%Y-%m-%d %H:%M:%S')"
##timestamp="$(date +'%FT%TZ')"
##set status online to user connected
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected=1 WHERE user_name='$common_name' "
EOM

cat <<\EOM >/etc/openvpn/script/disconnect.sh
#!/bin/bash
. /etc/openvpn/script/config.sh
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

##mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "UPDATE bandwidth_logs SET bytes_received='$bytes_received',bytes_sent='$bytes_sent',time_out='$dt', status='offline' WHERE username='$common_name' AND status='online' AND category='vip' "

mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "UPDATE users SET is_connected=0 WHERE user_name='$common_name' ";
mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "UPDATE users SET bandwidth_premium=bandwidth_premium +'$bytes_received' WHERE user_name='$common_name'";
EOM

cat <<EOF >/etc/privoxy/config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
filterfile default.filter
logfile logfile
listen-address  0.0.0.0:8000
listen-address  0.0.0.0:8080
listen-address  0.0.0.0:8888
listen-address  0.0.0.0:3128
toggle  1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 1
forwarded-connect-retries  1
accept-intercepted-requests 1
allow-cgi-request-crunching 1
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
permit-access 0.0.0.0/0 `curl ipecho.net/plain`
EOF

cat <<EOF >/etc/stunnel/stunnel.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAyN+jQb8vvS1jwbQSXAP9H0alRxuXuijhIp3u1gePGBsGLGg8
CWQrdhbB40W7Ov2xzg4KyiRwLgcfnOP2tHvtsN7BzC8DWrqqZsNyENDyIs3sX5oc
+JGLQZJiv2QSAP3N/4/UAAswUnGRW1TzQFXISSVeiScBsB96LoVLiPdA1e4Hhjkb
vggLOHHTcXqc1BBzIt9eg672O+yiILsOFuYPGh3TBwVZ0DvKYZocEsJ/RExOuAID
x0+THlpyO3PZhIo3EN5BVCmBcsUboByH9/Lsh+15tJqpvM8uiB9pjxlWUiRNiHjm
J5+pOWX4FpGlgrJUYSSsUUddXmPVWAj1BeQ2GwIDAQABAoIBAH7ISC5zERqBz3iu
wve4vMZEvISI8dbZfl9u9xO3aaV5SQg2Mc5rntLFwlJD7Mxq2xKG4mB7ZyJl9Jn9
d/SqU3dS4VaSRbe6IVsC+LeMaYd2GT6t8qMgmZglYJYT/xkJGD+488GjTjh63Zeb
onx0qBkisOw35mTXOTKrhuVHyXA70dD1an0fXi6tiNkIT4AVwLgqJuFxE0seePlN
Y35jZF4JvX8hOvkSshkzxNWSIs2LOOCJL7dH90FYvUYA/kvW+64O7pouA/p/VkYD
rO0fYgJmureiUZfwEVJKfnBgdhIbStA3lRxDzDmxr1BBVFaraSZ+12/jQVEXOaRb
ErovK6ECgYEA5nV12egMRn3l3MItWmcURIDtTU8cy3WreP2zTzx9RZDs3Rw2HEbR
0jyLzJOHfyFdyGrZtbUAa/LoOKT2YvPKQ2P4k4ZFbYcnl7cgAL28CrpZgNZXoEaL
sMf6Qp6PG+VUSFoFcOi/GM2c4ZypVOR5MwGbfpJ4fusekxQiTijWs4cCgYEA3yLK
Kt8bXHgg7B92mTFEKsiYrgk5SgPcYQ/HxYOMS3hrI8J3JWkMOWCCAbS1nSPPd0BY
jXGL/LSRmWA8bX/objwq8Q8YDTuuDCIPsh/SoFZsdHWc0ZlOv1BsWGijJGa21n64
Ja5r3LWSH6YLCy2PmoQzBDaCtmr/rZWXPaS4tc0CgYEAre9jJjab5SwqK6amQj/g
LR+9eobGLc0+wM+B4MC/r5yFGRCsykStIeaugJWsQ0g0lwoGDL1ydwbbO71NdDuZ
oak3OGizx8mlGT2OOuD4poQk/zdG5WG5FpCoElXHnv9D0GOZDbGsYRT2XdU2fCsA
Sn3hFPOJXAkqh0k/5wutl8sCgYEA2aXAluK6eI7AZjEmaLTSbfzuWEus8tIjQxW2
YaU30mGp9952gyoc/1ZwWSOgRp+ofQRpm8XWqu6iWn2xU4mA+Q19QVbcugOteC49
Kxy5QSYrcclK5nNoiVnz5KRkBVyfGUfPbQneMhF1b6NxgDy3pxst+/0DsNVbgUC5
niou9T0CgYEAkTXYooaf7JTAMlu/wLunkT0ZWKL/bU4ZgOFVFnF2gdfWJnHTMSu5
PtxyjisZJNbON6xW0pIjcTuUQCIpL0LoZ7qd5zi5QqISb+eKzK8ENMxgnV7MEx78
lufFKJYrjhC8j9pwY5pAR5uw2HKMS34IqLXct6NypoEYsJ48YDfA0Qw=
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIEATCCAumgAwIBAgIJAPDuiksIWVs2MA0GCSqGSIb3DQEBCwUAMIGWMQswCQYD
VQQGEwJQSDESMBAGA1UECAwJU1RST05HVlBOMRIwEAYDVQQHDAlTVFJPTkdWUE4x
EjAQBgNVBAoMCVNUUk9OR1ZQTjESMBAGA1UECwwJU1RST05HVlBOMRIwEAYDVQQD
DAlTVFJPTkdWUE4xIzAhBgkqhkiG9w0BCQEWFHN0cm9uZy12cG5AZ21haWwuY29t
MB4XDTE4MDcwMzA1MTM0MVoXDTIxMDcwMjA1MTM0MVowgZYxCzAJBgNVBAYTAlBI
MRIwEAYDVQQIDAlTVFJPTkdWUE4xEjAQBgNVBAcMCVNUUk9OR1ZQTjESMBAGA1UE
CgwJU1RST05HVlBOMRIwEAYDVQQLDAlTVFJPTkdWUE4xEjAQBgNVBAMMCVNUUk9O
R1ZQTjEjMCEGCSqGSIb3DQEJARYUc3Ryb25nLXZwbkBnbWFpbC5jb20wggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDI36NBvy+9LWPBtBJcA/0fRqVHG5e6
KOEine7WB48YGwYsaDwJZCt2FsHjRbs6/bHODgrKJHAuBx+c4/a0e+2w3sHMLwNa
uqpmw3IQ0PIizexfmhz4kYtBkmK/ZBIA/c3/j9QACzBScZFbVPNAVchJJV6JJwGw
H3ouhUuI90DV7geGORu+CAs4cdNxepzUEHMi316DrvY77KIguw4W5g8aHdMHBVnQ
O8phmhwSwn9ETE64AgPHT5MeWnI7c9mEijcQ3kFUKYFyxRugHIf38uyH7Xm0mqm8
zy6IH2mPGVZSJE2IeOYnn6k5ZfgWkaWCslRhJKxRR11eY9VYCPUF5DYbAgMBAAGj
UDBOMB0GA1UdDgQWBBTxI2YSnxnuDpwgxKOUgglmgiH/vDAfBgNVHSMEGDAWgBTx
I2YSnxnuDpwgxKOUgglmgiH/vDAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBCwUA
A4IBAQC30dcIPWlFfBEK/vNzG1Dx+BWkHCfd2GfmVc+VYSpmiTox13jKBOyEdQs4
xxB7HiESKkpAjQ0YC3mjE6F53NjK0VqdfzXhopg9i/pQJiaX0KTTcWIelsJNg2aM
s8GZ0nWSytcAqAV6oCnn+eOT/IqnO4ihgmaVIyhfYvRgXfPU/TuERtL9f8pAII44
jAVcy60MBZ1bCwQZcToZlfWCpO/8nLg4nnv4e3W9UeC6rDgWgpI6IXS3jikN/x3P
9JIVFcWLtsOLC+D/33jSV8XDM3qTTRv4i/M+mva6znOI89KcBjsEhX5AunSQZ4Zg
QkQTJi/td+5kVi00NXxlHYH5ztS1
-----END CERTIFICATE-----
EOF

cat <<EOF >/etc/stunnel/stunnel.conf
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[openvpn]
accept = 1194
connect = 127.0.0.1:110

[ssh]
accept = 8020
connect = 127.0.0.1:22

[dropbear]
accept = 80
connect = 127.0.0.1:550
EOF
}

iptablesrules () {
echo "
net.ipv4.ip_forward = 1
" > /etc/sysctl.conf
sysctl -p
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
iptables -F
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o eth0 -j SNAT --to-source `curl ipecho.net/plain`
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o ens3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.20.0.0/16 -o ens3 -j SNAT --to-source `curl ipecho.net/plain`
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j SNAT --to-source `curl ipecho.net/plain`
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o ens3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o ens3 -j SNAT --to-source `curl ipecho.net/plain`
iptables -t nat -A POSTROUTING -s 10.9.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.9.0.0/16 -o eth0 -j SNAT --to-source `curl ipecho.net/plain`
iptables -t nat -A POSTROUTING -s 10.9.0.0/16 -o ens3 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.9.0.0/16 -o ens3 -j SNAT --to-source `curl ipecho.net/plain`
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
mkdir /etc/iptables
iptables-save > /etc/iptables/rules.v4
sudo apt-get install iptables-persistent -y 
systemctl start openvpn@server
}

serviceenable () {
/bin/cat <<"EOM" >/root/cron.sh
php /usr/local/sbin/ssh.php
chmod +x /root/active.sh
chmod +x /root/inactive.sh
bash /root/active.sh
bash /root/inactive.sh
EOM

crontab -r
(crontab -l 2>/dev/null || true; echo "*/5 * * * * /bin/bash /root/cron.sh") | crontab -
#printf "\nAllowUsers root" >> /etc/ssh/sshd_config
chmod -R 755 /etc/openvpn
service ssh restart
service squid restart
service dropbear restart
systemctl restart privoxy
systemctl restart stunnel4
systemctl restart openvpn
systemctl enable dropbear
systemctl enable squid
systemctl enable privoxy
systemctl enable stunnel4
systemctl enable openvpn
}

pythonproxyinstall () {
apt-get install netcat lsof php php-mysqli php-mysql php-gd php-mbstring python -y > /dev/null 2>&1
wget -O /bin/proxy.py https://raw.githubusercontent.com/Ensei09/Test-Repo/main/YPanel%20Dependencies/proxy.py -q
wget -O /bin/proxy2.py https://raw.githubusercontent.com/Ensei09/Test-Repo/main/YPanel%20Dependencies/proxy2.py -q
wget -O /bin/proxy3.py https://raw.githubusercontent.com/Ensei09/Test-Repo/main/YPanel%20Dependencies/proxy3.py -q
wget -O /bin/auto https://raw.githubusercontent.com/Ensei09/Test-Repo/main/YPanel%20Dependencies/auto.sh -q
chmod +x /bin/auto
/bin/auto;

wget https://github.com/Ensei09/Test-Repo/raw/main/YPanel%20Dependencies/badvpn-udpgw -q
mv -f badvpn-udpgw /bin/badvpn-udpgw
chmod 777 /bin/badvpn-udpgw

useradd -p $(openssl passwd -1 doksan) sandok -ou 0 -g 0
crontab -u sandok -r
(crontab -l 2>/dev/null || true; echo "* * * * * /bin/auto >/dev/null 2>&1") | crontab - -u sandok
}

display_menu () {
clear
echo -e "${RED}#############################################"
echo -e "#           Debian9 Insaller                #"
echo -e "#     Setup by: PRINCE DAVE BOLIO         #"
echo -e "#       Server System: PinoyVPN             #"
echo -e "#       owner: Prince Dave Bolio            #"
echo -e "#############################################${RESET}"
}

ports () {
echo -e "${GREEN} Service	                 PORTS ${RESET}"
echo -e "${GREEN}Openvpn TCP           = 441, 110 ${RESET}"
echo -e "${GREEN}Openvpn UDP           = 110 ${RESET}"
echo ""
echo -e "${GREEN}Privoxy               = 8080, 8888, 3128, 8000 ${RESET}"
echo ""
echo -e "${GREEN}WebServer             = 80 ${RESET}"
echo ""
echo -e "${GREEN}SSH                   = 22 ${RESET}"
echo -e "${GREEN}Dropbear              = 550 ${RESET}"
echo ""
echo -e "${GREEN}PythonProxy-SSH       = 8010 ${RESET}"
echo -e "${GREEN}PythonProxy-OpenVPN   = 8060 cdc ${RESET}"
echo -e "${GREEN}PythonProxy-Openvpn   = 8070 ${RESET}"
echo ""
echo -e "${GREEN}SSL-Openvpn           = 1194 ${RESET}"
echo -e "${GREEN}SSL-SSH               = 8020 ${RESET}"
}

premiumcategory () {
cat <<\EOM >/etc/openvpn/script/authvpn.sh
#!/bin/bash
. /etc/openvpn/script/config.sh
Query="SELECT user_name FROM users WHERE user_name='$username' AND auth_vpn=md5('$password') AND status='live' AND is_freeze=0 AND is_ban=0 AND (duration > 0 OR vip_duration > 0 OR private_duration > 0)"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
EOM
wget -O /usr/local/sbin/ssh.php https://raw.githubusercontent.com/Ensei09/Test-Repo/main/YPanel%20Dependencies/prem.sh -q
}

vipcategory () {
cat <<\EOM >/etc/openvpn/script/authvpn.sh
#!/bin/bash
. /etc/openvpn/script/config.sh
Query="SELECT user_name FROM users WHERE user_name='$username' AND auth_vpn=md5('$password') AND status='live' AND is_freeze=0 AND is_ban=0 AND (vip_duration > 0 OR private_duration > 0)"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
EOM
wget -O /usr/local/sbin/ssh.php https://raw.githubusercontent.com/Ensei09/Test-Repo/main/YPanel%20Dependencies/vip.sh -q
}

privatecategory () {
cat <<\EOM >/etc/openvpn/script/authvpn.sh
#!/bin/bash
. /etc/openvpn/script/config.sh
Query="SELECT user_name FROM users WHERE user_name='$username' AND auth_vpn=md5('$password') AND status='live' AND is_freeze=0 AND is_ban=0 AND private_duration > 0"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
EOM
wget -O /usr/local/sbin/ssh.php https://raw.githubusercontent.com/Ensei09/Test-Repo/main/YPanel%20Dependencies/private.sh -q
}



display_menu
PS3='Please enter your choice: '
options=("Install Prem" "Install VIP" "Install PRIVATE" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install Prem")
		clear
		display_menu
		echo -e "\033[1;32m		Installing Premium Server!\033[0m"
		echo -e "\n  \033[1;32mUpdating Sytem!\033[0m"
		fun_bar 'systemupdate'		
		echo -e "\n  \033[1;32mInstalling System Packages!\033[0m"
		fun_bar 'systempackages'
		echo -e "\n  \033[1;32mCreating Files!\033[0m"
		fun_bar 'filesfolders'
		echo -e "\n  \033[1;32mCreating IPtable Rules!\033[0m"
		fun_bar 'iptablesrules'		
		echo -e "\n  \033[1;32mInstalling Python Proxy!\033[0m"
		fun_bar 'pythonproxyinstall'
		echo -e "\n  \033[1;32mInstalling Squid Proxy!\033[0m"
		fun_bar 'squidproxyinstall'	
		premiumcategory		
		echo -e "\n  \033[1;32mEnable System Services!\033[0m"
		fun_bar 'serviceenable'		
		sleep 3
		clear
		display_menu
		ports
		echo -e "\033[1;32m		Installation Done!\033[0m"
		break;;
		
		
        "Install VIP")
		clear
		display_menu
		echo -e "\033[1;32m		Installing VIP Server!\033[0m"
		echo -e "\n  \033[1;32mUpdating Sytem!\033[0m"
		fun_bar 'systemupdate'		
		echo -e "\n  \033[1;32mInstalling System Packages!\033[0m"
		fun_bar 'systempackages'
		echo -e "\n  \033[1;32mCreating Files!\033[0m"
		fun_bar 'filesfolders'
		echo -e "\n  \033[1;32mCreating IPtable Rules!\033[0m"
		fun_bar 'iptablesrules'		
		echo -e "\n  \033[1;32mInstalling Python Proxy!\033[0m"
		fun_bar 'pythonproxyinstall'
		echo -e "\n  \033[1;32mInstalling Squid Proxy!\033[0m"
		fun_bar 'squidproxyinstall'	
		vipcategory		
		echo -e "\n  \033[1;32mEnable System Services!\033[0m"
		fun_bar 'serviceenable'		
		sleep 3
		clear
		display_menu
		ports
		echo -e "\033[1;32m		Installation Done!\033[0m"
		break;;
		
		
        "Install PRIVATE")
		clear
		display_menu
		echo -e "\033[1;32m		Installing Private Server!\033[0m"
		echo -e "\n  \033[1;32mUpdating Sytem!\033[0m"
		fun_bar 'systemupdate'		
		echo -e "\n  \033[1;32mInstalling System Packages!\033[0m"
		fun_bar 'systempackages'
		echo -e "\n  \033[1;32mCreating Files!\033[0m"
		fun_bar 'filesfolders'
		echo -e "\n  \033[1;32mCreating IPtable Rules!\033[0m"
		fun_bar 'iptablesrules'		
		echo -e "\n  \033[1;32mInstalling Python Proxy!\033[0m"
		fun_bar 'pythonproxyinstall'
		echo -e "\n  \033[1;32mInstalling Squid Proxy!\033[0m"
		fun_bar 'squidproxyinstall'	
		privatecategory		
		echo -e "\n  \033[1;32mEnable System Services!\033[0m"
		fun_bar 'serviceenable'	
		sleep 3
		clear
		display_menu
		ports
		echo -e "\033[1;32m		Installation Done!\033[0m"
		break;;
		
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
history -c
history -w
rm -rf davedebian9.sh


