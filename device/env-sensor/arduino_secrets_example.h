#pragma once

// Wi-Fi credentials
// Replace with your Wi-Fi SSID
const char WIFI_SSID[] = "YOUR_WIFI_SSID";
// Replace with your Wi-Fi password
const char WIFI_PASSWORD[] = "YOUR_WIFI_PASSWORD";

// AWS IoT Core details
// Replace with your AWS IoT Core endpoint
const char AWS_IOT_ENDPOINT[] = "YOUR_AWS_IOT_ENDPOINT";

// Amazon Root CA 1
// Replace with your Amazon Root CA 1 certificate
const char AWS_IOT_ROOT_CA[] = R"EOF(
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
)EOF";

// Device Certificate
// Replace with your device certificate
const char AWS_IOT_CERTIFICATE[] = R"EOF(
-----BEGIN CERTIFICATE-----
-----END CERTIFICATE-----
)EOF";

// Device Private Key
// Replace with your device private key
const char AWS_IOT_PRIVATE_KEY[] = R"EOF(
-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----
)EOF";
