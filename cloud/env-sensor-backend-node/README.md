# env-sensor-backend-node

IoT環境センサーのバックエンドシステム（Node.js実装）です。環境センサーから送信された測定値をAWS IoT Coreで受信し、DynamoDBに保存して、Webダッシュボードで可視化します。

## プロジェクト構成

- `src/dashboard/` - ダッシュボードのLambda関数
- `template.yaml` - AWS SAMテンプレート

## アーキテクチャ

- **AWS IoT Core**: デバイスからMQTTでデータを受信
- **DynamoDB**: センサーデータを保存
- **Lambda**: ダッシュボードのバックエンド
- **API Gateway**: ダッシュボードへのHTTPアクセス

## 必要なツール

- [SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
- [Node.js 22](https://nodejs.org/en/)
- [Docker](https://hub.docker.com/search/?type=edition&offering=community)

## デプロイ

初回デプロイ時は以下のコマンドを実行します。

```bash
sam build
sam deploy --guided
```

2回目以降は以下のコマンドでデプロイできます。

```bash
sam build && sam deploy
```

## ローカルでのテスト

ローカルでAPIを起動してテストできます。

```bash
sam build
sam local start-api
```

その後、ブラウザで http://localhost:3000/ にアクセスします。

## 削除

スタックを削除するには以下のコマンドを実行します。

```bash
sam delete
```
