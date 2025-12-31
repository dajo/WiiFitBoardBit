#!/bin/bash
# Generate self-signed SSL certificate for Fitbit OAuth

CERT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/fitbit_sync"

echo "Generating self-signed SSL certificate for HTTPS..."

# Generate private key and certificate
openssl req -x509 -newkey rsa:4096 -nodes \
    -out "$CERT_DIR/cert.pem" \
    -keyout "$CERT_DIR/key.pem" \
    -days 3650 \
    -subj "/C=US/ST=State/L=City/O=Personal/CN=wiifitboardbit"

echo "Certificate generated:"
echo "  Certificate: $CERT_DIR/cert.pem"
echo "  Private Key: $CERT_DIR/key.pem"
echo ""
echo "These files will be used for HTTPS on the Fitbit auth server."
