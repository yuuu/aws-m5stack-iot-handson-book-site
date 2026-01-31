## 概要

IoTシステムのデバイスのファームウェアです。

## ハードウェア

次の2種類のハードウェアのいずれでも動作するものとする。

- M5Stack Core S3
- M5Atom S3

いずれのハードウェアもGrove Port.A(I2C)でM5Stack用温湿度気圧センサユニット Ver.3（ENV Ⅲ）が接続される。
このセンサユニットには温湿度センサSHT30と気圧センサQMP6988が搭載されている。

## ソフトウェア

arduino-esp32上で動作する。
arduino-cliを使って、Arduino Sketchを開発します。
使用するボードやライブラリは `env-sensor/sketch.yaml` を参照ください。現時点で記載のないライブラリは使えないものとしてください。

## 仕様

- 温度・湿度・気圧を計測する。温度はSHT30の値を採用する
- MCUであるESP32にてWi-Fiへ接続し、インターネット経由でAWS IoT Coreに接続する
- 計測した値は次の用途で使用する
    - シリアル通信経由で出力する
    - M5Stack Core S3の場合のみ、LCDに表示する
    - MQTTSでAWS IoT Coreへ送信する
- Wi-Fiへの接続情報やAWS IoT Coreとの接続に使用するエンドポイント・証明書は `arduino_secrets.h` というコードに記載する
- 計測周期は1分とする。計測やAWS IoT Coreへの送信に多少時間がかかっても周期が変動しないよう工夫すること

## 送信するメッセージ

AWS IoT Coreには次のような形式でJSONを送信するものとする。

```json
{
  "temperature": 26.0, // 温度(度)
  "humidity": 40.0,    // 湿度(%)
  "pressure": 1013.0   // 気圧(hPa)
}
```

## 制約

- 1つの関数が20行を超えないようにしてください