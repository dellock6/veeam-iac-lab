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
apt-get update -y
apt-get install -y --no-install-recommends python3-venv openssl sqlite3

echo "==> Creating pykmip system user"
useradd -r -m -s /bin/false pykmip || echo "User already exists, skipping"

echo "==> Installing PyKMIP in virtualenv"
python3 -m venv /opt/pykmip
/opt/pykmip/bin/pip install --upgrade pip
/opt/pykmip/bin/pip install pykmip

echo "==> Creating directory structure"
mkdir -p /etc/pykmip/certs
mkdir -p /etc/pykmip/policies
mkdir -p /var/lib/pykmip

echo "==> Generating CA certificate"
openssl genrsa -out /etc/pykmip/certs/ca.key 4096
openssl req -new -x509 -days 3650 \
  -key /etc/pykmip/certs/ca.key \
  -out /etc/pykmip/certs/ca.crt \
  -subj "/CN=PyKMIP-CA/O=Homelab/C=IT"

echo "==> Generating server certificate"
openssl genrsa -out /etc/pykmip/certs/server.key 4096
openssl req -new \
  -key /etc/pykmip/certs/server.key \
  -out /etc/pykmip/certs/server.csr \
  -subj "/CN=${HOST_IP}/O=Homelab/C=IT"

echo "subjectAltName=IP:${HOST_IP},DNS:${HOST_NAME},DNS:${HOST_NAME}.${HOST_DOMAIN}" \
  > /etc/pykmip/certs/san.ext

openssl x509 -req -days 3650 \
  -in /etc/pykmip/certs/server.csr \
  -CA /etc/pykmip/certs/ca.crt \
  -CAkey /etc/pykmip/certs/ca.key \
  -CAcreateserial \
  -out /etc/pykmip/certs/server.crt \
  -extfile /etc/pykmip/certs/san.ext

echo "==> Writing PyKMIP server config"
cat > /etc/pykmip/server.conf << EOF
[server]
hostname=${HOST_IP}
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

echo "==> Enabling and starting PyKMIP service"
systemctl daemon-reload
systemctl enable pykmip
systemctl start pykmip

echo "==> Opening firewall port 5696"
ufw allow 5696/tcp comment 'PyKMIP'

echo ""
echo "==> Done! Service status:"
systemctl status pykmip --no-pager

echo ""
echo "==> CA certificate (upload this to vSphere and VBR):"
cat /etc/pykmip/certs/ca.crt
