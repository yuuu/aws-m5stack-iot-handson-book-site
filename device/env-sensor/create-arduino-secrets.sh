#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CERTS_DIR="${SCRIPT_DIR}/certs"
OUTPUT_FILE="${SCRIPT_DIR}/arduino_secrets.h"

echo "=== Arduino Secrets Generator ==="
echo ""

# ユーザー入力を求める
read -p "Enter Wi-Fi SSID: " WIFI_SSID
read -sp "Enter Wi-Fi Password: " WIFI_PASSWORD
echo ""
read -p "Enter AWS IoT Endpoint: " AWS_IOT_ENDPOINT
echo ""

# 証明書ファイルを検索
ROOT_CA_FILE="${CERTS_DIR}/AmazonRootCA1.pem"
CERTIFICATE_FILE=$(find "${CERTS_DIR}" -name "*-certificate.pem.crt" | head -n 1)
PRIVATE_KEY_FILE=$(find "${CERTS_DIR}" -name "*-private.pem.key" | head -n 1)

# ファイルの存在確認
if [ ! -f "${ROOT_CA_FILE}" ]; then
    echo "Error: AmazonRootCA1.pem not found in certs directory"
    exit 1
fi

if [ -z "${CERTIFICATE_FILE}" ]; then
    echo "Error: Certificate file (*-certificate.pem.crt) not found in certs directory"
    exit 1
fi

if [ -z "${PRIVATE_KEY_FILE}" ]; then
    echo "Error: Private key file (*-private.pem.key) not found in certs directory"
    exit 1
fi

echo "Found certificate files:"
echo "  Root CA: ${ROOT_CA_FILE}"
echo "  Certificate: ${CERTIFICATE_FILE}"
echo "  Private Key: ${PRIVATE_KEY_FILE}"
echo ""

# 証明書ファイルの内容を読み込む
ROOT_CA_CONTENT=$(cat "${ROOT_CA_FILE}")
CERTIFICATE_CONTENT=$(cat "${CERTIFICATE_FILE}")
PRIVATE_KEY_CONTENT=$(cat "${PRIVATE_KEY_FILE}")

# arduino_secrets.h を生成（heredocの変数展開を使用）
cat > "${OUTPUT_FILE}" << EOF
#pragma once

// Wi-Fi credentials
// Replace with your Wi-Fi SSID
const char WIFI_SSID[] = "${WIFI_SSID}";
// Replace with your Wi-Fi password
const char WIFI_PASSWORD[] = "${WIFI_PASSWORD}";

// AWS IoT Core details
// Replace with your AWS IoT Core endpoint
const char AWS_IOT_ENDPOINT[] = "${AWS_IOT_ENDPOINT}";

// Amazon Root CA 1
// Replace with your Amazon Root CA 1 certificate
const char AWS_IOT_ROOT_CA[] = R"EOF(
${ROOT_CA_CONTENT}
)EOF";

// Device Certificate
// Replace with your device certificate
const char AWS_IOT_CERTIFICATE[] = R"EOF(
${CERTIFICATE_CONTENT}
)EOF";

// Device Private Key
// Replace with your device private key
const char AWS_IOT_PRIVATE_KEY[] = R"EOF(
${PRIVATE_KEY_CONTENT}
)EOF";
EOF

echo "✓ Successfully created ${OUTPUT_FILE}"
echo ""
echo "IMPORTANT: This file contains sensitive information."
echo "Make sure it is added to .gitignore and never committed to version control."
