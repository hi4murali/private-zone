#!/bin/bash
set -euxo pipefail

# Fetch instance metadata
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
PRIVATE_IP=$(curl -s "http://169.254.169.254/latest/meta-data/local-ipv4" \
  -H "X-aws-ec2-metadata-token: $TOKEN")

# Install web server and SSL module
dnf install -y httpd mod_ssl openssl

# Create a self-signed certificate for testing
mkdir -p /etc/pki/tls/certs
mkdir -p /etc/pki/tls/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/pki/tls/private/apache-selfsigned.key \
  -out /etc/pki/tls/certs/apache-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=localhost"

# Force SSL configuration to listen on 443 (mod_ssl usually does this but let's be explicit if needed)
# The default ssl.conf in Amazon Linux 2023 usually handles this.

# Write landing page
cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${project_name}</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 600px; margin: 80px auto; text-align: center; color: #333; }
    h1 { color: #232f3e; }
    .info { background: #f4f4f4; border-radius: 8px; padding: 16px; margin-top: 24px; text-align: left; }
    .info dt { font-weight: bold; margin-top: 8px; }
    .info dd { margin: 0 0 4px 0; font-family: monospace; }
  </style>
</head>
<body>
  <h1>${project_name}</h1>
  <p>This page is served from an EC2 instance.</p>
  <dl class="info">
    <dt>Hostname</dt>
    <dd>${hostname}</dd>
    <dt>Private IP</dt>
    <dd>$${PRIVATE_IP}</dd>
  </dl>
</body>
</html>
HTML

systemctl enable httpd
systemctl start httpd
