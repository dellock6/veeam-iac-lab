#!/bin/bash
# PyKMIP provisioning script
# Run as: sudo bash provision_pykmip.sh <VM_IP> <VM_HOSTNAME> <VM_DOMAIN>
# Example: sudo bash provision_pykmip.sh 192.168.1.50 pykmip-kms lab.local

set -e
echo "==> Script MD5: $(md5sum $0)"

HOST_IP="${1:?Usage: $0 <VM_IP> <VM_HOSTNAME> <VM_DOMAIN>}"
HOST_NAME="${2:?Usage: $0 <VM_IP> <VM_HOSTNAME> <VM_DOMAIN>}"
HOST_DOMAIN="${3:?Usage: $0 <VM_IP> <VM_HOSTNAME> <VM_DOMAIN>}"

echo "==> Installing dependencies"
echo "==> Adding deadsnakes PPA for Python 3.11"
add-apt-repository ppa:deadsnakes/ppa -y
apt-get update -y
apt-get install -y --no-install-recommends python3.11 python3.11-venv openssl sqlite3 authbind
# there is a known PyKMIP 0.10.0 incompatibility with Python 3.12, that's why we force the use of 3.11

echo "==> Creating pykmip system user"
useradd -r -m -s /bin/false pykmip || echo "User already exists, skipping"

echo "==> Installing PyKMIP in virtualenv"
python3.11 -m venv /opt/pykmip
/opt/pykmip/bin/pip install --upgrade pip
/opt/pykmip/bin/pip install git+https://github.com/dellock6/pykmip-veeam.git

echo "==> Creating directory structure"
mkdir -p /etc/pykmip/certs
mkdir -p /etc/pykmip/policies
mkdir -p /var/lib/pykmip
mkdir -p /var/log/pykmip

echo "==> Creating OpenSSL CA database"
touch /etc/pykmip/certs/index.txt
echo '01' > /etc/pykmip/certs/serial

echo "==> Writing OpenSSL CA config"
cat > /etc/pykmip/certs/openssl-ca.cnf << EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = /etc/pykmip/certs
database          = /etc/pykmip/certs/index.txt
serial            = /etc/pykmip/certs/serial
certificate       = /etc/pykmip/certs/ca.crt
private_key       = /etc/pykmip/certs/ca.key
new_certs_dir     = /etc/pykmip/certs
default_md        = sha256
default_days      = 3650
policy            = policy_anything

[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ crl_ext ]
authorityKeyIdentifier  = keyid:always
EOF

echo "==> Generating CA certificate"
openssl genrsa -out /etc/pykmip/certs/ca.key 4096
openssl req -new -x509 -days 3650 \
  -key /etc/pykmip/certs/ca.key \
  -out /etc/pykmip/certs/ca.crt \
  -subj "/CN=PyKMIP-CA/O=Homelab/C=IT" \
  -addext "subjectKeyIdentifier=hash" \
  -addext "basicConstraints=critical,CA:true" \
  -addext "keyUsage=critical,keyCertSign,cRLSign"

echo "==> Generating server certificate"
openssl genrsa -out /etc/pykmip/certs/server.key 4096
openssl req -new \
  -key /etc/pykmip/certs/server.key \
  -out /etc/pykmip/certs/server.csr \
  -subj "/CN=${HOST_IP}/O=Homelab/C=IT"

cat > /etc/pykmip/certs/san.ext << EOF
subjectAltName=IP:${HOST_IP},DNS:${HOST_NAME},DNS:${HOST_NAME}.${HOST_DOMAIN}
crlDistributionPoints=URI:http://${HOST_NAME}.${HOST_DOMAIN}/crl
EOF
openssl x509 -req -days 3650 \
  -in /etc/pykmip/certs/server.csr \
  -CA /etc/pykmip/certs/ca.crt \
  -CAkey /etc/pykmip/certs/ca.key \
  -CAcreateserial \
  -out /etc/pykmip/certs/server.crt \
  -extfile /etc/pykmip/certs/san.ext

echo "==> Generating CRL"
openssl ca -gencrl \
  -keyfile /etc/pykmip/certs/ca.key \
  -cert /etc/pykmip/certs/ca.crt \
  -out /etc/pykmip/certs/crl.pem \
  -crldays 3650 \
  -config /etc/pykmip/certs/openssl-ca.cnf
openssl crl -in /etc/pykmip/certs/crl.pem -outform DER -out /etc/pykmip/certs/crl

echo "==> Writing PyKMIP server config"
cat > /etc/pykmip/server.conf << EOF
[server]
hostname=0.0.0.0
port=5696
certificate_path=/etc/pykmip/certs/server.crt
key_path=/etc/pykmip/certs/server.key
ca_path=/etc/pykmip/certs/ca.crt
auth_suite=TLS1.2
policy_path=/etc/pykmip/policies
database_path=/var/lib/pykmip/pykmip.db
logging_level=INFO
EOF

echo "==> Fixing ownership and permissions"
chown -R pykmip:pykmip /etc/pykmip /var/lib/pykmip
chmod 700 /etc/pykmip/certs
chown -R pykmip:pykmip /etc/pykmip /var/lib/pykmip /var/log/pykmip

echo "==> Configuring authbind for CRL HTTP server"
touch /etc/authbind/byport/80
chown pykmip:pykmip /etc/authbind/byport/80
chmod 500 /etc/authbind/byport/80

echo "==> Writing CRL HTTP server systemd unit"
cat > /etc/systemd/system/pykmip-crl.service << EOF
[Unit]
Description=PyKMIP CRL HTTP Server
After=network.target

[Service]
Type=simple
User=pykmip
Group=pykmip
WorkingDirectory=/etc/pykmip/certs
ExecStart=/usr/bin/authbind --deep /opt/pykmip/bin/python3.11 -m http.server 80
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "==> Writing systemd unit"
cat > /etc/systemd/system/pykmip.service << EOF
[Unit]
Description=PyKMIP Key Management Server
After=network.target

[Service]
Type=simple
User=pykmip
Group=pykmip
ExecStart=/opt/pykmip/bin/pykmip-server -f /etc/pykmip/server.conf
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "==> Enabling and starting services"
systemctl daemon-reload
systemctl enable pykmip
systemctl start pykmip

echo "==> Enabling and starting CRL HTTP server"
systemctl enable pykmip-crl
systemctl start pykmip-crl

echo "==> Opening firewall port 5696"
ufw allow 5696/tcp comment 'PyKMIP'
ufw allow 80/tcp comment 'PyKMIP CRL'

echo ""
echo "==> Done! Service status:"
systemctl status pykmip --no-pager

echo ""
echo "==> CA certificate (upload this to vSphere and VBR):"
cat /etc/pykmip/certs/ca.crt
