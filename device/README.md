# Device Firmware

IoTシステムのデバイスファームウェアです。

## セットアップ

### 1. 秘密情報の設定

デバイスをAWS IoT Coreに接続するため、Wi-Fi情報と証明書の設定が必要です。

1. `env-sensor/arduino_secrets_example.h` を `env-sensor/arduino_secrets.h` にコピーする

```bash
cp env-sensor/arduino_secrets_example.h env-sensor/arduino_secrets.h
```

2. `env-sensor/arduino_secrets.h` を編集し、以下の情報を設定する

#### Wi-Fi設定
- `SECRET_WIFI_SSID`: Wi-FiのSSID
- `SECRET_WIFI_PASSWORD`: Wi-Fiのパスワード

#### AWS IoT Core設定
- `SECRET_AWS_IOT_ENDPOINT`: AWS IoT CoreのエンドポイントURL
  - AWS IoT Coreコンソールの「設定」から確認できます
  - 形式: `xxxxxxxxxxxxxx.iot.ap-northeast-1.amazonaws.com`
- `SECRET_AWS_IOT_CLIENT_NAME`: デバイス名（任意の識別子）

#### 証明書設定
- `SECRET_DEVICE_CERTIFICATE`: デバイス証明書の内容
  - AWS IoT Coreでモノを作成した際にダウンロードした証明書ファイル（`xxx-certificate.pem.crt`）の内容を貼り付けます
- `SECRET_DEVICE_PRIVATE_KEY`: デバイスの秘密鍵
  - AWS IoT Coreでモノを作成した際にダウンロードした秘密鍵ファイル（`xxx-private.pem.key`）の内容を貼り付けます
- `SECRET_ROOT_CA_CERTIFICATE`: Amazon Root CA証明書
  - [Amazon Root CA証明書](https://www.amazontrust.com/repository/AmazonRootCA1.pem)をダウンロードし、その内容を貼り付けます

> **注意**: `arduino_secrets.h` ファイルは秘密情報が含まれるため、Gitにコミットしないでください。`.gitignore`に登録されています。

### 2. ビルドとアップロード

Makefileを使用してビルド・アップロードします。

```bash
cd env-sensor

# ビルドのみ
make build

# デバイスにアップロード（ポート指定が必要な場合）
make upload PORT=/dev/ttyUSB0

# ビルドとアップロードを一度に実行
make flash

# シリアルモニタを開く
make monitor

# 利用可能なポートを確認
make list-ports
```

利用可能なMakeターゲットの詳細は `make help` で確認できます。

## ハードウェア

対応ハードウェアと仕様の詳細は [spec.md](spec.md) を参照してください。
